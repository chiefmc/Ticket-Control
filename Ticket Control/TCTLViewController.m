//
//  TCTLViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLConstants.h"
#import "TCTLViewController.h"
#import "TCTLScanResultItem.h"
#import "TCTLServerQueryResponse.h"
#import "TCTLServerCommand.h"
#import "TCTLLogTableViewController.h"

@interface TCTLViewController ()

// Таймер, брасывающий статус в "Ожидание Проверки"
@property (nonatomic) NSTimer			*timer;

// Признак того, что система не готова сканировать следующий код
@property BOOL							isBusy;

// Переменные в которые читаются настройки париложения из Settings Bundle
@property NSInteger						*vibroStrength;
@property BOOL							disableAutolock;
@property NSString						*userGUID;
@property NSTimeInterval				resultDisplayTime;
@property NSURL							*serverURL;
@property BOOL							scannerBeep;

@end

@implementation TCTLViewController

#pragma mark - Actions:

// -------------------------------------------------------------------------------
// Инициируем сканирование штрих-кода
// -------------------------------------------------------------------------------
- (IBAction)tappedScan:(id)sender
{
    // Если система не занята, то запускаем сканирование
	if (!self.isBusy) {
		[[MLScanner sharedInstance] scan];

#ifdef DEBUG
		// После тестирования удалить!
		NSLog(@"Sending a test barcode");
		[self doScannedBarcodeCheck: @"1234567890123"];
#endif
	}
}

// -------------------------------------------------------------------------------
// Показывает alert с детальным статусом батареи саней
// -------------------------------------------------------------------------------
- (IBAction)sledShowSledBatDetails:(id)sender
{
	
}

// -------------------------------------------------------------------------------
// Показывает alert со статусом соединения с билетным сервером
// -------------------------------------------------------------------------------
- (IBAction)showServerConnectionInfo:(id)sender
{
    
}

// -------------------------------------------------------------------------------
// Перед переходом к таблице лога сканирования передаём ссылку на сам лог
// -------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString: @"logTableSegue"]) {
		TCTLLogTableViewController *destinationController = segue.destinationViewController;
		destinationController.scanResultItems = self.scanResultItems;
	}
}
/*
// -------------------------------------------------------------------------------
// Вызывает таблицу лога результатов сканирования
// -------------------------------------------------------------------------------
- (IBAction)logTableButtonTapped:(id)sender
{
	return;
	TCTLLogTableViewController *destinationController = [[TCTLLogTableViewController alloc] init];
	destinationController.scanResultItems = self.scanResultItems;
	[self presentViewController:destinationController animated:YES completion:nil];
	// [self.navigationController pushViewController:destinationController animated:YES];
}*/

// -------------------------------------------------------------------------------
// Возвращает на главный экран
// -------------------------------------------------------------------------------
- (IBAction)unwindToMainScreen:(UIStoryboardSegue *)segue
{
	
}

// ------------------------------------------------------------------------------
// Запускается после загрузки view
// ------------------------------------------------------------------------------
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[[MLScanner sharedInstance] addAccessoryDidConnectNotification:self];
	[[MLScanner sharedInstance] addAccessoryDidDisconnectNotification:self];
	[[MLScanner sharedInstance] addReceiveCommandHandler:self];
	
	self.isBusy = NO;
	// фильтрация истории сканирования
	if (self.scanResultItems != nil) {
		for (TCTLScanResultItem *logItem in self.scanResultItems) {
			// если записи в логе больше 24 часов удаляем её
			if ([logItem.locallyCheckedTime compare: [[NSDate date] dateByAddingTimeInterval: -24*60*60]] == NSOrderedAscending) {
				[self.scanResultItems removeObject: logItem];
			}
		}
	} else {
		// если лога нет, то создаём пустой
		self.scanResultItems = [[NSMutableArray alloc] init];
	}
#ifdef DEBUG
	NSLog(@"viewDidLoad done.");
#endif
}

// ------------------------------------------------------------------------------
// Обработчик при нехватке памяти
// ------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	// [self isScannerConnected];
#ifdef DEBUG
	NSLog(@"viewDidAppear done.");
#endif
}

- (void)dealloc
{
	[[MLScanner sharedInstance] removeAccessoryDidConnectNotification:self];
	[[MLScanner sharedInstance] removeAccessoryDidDisconnectNotification:self];
	[[MLScanner sharedInstance] removeReceiveCommandHandler:self];
}

// -------------------------------------------------------------------------------
//	viewWillAppear:
// -------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load our preferences.  Preloading the relevant preferences here will
    // prevent possible diskIO latency from stalling our code in more time
    // critical areas, such as tableView:cellForRowAtIndexPath:, where the
    // values associated with these preferences are actually needed.
    [self onDefaultsChanged:nil];
    
    // Begin listening for changes to our preferences when the Settings app does
    // so, when we are resumed from the backround, this will give us a chance to
    // update our UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDefaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
#ifdef DEBUG
	NSLog(@"viewWillAppear done.");
#endif
}

// -------------------------------------------------------------------------------
//	viewWillDisappear:
// -------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    // Stop listening for the NSUserDefaultsDidChangeNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - NotificationHandler

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при подкдючении сканера
// -------------------------------------------------------------------------------
- (void)connectNotify
{
#ifdef DEBUG
	NSLog(@"Received connectNotify");
#endif
	// Отображаем статус подключённого сканера
	UIImage *noScanner = [UIImage imageNamed: @"battery70"];
	[self.scannerBatStatusIcon setImage: noScanner forState: UIControlStateNormal];

	// Инициируем опрос заряда батареи
	[self performSelector:@selector(postponeBatteryRemain) withObject:nil afterDelay:0.8f];
	
	// Устанавливаем настройки сканера из Settings Bundle
	[[MLScanner sharedInstance] vibraMotorStrength: *self.vibroStrength];
	[[MLScanner sharedInstance] beepSwitch: self.scannerBeep];
#ifdef DEBUG
	NSLog(@"Sent settings to scanner: \n vibro: %ld \n beep: %ld", (long)self.vibroStrength, (long)self.scannerBeep);
#endif
}

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при отключении сканера
// -------------------------------------------------------------------------------
- (void)disconnectNotify
{
#ifdef DEBUG
	NSLog(@"Received disconnectNotify");
#endif
	// Отображаем статус отключённого девайса
	UIImage *noScanner = [UIImage imageNamed: @"barcode"];
	[self.scannerBatStatusIcon setImage: noScanner forState: UIControlStateNormal];
	// [self checkConnected];
	// self.scannedBarcode = @"";
}

#pragma mark - ReceiveCommandHandler

// ------------------------------------------------------------------------------
// Отвечает framework'у, что этот объект является обработчиком
// ------------------------------------------------------------------------------
- (BOOL)isHandler:(NSObject <ReceiveCommandProtocol> *)command
{
	if ([command isKindOfClass:[ReceiveCommand class]]) {
		return TRUE;
	}
	
	return FALSE;
}

// ------------------------------------------------------------------------------
// Обработчик, вызываемый сканером, после успешного сканирования
// ------------------------------------------------------------------------------
- (void)handleRequest:(NSObject <ReceiveCommandProtocol> *)command
{
#ifdef DEBUG
	NSLog(@"Received handleRequest");
#endif
	// Если система занята, то игнорируем результаты сканирования
	if (!self.isBusy) {
		[self doScannedBarcodeCheck: [command receiveString]];
	}
}

// ------------------------------------------------------------------------------
// Обработчик, вызываемый сканером, при обновлении статуса заряда и батареи
// ------------------------------------------------------------------------------
- (void)handleInformationUpdate
{
#ifdef DEBUG
	NSLog(@"Received handleInformationUpdate");
#endif
	// Обрабатываем обновлённую информацию о заряде
	// NSNumber *capacity = [[MLScanner sharedInstance] batteryCapacity];
	// self.sledBatRemain = [NSString stringWithFormat:@"%@ %%", [capacity stringValue]];
}

#pragma mark - private

// -------------------------------------------------------------------------------
// Осуществляет проверку штих-кода
// -------------------------------------------------------------------------------
- (void)doScannedBarcodeCheck: (NSString *)barcode
{
	self.isBusy = YES;
	
	// Отображаем, что поиск начат
	[self displayProgress];
	
	// Опрашиваем сервер и ждём ответ
	TCTLServerCommand *serverCommand = [[TCTLServerCommand alloc] initWithCommand: getCodeResult withGUID: _userGUID withBarcode: barcode];
	[serverCommand doSendCommand];
	TCTLServerQueryResponse *serverResponse = serverCommand.getServerResponse;
	
	// Показываем результат
	[self displayScanResult: serverResponse];
	
	// Запускаем таймер, по окончании которого снова отображается "Ожидание Проверки"
	[self runTimer];
	
	// Упаковываем результат сканирования в формат лога
	TCTLScanResultItem *logItem = [[TCTLScanResultItem alloc] initItemWithBarcode: barcode FillTextWith: serverResponse];
	
	// Добавляем результат сканирования в коллекцию результатов
	if (!self.scanResultItems) {
		self.scanResultItems = [NSMutableArray init];
	} else if ([self.scanResultItems count] == 100) {
		[self.scanResultItems removeLastObject];
	}
	[self.scanResultItems insertObject: logItem atIndex: 0];
	
	self.isBusy = NO;
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Стоять!" message:@"Ты чего тут кнопки тычешь?" delegate:self cancelButtonTitle:@"Не буду" otherButtonTitles:@"Буду", nil];
	[alert show];
	*/
}

// -------------------------------------------------------------------------------
// Проверяем подключен ли сканер
// -------------------------------------------------------------------------------
- (BOOL)isScannerConnected
{
	return [[MLScanner sharedInstance] isConnected];
}
/*
- (NSNumber *)getScannerBatRemain
{
	// get battery info
	[[MLScanner sharedInstance] batteryRemain];
	return [[MLScanner sharedInstance] batteryCapacity];
}

// Заряжается ли сканер в данный момент
- (BOOL)isScannerOnCharge
{
	return [[MLScanner sharedInstance] batteryOnCharge];
}

// -------------------------------------------------------------------------------
// Зарядить батарею iДевайса от сканера
// -------------------------------------------------------------------------------
- (void)chargeBattery {
  [[MLScanner sharedInstance] chargeBattery];
}
*/

// -------------------------------------------------------------------------------
// Включаем или отключаем значок ожидания
// -------------------------------------------------------------------------------
- (void)showWaitingSign:(bool)show
{
	if (show) {
		[self.waitSign startAnimating];
	} else {
		[self.waitSign stopAnimating];
	}
}

// -------------------------------------------------------------------------------
// Запускает таймер, сбрасывающий отображение статуса, по истечении времени
// -------------------------------------------------------------------------------
- (void)runTimer
{
	if (self.timer != nil) {
		[self.timer invalidate];
	}
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.resultDisplayTime target:self selector:@selector(displayReadyToScan:) userInfo:nil repeats:NO];
}

// -------------------------------------------------------------------------------
// Запускает начальную проверку заряда сканера с задержкой
// -------------------------------------------------------------------------------
- (void)postponeBatteryRemain
{
	// get battery info
	[[MLScanner sharedInstance] batteryRemain];
#ifdef DEBUG
	NSLog(@"Battery remain request sent");
#endif
}

// -------------------------------------------------------------------------------
// Отображает начальный экран "Ожидание Проверки"
// -------------------------------------------------------------------------------
- (void)displayReadyToScan: (NSTimer *)timer
{
	[self.background setBackgroundColor: [UIColor whiteColor]];
	[self.scannedStatus setText: textReadyToCheck];
	[self.scannedStatus setTextColor: [UIColor darkGrayColor]];
	[self.scannedSubStatus setTextColor: [UIColor clearColor]];
	[self showWaitingSign: NO];
}

// -------------------------------------------------------------------------------
// Отображает экран "Поиск Билета"
// -------------------------------------------------------------------------------
- (void)displayProgress
{
	[self.background setBackgroundColor: [UIColor lightGrayColor]];
	[self.scannedStatus setText: textLookingForTicket];
	[self.scannedStatus setTextColor: [UIColor darkGrayColor]];
	[self.scannedSubStatus setTextColor: [UIColor clearColor]];
	[self showWaitingSign: YES];
}

// -------------------------------------------------------------------------------
// Отображает статус в зависимости от результата
// -------------------------------------------------------------------------------
- (void)displayScanResult: (TCTLServerQueryResponse *)scanResult
{
	switch (scanResult.responseCode) {
		case accessAllowed:
			[self.background setBackgroundColor: [UIColor greenColor]];
			[self.scannedStatus setText: textAccessAllowed];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setTextColor: [UIColor clearColor]];
			[self showWaitingSign: NO];
			break;
			
		case accessDeniedTicketNotFound:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textTicketNotFound];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			[self showWaitingSign: NO];
			break;
			
		case accessDeniedAlreadyPassed:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textTicketAlreadyPassed];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			[self showWaitingSign: NO];
			break;
			
		case accessDeniedWrongEntrance:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textWrongEntrance];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			[self showWaitingSign: NO];
			break;
			
		case accessDeniedNoActiveEvent:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textNoEventToControl];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			[self showWaitingSign: NO];
			break;
			
		default:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textUnknownError];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			[self showWaitingSign: NO];
			break;
	}
}

#pragma mark - Preferences

// -------------------------------------------------------------------------------
//	onDefaultsChanged:
//  Handler for the NSUserDefaultsDidChangeNotification.  Loads the preferences
//  from the defaults database into the holding properies, then asks the
//  tableView to reload itself.
// -------------------------------------------------------------------------------
- (void)onDefaultsChanged:(NSNotification*)aNotification
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    self.vibroStrength		= (NSInteger *)[standardDefaults integerForKey: kVibroStrength];
	self.scannerBeep		= [standardDefaults boolForKey: kScannerBeep];
	self.disableAutolock	= [standardDefaults boolForKey: kDisableAutolock];
    self.userGUID			= [standardDefaults objectForKey: kUserGUID];
    self.resultDisplayTime	= (NSTimeInterval)[standardDefaults integerForKey:kResultDisplayTime];
	self.serverURL			= [standardDefaults objectForKey: kServerURL];
    
	if ([self isScannerConnected]) {
		// Устанавливаем обновлённые установки в сканер
	}
	
#ifdef DEBUG
	NSLog(@"Settings has changed:");
	NSLog(@"Vibro: %ld", (long)self.vibroStrength);
	NSLog(@"Beep: %hhd", self.scannerBeep);
	NSLog(@"No autolock: %hhd", self.disableAutolock);
	NSLog(@"GUID: %@", self.userGUID);
	NSLog(@"Timer: %lds", (long)self.resultDisplayTime);
	NSLog(@"URL: %@", self.serverURL);
#endif
	
    // [self.tableView reloadData];
}

#pragma mark - Server query methods

// -------------------------------------------------------------------------------
//	Проверяет отвечает ли сервер
// -------------------------------------------------------------------------------
- (BOOL) isServerAlive
{
	return YES;
};

// -------------------------------------------------------------------------------
//	Проверяет штрих-код на сервере
// -------------------------------------------------------------------------------
- (TCTLServerQueryResponse *) sendBarcodeToServer: (NSString *)barcode
{
	TCTLServerQueryResponse *response = [[TCTLServerQueryResponse alloc] init];
	[response setResponseCode: accessAllowed];
	return response;
};

// -------------------------------------------------------------------------------
//	Запрашивает текстовое имя текущего устройства на сервере по GUID
// -------------------------------------------------------------------------------
- (NSString *) getUserName
{
	return @"Контроллёр 1";
};

@end
