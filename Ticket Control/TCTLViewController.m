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
#import "TCTLServerResponse.h"
#import "TCTLServerCommand.h"
#import "TCTLLogTableViewController.h"
#import "XMLDictionary.h"

@interface TCTLViewController ()

// Таймер, cбрасывающий статус в "Ожидание Проверки"
@property (nonatomic) NSTimer			*timer;

// Признак того, что система не готова сканировать следующий код. Если YES, то система будет игнорировать все сканирования
@property BOOL							isBusy;

// Признак того, что сервер подключён
@property BOOL							isServerConnected;

// Команда и ответ от сервера
// @property (strong, nonatomic) TCTLServerCommand	*serverCommand;
// @property (strong, nonatomic) TCTLServerResponse *serverResponse;

// Переменные в которые читаются настройки париложения из Settings Bundle
@property NSInteger						vibroStrength;
@property BOOL							disableAutolock;
@property NSString						*userGUID;
@property NSTimeInterval				resultDisplayTime;
@property NSURL							*serverURL;
@property BOOL							scannerBeep;

// Служебные переменные
@property BOOL							isUserNameSet;
@property BOOL							isUpsideDown;
@property NSString						*lastScannedBarcode;

@end

@implementation TCTLViewController

#pragma mark - Actions:

// -------------------------------------------------------------------------------
// Инициируем сканирование штрих-кода
// -------------------------------------------------------------------------------
- (IBAction)tappedScan:(id)sender
{
#ifdef DEBUG
	NSLog(@"tappedScan received");
#endif

    // Если система не занята, то запускаем сканирование
	if (!_isBusy) {
		[[MLScanner sharedInstance] scan];

#if TARGET_IPHONE_SIMULATOR
		[self doScannedBarcodeCheck: @"1234567890123"];
#endif
	}
}

// -------------------------------------------------------------------------------
// Показывает alert с детальным статусом батареи саней
// -------------------------------------------------------------------------------
- (IBAction)showScannerBatDetails:(id)sender
{
#ifdef DEBUG
	NSLog(@"showScannerBatDetails received");
#endif
	NSString *message;
	if ([self isScannerConnected]) {
		if ([self isScannerOnCharge]) {
			message = textScannerBatteryOnCharge;
		} else {
			message = [textScannerBatteryCharge stringByAppendingFormat: @"%@%%", [self getScannerBatRemain]];
		}
	} else {
		message = textScannerIsNotConnected;

	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: textInformation message: message delegate:nil cancelButtonTitle: textOk otherButtonTitles: nil];
	[alert show];
}

// -------------------------------------------------------------------------------
// Показывает alert со статусом соединения с билетным сервером
// -------------------------------------------------------------------------------
- (IBAction)showServerConnectionInfo:(id)sender
{
#ifdef DEBUG
	NSLog(@"showServerConnectionInfo received");
#endif
#ifdef DEBUG
	NSLog(@"showScannerBatDetails received");
#endif
	NSString *message;
	if (_isServerConnected) {
		message = textServerConnected;
	} else {
		message = textNoServerConnection;
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: textInformation message: message delegate:nil cancelButtonTitle: textOk otherButtonTitles: nil];
	[alert show];
}

// -------------------------------------------------------------------------------
// Поворачивает отображение приложения на 180 градусов - не работает в версии iOS 6.1+
// -------------------------------------------------------------------------------
- (IBAction)rotateViewOrientation:(id)sender
{
#ifdef DEBUG
	NSLog(@"rotateViewOrientation received: %hhd", self.isUpsideDown);
#endif
	if (self.isUpsideDown) {
		self.isUpsideDown = NO;
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		UIView *view = [window.subviews objectAtIndex:0];
		[view removeFromSuperview]; [window addSubview:view];
	} else {
		self.isUpsideDown = YES;
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		UIView *view = [window.subviews objectAtIndex:0];
		[view removeFromSuperview]; [window addSubview:view];
	}
}

// -------------------------------------------------------------------------------
// Перед переходом к таблице лога сканирования передаём ссылку на сам лог
// -------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#ifdef DEBUG
	NSLog(@"prepareForSegue received");
#endif
	if ([segue.identifier isEqualToString: @"logTableSegue"]) {
		// Устанавливаем статус приложения в "Не готово к сканированию"
		[self setAppBusyStatus: YES];
		
		// Передаем в контроллер таблицы данные лога
		TCTLLogTableViewController *destinationController = segue.destinationViewController;
		destinationController.scanResultItems = self.scanResultItems;
	}
}

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
#ifdef DEBUG
	NSLog(@"viewDidLoad begins...");
#endif
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_isUpsideDown = NO;
	_isUserNameSet = NO;
	
	[[MLScanner sharedInstance] addAccessoryDidConnectNotification:self];
	[[MLScanner sharedInstance] addAccessoryDidDisconnectNotification:self];
	[[MLScanner sharedInstance] addReceiveCommandHandler:self];
	
	// Настраиваем XML-парсер
	// [XMLDictionaryParser sharedInstance].stripEmptyNodes = NO;
	
	// Готовим лог ответов от сервера
	[self prepareScanResultItems];
	
	// по умолчанию считаем, что связи нет
	[self serverConnectionStatus: NO];
		
	// Проверка подключения сканера и отображение статуса
	if ([self isScannerConnected]) {
		[self setAppBusyStatus: NO];
		[self displayReadyToScan];
	} else {
		[self setAppBusyStatus: YES];
		[self displayNotReady];
	}
	
	// Планируем проверку связи с сервером
	[self performSelector:@selector(invocateGetUserName) withObject:nil afterDelay:0.5f];

#ifdef DEBUG
	NSLog(@"viewDidLoad done.");
#endif
}

// ------------------------------------------------------------------------------
// Обработчик при нехватке памяти
// ------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"didReceiveMemoryWarning received");
#endif

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	// Устанавливаем правльную иконку подключения сканера
	if (self.isScannerConnected) {
		[self postponeBatteryRemain];
#if TARGET_IPHONE_SIMULATOR
		[self setBatteryRemainIcon];
#endif

	} else {
		[self setBatteryRemainIcon];
	}
	
#ifdef DEBUG
	NSLog(@"viewDidAppear done.");
#endif
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc received");
#endif

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
#ifdef DEBUG
	NSLog(@"viewWillDisappear received");
#endif
	// Устанавливаем статус приложения в "Готово к сканированию"
	// [self setAppBusyStatus: NO];

    // Stop listening for the NSUserDefaultsDidChangeNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - Inherited methods

-(BOOL) shouldAutorotate {
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
	/*if (_isUpsideDown) {
		return (enum UIInterfaceOrientation) UIInterfaceOrientationMaskPortraitUpsideDown;
	} else {
		return (enum UIInterfaceOrientation) UIInterfaceOrientationMaskPortrait;
	}*/
}

#pragma mark - NotificationHandler

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при подкдючении сканера
// -------------------------------------------------------------------------------
- (void)connectNotify
{
#ifdef DEBUG
	NSLog(@"connectNotify received");
#endif
	// Показываем статус готовности к сканированию
	[self setAppBusyStatus: NO];
	[self displayReadyToScan];
	
	// Инициируем опрос заряда батареи
	[self performSelector:@selector(postponeBatteryRemain) withObject:nil afterDelay:0.8f];
	
	// Устанавливаем настройки сканера с задержкой в 1 сек
	[self performSelector:@selector(setScannerPreferences) withObject:nil afterDelay:0.5f];
}

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при отключении сканера
// -------------------------------------------------------------------------------
- (void)disconnectNotify
{
#ifdef DEBUG
	NSLog(@"disconnectNotify received");
#endif
	// Показываем статус неготовности к сканированию
	[self setAppBusyStatus:YES];
	[self displayNotReady];
	
	// Отображаем статус отключённого девайса
	[self setBatteryRemainIcon];
}

#pragma mark - ReceiveCommandHandler

// ------------------------------------------------------------------------------
// Отвечает framework'у, что этот объект является обработчиком
// ------------------------------------------------------------------------------
- (BOOL)isHandler:(NSObject <ReceiveCommandProtocol> *)command
{
#ifdef DEBUG
	NSLog(@"isHandler received");
#endif

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
	NSLog(@"handleRequest received");
#endif
	// Если система занята, то игнорируем результаты сканирования
	if (!_isBusy) {
		[self doScannedBarcodeCheck: [command receiveString]];
	}
}

// ------------------------------------------------------------------------------
// Обработчик, вызываемый сканером, при обновлении статуса заряда и батареи
// ------------------------------------------------------------------------------
- (void)handleInformationUpdate
{
#ifdef DEBUG
	NSLog(@"handleInformationUpdate received");
#endif
	// Обрабатываем обновлённую информацию о заряде
	[self setBatteryRemainIcon];
}

#pragma mark - Delegates
// ------------------------------------------------------------------------------
// Обработчик, вызываемый XMLRPC, при получении ответа или ошибки от сервера
// ------------------------------------------------------------------------------
- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)xmlResponse {
	
	UIAlertView *alert;
	
#ifdef DEBUG
	NSLog(@"didReceiveResponse from XMLRPC.");
#endif
	
    if ([xmlResponse isFault]) {
		// Если получили ошибку, то...
#ifdef DEBUG
        NSLog(@"Fault code: %@", [xmlResponse faultCode]);
        NSLog(@"Fault string: %@", [xmlResponse faultString]);
#endif
		// Показываем алерт
		NSString *message = textErrorConnectingToServer;
		[message stringByAppendingFormat:@"\n Код ошибки: %@ (%@)", [xmlResponse faultCode], [xmlResponse faultString]];
		alert = [[UIAlertView alloc] initWithTitle:textError message: message delegate:nil cancelButtonTitle:textRetry otherButtonTitles: nil];
		[alert show];
		// Отображаем разрыв соединения с сервером
		[self serverConnectionStatus:NO];
		
    } else {
		// Если ответ нормальный, то обрабатываем...
#ifdef DEBUG
        NSLog(@"Parsed response: %@", [xmlResponse object]);
#endif
		TCTLServerResponse *serverResponse = [[TCTLServerCommand sharedInstance] unpackResponse:xmlResponse];
		
		// Обрабатываем возможные ответы сервера
		switch (serverResponse.responseCode) {
			case resultOk:
				[self serverConnectionStatus:YES];
				break;
			
			case setActiveUser:
				_userName.text = serverResponse.userName;
				_isUserNameSet = YES;
				break;
			
			case setActiveUserNotFound:
				// Устанавливаем имя пользователя на главном экране в значение имени текущего девайса
				[self.userName setText: [UIDevice currentDevice].name];

				// Показываем алерт
				alert = [[UIAlertView alloc]initWithTitle:textError message:@"Ошибка GUID! Обратитесь к администратору системы" delegate:nil cancelButtonTitle:textCancel otherButtonTitles: nil];
				[alert show];
				break;
				
			case setActiveEvent:
#warning Пока не реализовано
				break;
				
			case setActiveEventNotFound:
#warning Пока не реализовано
				break;
				
			case accessAllowed ... accessDeniedUnknownError:
			{
				// Проверяем совпадение штрих-кода
				if (serverResponse.barcode == _lastScannedBarcode) {
					// Показываем результат
					[self displayScanResult: serverResponse];
					
					// Запускаем таймер, по окончании которого снова отображается "Ожидание Проверки"
					[self runTimer];
					
					// Упаковываем результат сканирования в формат лога
					TCTLScanResultItem *logItem = [[TCTLScanResultItem alloc] initItemWithBarcode: serverResponse.barcode FillTextWith: serverResponse];
					[self addScanResultItem:logItem];

					break;
				}
			}
				
			case errorNetworkError:
				
			default:
				// Показываем алерт
				alert = [[UIAlertView alloc]initWithTitle:textError message:@"Неизвестный ответ сервера" delegate:nil cancelButtonTitle:textRetry otherButtonTitles: nil];
				[alert show];

				break;
			[self serverConnectionStatus:YES];
		}
		[self setAppBusyStatus:NO];
		[self displayReadyToScan];
    }
#ifdef DEBUG
    NSLog(@"Response body: %@", [xmlResponse body]);
#endif
}

// ------------------------------------------------------------------------------
// Обработчик, вызываемый XMLRPC, при получении ответа или ошибки от сервера
// ------------------------------------------------------------------------------
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
#ifdef DEBUG
	NSLog(@"didFailWithError from XMLRPC.");
#endif
	// Показываем алерт
	NSString *message = textErrorConnectingToServer;
	[message stringByAppendingFormat:@"\n Код ошибки: %@", error];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message: textErrorConnectingToServer delegate:nil cancelButtonTitle:textRetry otherButtonTitles: nil];
	[alert show];

	[self setAppBusyStatus:NO];
	[self displayReadyToScan];
	
	// Отображаем разрыв соединения с сервером
	[self serverConnectionStatus:NO];
}

- (BOOL)request: (XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace
{
	return NO;
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	
}

#pragma mark - private

// -------------------------------------------------------------------------------
// Осуществляет проверку штих-кода
// -------------------------------------------------------------------------------
- (void)doScannedBarcodeCheck: (NSString *)barcode
{
#ifdef DEBUG
	NSLog(@"doScannedBarcodeCheck received");
#endif
	// Запоминаем последний код
	_lastScannedBarcode = barcode;
	
	// Устанавливаем статус приложения
	[self setAppBusyStatus: YES];
	[self displayProgress];
	
	// Опрашиваем сервер и ждём ответ
	[[TCTLServerCommand sharedInstance] initWithServer:_serverURL withCommand:getCodeResult withGUID: _userGUID withBarcode: barcode];
	[[TCTLServerCommand sharedInstance] doSendCommand: self];
}

// -------------------------------------------------------------------------------
// Проверяем подключен ли сканер
// -------------------------------------------------------------------------------
- (BOOL)isScannerConnected
{
	BOOL connected;
#if TARGET_IPHONE_SIMULATOR
	connected = YES;
#else
	connected = [[MLScanner sharedInstance] isConnected];
#endif
	
#ifdef DEBUG
	NSLog(@"isScannerConnected received: %hhd", connected);
#endif
	return connected;
}

// -------------------------------------------------------------------------------
// Возвращает остаток заряда батареи сканера в %
// -------------------------------------------------------------------------------
- (NSNumber *)getScannerBatRemain
{
	NSNumber *remain;
#if TARGET_IPHONE_SIMULATOR
	remain = @101;
#else
	// get battery info
	remain = [[MLScanner sharedInstance] batteryCapacity];
#endif

#ifdef DEBUG
	NSLog(@"getScannerBatRemain received: %@", remain);
#endif
	return remain;
}

// -------------------------------------------------------------------------------
// Заряжается ли сканер в данный момент
// -------------------------------------------------------------------------------
- (BOOL)isScannerOnCharge
{
#ifdef DEBUG
	NSLog(@"isScannerOnCharge received");
#endif

#if TARGET_IPHONE_SIMULATOR
	return  YES;
#endif
	return [[MLScanner sharedInstance] batteryOnCharge];
}

// -------------------------------------------------------------------------------
// Зарядить батарею iДевайса от сканера
// -------------------------------------------------------------------------------
- (void)chargeiDeviceBattery {
#ifdef DEBUG
	NSLog(@"chargeiDeviceBattery received");
#endif
  [[MLScanner sharedInstance] chargeiDeviceBattery];
}


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
	if (_timer != nil) {
		[_timer invalidate];
	}
	_timer = [NSTimer scheduledTimerWithTimeInterval:_resultDisplayTime target:self selector:@selector(displayReadyToScan) userInfo:nil repeats:NO];
}

// -------------------------------------------------------------------------------
// Запускает начальную проверку заряда сканера с задержкой
// -------------------------------------------------------------------------------
- (void)postponeBatteryRemain
{
#ifdef DEBUG
	NSLog(@"postponeBatteryRemain received");
#endif
	// get battery info
	[[MLScanner sharedInstance] batteryRemain];
}

// -------------------------------------------------------------------------------
// Запускает начальную проверку заряда сканера с задержкой
// -------------------------------------------------------------------------------
- (void)setBatteryRemainIcon
{
#ifdef DEBUG
	NSLog(@"setBatteryRemainIcon received");
#endif
	UIImage *batIcon;
	if ([self isScannerConnected]) { // проверяем поделючен ли сканер
		NSInteger batRemain = [[self getScannerBatRemain] integerValue];
		
		if ((batRemain > 100) || [self isScannerOnCharge]) {
			batIcon = [UIImage imageNamed: @"battery_charging"];
		} else if (batRemain > 88) {
			batIcon = [UIImage imageNamed: @"battery_100"];
		} else if (batRemain > 63) {
			batIcon = [UIImage imageNamed: @"battery_75"];
		} else if (batRemain > 37) {
			batIcon = [UIImage imageNamed: @"battery_50"];
		} else if (batRemain > 12) {
			batIcon = [UIImage imageNamed: @"battery_25"];
		} else if (batRemain > 5) {
			batIcon = [UIImage imageNamed: @"battery_5"];
		} else {
			batIcon = [UIImage imageNamed: @"battery_0_red"];
		}
	} else { // если сканер не подключен, показываем пустую батарею
		batIcon = [UIImage imageNamed: @"scanner"];
	}
	[self.scannerBatStatusIcon setImage: batIcon forState: UIControlStateNormal];
}

// -------------------------------------------------------------------------------
// Устанавливает статус готовности приложения к новому сканированию
// -------------------------------------------------------------------------------
-(void)setAppBusyStatus: (BOOL)yes
{
	if (yes) {
		_isBusy = YES;
		[self.scanButton setEnabled: NO];
	} else {
		_isBusy = NO;
		[self.scanButton setEnabled: YES];
	}
}

// -------------------------------------------------------------------------------
// Отображает экран "Не Готов"
// -------------------------------------------------------------------------------
- (void)displayNotReady
{
	[self.background setBackgroundColor: [UIColor lightGrayColor]];
	[self.scannedStatus setText: textNotReady];
	[self.scannedStatus setTextColor: [UIColor darkGrayColor]];
	[self.scannedSubStatus setTextColor: [UIColor clearColor]];
	[self showWaitingSign: NO];
}

// -------------------------------------------------------------------------------
// Отображает начальный экран "Ожидание Проверки"
// -------------------------------------------------------------------------------
- (void)displayReadyToScan
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
- (void)displayScanResult: (TCTLServerResponse *)scanResult
{
	[self showWaitingSign: NO];
	switch (scanResult.responseCode) {
		case accessAllowed:
			[self.background setBackgroundColor: [UIColor greenColor]];
			[self.scannedStatus setText: textAccessAllowed];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setTextColor: [UIColor clearColor]];
			break;
			
		case accessDeniedTicketNotFound:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textTicketNotFound];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			break;
			
		case accessDeniedAlreadyPassed:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textTicketAlreadyPassed];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			break;
			
		case accessDeniedWrongEntrance:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textWrongEntrance];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			break;
			
		case accessDeniedNoActiveEvent:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textNoEventToControl];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			break;
			
		default:
			[self.background setBackgroundColor: [UIColor redColor]];
			[self.scannedStatus setText: textAccessDenied];
			[self.scannedStatus setTextColor: [UIColor whiteColor]];
			[self.scannedSubStatus setText: textUnknownError];
			[self.scannedSubStatus setTextColor: [UIColor whiteColor]];
			break;
	}
}

// -------------------------------------------------------------------------------
// Отображает правильную иконку коннекта к серверу
// -------------------------------------------------------------------------------
-(void)serverConnectionStatus: (BOOL)сonnected
{
	if (сonnected) {
		UIImage *serverIcon = [UIImage imageNamed: @"serverActive"];
		[self.serverConnectionStatus setImage: serverIcon forState: UIControlStateNormal];
	} else {
		UIImage *serverIcon = [UIImage imageNamed: @"serverInactive"];
		[self.serverConnectionStatus setImage: serverIcon forState: UIControlStateNormal];
	}
}

// -------------------------------------------------------------------------------
// Готовим массив лога сканирований
// -------------------------------------------------------------------------------
- (void)prepareScanResultItems
{
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
}

// -------------------------------------------------------------------------------
// Добавляем результат сканирования в коллекцию результатов
// -------------------------------------------------------------------------------
- (void)addScanResultItem:(TCTLScanResultItem *)logItem
{
	if (!self.scanResultItems) {
		self.scanResultItems = [NSMutableArray init];
	} else if ([self.scanResultItems count] == NUMBER_OF_HISTORY_ITEMS) {
		[self.scanResultItems removeLastObject];
	}
	[self.scanResultItems insertObject: logItem atIndex: 0];
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
#ifdef DEBUG
	NSLog(@"onDefaultsChanged received");
#endif
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    _vibroStrength		= (NSInteger)[standardDefaults integerForKey: kVibroStrength];
	_scannerBeep		= [standardDefaults boolForKey: kScannerBeep];
	_disableAutolock	= [standardDefaults boolForKey: kDisableAutolock];
    _userGUID			= [standardDefaults objectForKey: kUserGUID];
    _resultDisplayTime	= (NSTimeInterval)[standardDefaults integerForKey:kResultDisplayTime];
	_serverURL			= [NSURL URLWithString:[standardDefaults objectForKey: kServerURL]];
    
	if ([self isScannerConnected]) {
		[self setScannerPreferences];
	}
}


// -------------------------------------------------------------------------------
//	Устанавливаем хардварные настройки сканера
// -------------------------------------------------------------------------------
- (void)setScannerPreferences
{
	// Устанавливаем настройки сканера из Settings Bundle
	[[MLScanner sharedInstance] beepSwitch: self.scannerBeep];
	[[MLScanner sharedInstance] vibraMotorStrength: (enum vibraMotorStrengthDef)self.vibroStrength];
#ifdef DEBUG
	NSLog(@"Sent settings to scanner: \n vibro: %ld \n beep: %ld", (long)self.vibroStrength, (long)self.scannerBeep);
#endif
}

#pragma mark - Server query methods

// -------------------------------------------------------------------------------
//	Проверяет отвечает ли сервер
// -------------------------------------------------------------------------------
- (void)invocateServerAliveCheck
{
	[[TCTLServerCommand sharedInstance] initWithServer:_serverURL withCommand: noOp withGUID: _userGUID withBarcode:@""];
	[[TCTLServerCommand sharedInstance] doSendCommand: self];
}

// -------------------------------------------------------------------------------
//	Инициирует запрос имени текущего устройства на сервере по GUID
// -------------------------------------------------------------------------------
- (void)invocateGetUserName
{
	[[TCTLServerCommand sharedInstance] initWithServer:_serverURL withCommand: getUserName withGUID: _userGUID withBarcode:@""];
	[[TCTLServerCommand sharedInstance] doSendCommand:self];
/*
	_serverResponse = [_serverCommand getServerResponse];
	switch (_serverResponse.responseCode) {
		case setActiveUser:
			[_userName setText: _serverResponse.userName];
			return YES;
			break;
			
		case setActiveUserNotFound:
		{
			[_userName setText: @"Неверный GUID"];
			
			// Отображаем сообщение об ошибке и просим пользователя отреагировать
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:textError message: textWrongGUID delegate:nil cancelButtonTitle:textCancel otherButtonTitles: nil];
			[alert show];

			break;
		}
		case errorNetworkError:
			[_userName setText: @""];
			break;
			
		default:
			[_userName setText: @""];
			
			// Отображаем сообщение об ошибке и просим пользователя отреагировать
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:textError message: textUnknownError delegate:nil cancelButtonTitle:textCancel otherButtonTitles: nil];
			[alert show];
			
			break;
	}
	return NO;
*/
}

@end
