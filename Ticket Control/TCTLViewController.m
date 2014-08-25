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
#import <xmlrpc.h>

@interface TCTLViewController ()

// Массив-история сосканированных кодов
@property (nonatomic) NSMutableArray	*scanResultItems;

// Объект-коммуникатор с сервером
@property (nonatomic) TCTLTicketServerQuery *serverQuery;

// Таймер, брасывающий статус в "Ожидание Проверки"
@property (nonatomic) NSTimer			*timer;

// Признак того, что система не готова сканировать следующий код
@property (nonatomic) BOOL				isBusy;

// Переменные в которые читаются настройки париложения из Settings Bundle
@property NSInteger						*vibroStrength;
@property BOOL							disableAutolock;
@property NSString						*userGUID;
@property NSInteger						*resultDisplayTime;
@property NSURL							*serverURL;

@end

@implementation TCTLViewController

#pragma mark - Actions:

// -------------------------------------------------------------------------------
// Инициируем сканирование штрих-кода
// -------------------------------------------------------------------------------
- (IBAction)tappedScan:(id)sender
{
    [[MLScanner sharedInstance] scan];
	[self doScannedBarcodeCheck: @"1234567890123"];
}

// -------------------------------------------------------------------------------
// Показывает tip с детальным статусом батареи саней
// -------------------------------------------------------------------------------
- (IBAction)sledShowSledBatDetails:(id)sender
{

// -------------------------------------------------------------------------------
// Показывает tip со статусом соединения с билетным сервером
// -------------------------------------------------------------------------------
}
- (IBAction)showServerConnectionInfo:(id)sender
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[[MLScanner sharedInstance] addAccessoryDidConnectNotification:self];
	[[MLScanner sharedInstance] addAccessoryDidDisconnectNotification:self];
	[[MLScanner sharedInstance] addReceiveCommandHandler:self];
	
	self.serverQuery = [TCTLTicketServerQuery alloc];
	// здесь нужно добавить проверку и фильтрацию истории сканирования
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NotificationHandler

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при подкдючении сканера
// -------------------------------------------------------------------------------
- (void)connectNotify
{
	// [self checkConnected];
	// [self performSelector:@selector(postponeBatteryRemain) withObject:nil afterDelay:0.8f];
}

// -------------------------------------------------------------------------------
// Вызывается Framework'ом при отключении сканера
// -------------------------------------------------------------------------------
- (void)disconnectNotify
{
	// [self checkConnected];
	// self.scannedBarcode = @"";
}

#pragma mark - ReceiveCommandHandler

- (BOOL)isHandler:(NSObject <ReceiveCommandProtocol> *)command
{
	if ([command isKindOfClass:[ReceiveCommand class]]) {
		return TRUE;
	}
	
	return FALSE;
}

- (void)handleRequest:(NSObject <ReceiveCommandProtocol> *)command
{
	[self doScannedBarcodeCheck: [command receiveString]];
}

- (void)handleInformationUpdate
{
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
	TCTLScanResultItem *result = [[TCTLScanResultItem alloc] init];
	result.resultCode = accessDeniedAlreadyPassed;
	[self displayScanResult: result];
	[self runTimer];
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

- (BOOL)isScannerOnCharge // Заряжается ли сканер в данный момент
{
	return [[MLScanner sharedInstance] batteryOnCharge];
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
	self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(displayReadyToScan:) userInfo:nil repeats:NO];
}

// -------------------------------------------------------------------------------
// Запускает начальную проверку заряда сканера с задержкой
// -------------------------------------------------------------------------------
- (void)postponeBatteryRemain
{
	// get battery info
	[[MLScanner sharedInstance] batteryRemain];
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
- (void)displayScanResult: (TCTLScanResultItem *)scanResult
{
	switch (scanResult.resultCode) {
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
}

// -------------------------------------------------------------------------------
//	viewWillDisappear:
// -------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
    // Stop listening for the NSUserDefaultsDidChangeNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
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
	self.disableAutolock	= [standardDefaults boolForKey: kDisableAutolock];
    self.userGUID			= [standardDefaults objectForKey: kUserGUID];
    self.resultDisplayTime	= (NSInteger *)[standardDefaults integerForKey:kResultDisplayTime];
	self.serverURL			= [standardDefaults objectForKey: kServerURL];
    
	NSLog(@"Settings has changed:");
	NSLog(@"Vibro: %ld", (long)self.vibroStrength);
	NSLog(@"Autolock: %hhd", self.disableAutolock);
	NSLog(@"GUID: %@", self.userGUID);
	NSLog(@"Timer: %lds", (long)self.resultDisplayTime);
	NSLog(@"URL: %@s", self.serverURL);
	
    // [self.tableView reloadData];
}

#pragma mark - Server query methods

- (BOOL) isServerAlive
{
	return YES;
};

- (TCTLServerQueryResponse *)	 checkBarcode: (NSString *)barcode
{
	TCTLServerQueryResponse *response = [[TCTLServerQueryResponse alloc] init];
	[response setResponseCode: accessAllowed];
	return response;
};

- (NSString *) getUserName
{
	return @"Контроллёр 1";
};

- (TCTLServerQueryResponse *) sendCommand: (ServerCommand) command
{
	TCTLServerQueryResponse *response = [[TCTLServerQueryResponse alloc] init];
	[response setResponseCode: resultOk];
	return response;
};


@end
