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
@import AudioToolbox;

@interface TCTLViewController ()

// Признак того, что система не готова сканировать следующий код. Если YES, то система будет игнорировать все сканирования
@property (nonatomic) BOOL				isAppBusy;

// Признак того, что сервер подключён
@property (nonatomic) BOOL				isServerConnected;

// Переменные в которые читаются настройки париложения из Settings Bundle
@property (nonatomic) NSInteger			vibroStrength;
@property (nonatomic) BOOL				disableAutolock;
@property (nonatomic, copy) NSString	*userGUID;
@property (nonatomic) NSTimeInterval	resultDisplayTime;
@property (nonatomic, strong) NSURL		*serverURL;
@property (nonatomic) BOOL				scannerBeep;

// Служебные переменные
@property (nonatomic) BOOL				isUserNameSet;
@property (nonatomic) BOOL				isUpsideDown;
@property (nonatomic, copy) NSString 	*lastScannedBarcode;
@property (nonatomic) UIAlertView		*warningAlert;
@property (nonatomic) UIAlertView		*manualBarcodeAlert;
@property (assign) SystemSoundID		deniedSound;
@property (assign) SystemSoundID		allowedSound;

@end

@implementation TCTLViewController

#pragma mark - Actions:

// -------------------------------------------------------------------------------
// Invocating the barcode scan via the framework
// -------------------------------------------------------------------------------
- (IBAction)tappedScan:(id)sender
{
#ifdef DEBUG
	NSLog(@"tappedScan received");
#endif

    // Если система не занята, то запускаем сканирование
	if (!_isAppBusy) {
		[[MLScanner sharedInstance] scan];

#if TARGET_IPHONE_SIMULATOR
		[self doScannedBarcodeCheck: @"1234567890123"];
#elif TEST_IPOD_WITHOUT_SCANNER == 1
		[self doScannedBarcodeCheck: @"1234567890123"];
#endif
	}
}

// -------------------------------------------------------------------------------
// Displaying the screen to enter the barcode manually
// -------------------------------------------------------------------------------
- (IBAction)numKeypadTapped:(id)sender
{
	if (!_isAppBusy) {
		self.isAppBusy = YES;
		_manualBarcodeAlert = [[UIAlertView alloc] initWithTitle:@"Введите штрих-код"
														 message:@""
														delegate:self
											   cancelButtonTitle:@"Готово"
											   otherButtonTitles:nil];
		[_manualBarcodeAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
		[[_manualBarcodeAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
		[_manualBarcodeAlert show];
	}
}

// -------------------------------------------------------------------------------
// Displaying the alert with a battery status
// -------------------------------------------------------------------------------
- (IBAction)showScannerBatDetails:(id)sender
{
#ifdef DEBUG
	NSLog(@"showScannerBatDetails received");
#endif
	
	// Updating accessory info as per framework manual
	[[MLScanner sharedInstance] updateAccessoryInfo];
	NSString *message;
	if ([self isScannerConnected]) {
		if ([self isScannerOnCharge]) {
			message = @"Батарея сканера заряжается";
		} else {
#ifdef DEBUG
			message = [@"Заряд батареи сканнера: " stringByAppendingFormat: @"%@%% (%dv, %dm, %d%%)", [self getScannerBatRemain], [[MLScanner sharedInstance] powerRemainInmV], [[MLScanner sharedInstance] powerRemainInMin], [[MLScanner sharedInstance] powerRemainPercent]];
#else
			message = [@"Заряд батареи сканнера: " stringByAppendingFormat: @"%@%%", [self getScannerBatRemain]];
#endif
		}
	} else {
		message = @"Сканнер не подключен";

	}
	self.warningAlert = [[UIAlertView alloc] initWithTitle:@"Информация"
												   message:message
												  delegate:self
										 cancelButtonTitle:@"Ok"
										 otherButtonTitles:nil];
	[self.warningAlert show];
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
	if (self.isServerConnected) {
		message = @"Соединение с сервером установлено";
	} else {
		message = @"Нет соединения с сервером";
	}
	 self.warningAlert = [[UIAlertView alloc] initWithTitle:@"Информация"
													message:message
												   delegate:self
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[self.warningAlert show];
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
		[view removeFromSuperview];
		[window addSubview:view];
	} else {
		self.isUpsideDown = YES;
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		UIView *view = [window.subviews objectAtIndex:0];
		[view removeFromSuperview];
		[window addSubview:view];
	}
}

// -------------------------------------------------------------------------------
// Метод вызывается перед сегами и не даёт переходить в историю, если приложение занято
// -------------------------------------------------------------------------------
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if (([identifier isEqual: @"logTableSegue"]) && (!self.isAppBusy)) {
		return YES;
	} else {
		return NO;
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
		[self setIsAppBusy: YES];
		
		// Передаем в контроллер таблицы данные лога
		if ([[segue.destinationViewController topViewController] isKindOfClass:[TCTLLogTableViewController class]]) {
			TCTLLogTableViewController *tableView = (TCTLLogTableViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
			tableView.scanResultItems = self.scanResultItems;
		}
	} 
}

// -------------------------------------------------------------------------------
// Возвращает на главный экран
// -------------------------------------------------------------------------------
- (IBAction)unwindToMainScreen:(UIStoryboardSegue *)segue
{
#ifdef DEBUG
	NSLog(@"unwindToMainScreen received.");
#endif
	self.isAppBusy = NO;
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
	self.isUpsideDown = NO;
	
	[[MLScanner sharedInstance] addAccessoryDidConnectNotification:self];
	[[MLScanner sharedInstance] addAccessoryDidDisconnectNotification:self];
	[[MLScanner sharedInstance] addReceiveCommandHandler:self];
	
	// Preparing sound resources
	NSURL *deniedURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"denied"
																			  ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)deniedURL, &_deniedSound);
	
	NSURL *allowedURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"allowed"
																			   ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)allowedURL, &_allowedSound);

	
	// Готовим лог ответов от сервера
	[self prepareScanResultItems];
	
	// по умолчанию считаем, что связи нет
	[self serverConnectionStatus: NO];
	
	// Устанавливаем имя пользователя на главном экране в значение имени текущего девайса
	self.userNameLabel.text = [UIDevice currentDevice].name;
	self.isUserNameSet = NO;
		
	// Проверка подключения сканера и отображение статуса
	if ([self isScannerConnected]) {
		self.isAppBusy = NO;
		[self displayReadyToScan];
	} else {
		self.isAppBusy = YES;
		[self displayNotReady];
	}
	
	// Load our preferences.  Preloading the relevant preferences here will
	// prevent possible diskIO latency from stalling our code in more time
	// critical areas, such as tableView:cellForRowAtIndexPath:, where the
	// values associated with these preferences are actually needed.
	[self performSelector:@selector(onDefaultsChanged:)
			   withObject:self
			   afterDelay:1.0];
	// [self onDefaultsChanged:nil];
	
	// Begin listening for changes to our preferences when the Settings app does
	// so, when we are resumed from the backround, this will give us a chance to
	// update our UI
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];

	// Setting up the right icon for scanner hardware connection
	if (self.isScannerConnected) {
		[self performSelector:@selector(postponeBatteryRemain)
				   withObject:self
				   afterDelay:2.0f];
#if TARGET_IPHONE_SIMULATOR
		[self setBatteryRemainIcon];
#elif TEST_IPOD_WITHOUT_SCANNER == 1
		[self setBatteryRemainIcon];
#endif
	} else {
		[self setBatteryRemainIcon];
	}
	
#ifdef DEBUG
	[self.scannerBatStatusIcon setUserInteractionEnabled:YES];
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
	[super viewDidAppear:animated];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSUserDefaultsDidChangeNotification
												  object:nil];
	[super viewWillDisappear:animated];
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
// Being called-back by the framework after the scanner connection
// -------------------------------------------------------------------------------
- (void)connectNotify
{
#ifdef DEBUG
	NSLog(@"connectNotify received");
#endif
	// Показываем статус готовности к сканированию
	self.isAppBusy = NO;
	[self displayReadyToScan];
	
	// Инициируем опрос заряда батареи
	[self performSelector:@selector(postponeBatteryRemain)
			   withObject:nil
			   afterDelay:0.8f];
	
	// Устанавливаем настройки сканера с задержкой в 1 сек
	[self performSelector:@selector(setScannerPreferences)
			   withObject:nil
			   afterDelay:0.5f];
	
	// Планируем проверку связи с сервером
	[self performSelector:@selector(invocateGetUserName)
			   withObject:nil
			   afterDelay:1.0f];
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
	self.isAppBusy = YES;
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
	if (!self.isAppBusy) {
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

#pragma mark - Server response handlers

// ------------------------------------------------------------------------------
// This is how we handle the success response from JSON-RPC
// ------------------------------------------------------------------------------
- (void)handleSuccessResponse:(id)responseObject
{
	// If the server response is ok, than...
	TCTLServerResponse *serverResponse = [[TCTLServerCommand sharedInstance] unpackResponse:responseObject];
	
	if (serverResponse) {
	// Handling possible server responses
		switch (serverResponse.responseCode) {
			case resultOk:
				[self displayReadyToScan];
				self.isAppBusy = NO;
				break;
				
			case setActiveUser:
				self.userNameLabel.text = serverResponse.userName;
				self.isUserNameSet = YES;
				self.isAppBusy = NO;
				break;
				
			case setActiveUserNotFound:
				self.isUserNameSet = NO;
				
				// Setting the user name on the main view to a current device's name
				self.userNameLabel.text = [UIDevice currentDevice].name;
				
				// Showing alert
				self.warningAlert = [[UIAlertView alloc]initWithTitle:@"Ошибка"
															  message:@"Неверный GUID! Обратитесь к администратору системы"
															 delegate:self
													cancelButtonTitle:@"Отмена"
													otherButtonTitles:nil];
				[self.warningAlert show];
				[self displayReadyToScan];
				break;
				
			case setActiveEvent:
	#warning Пока не реализовано
				self.isAppBusy = NO;
				break;
				
			case setActiveEventNotFound:
	#warning Пока не реализовано
				self.isAppBusy = NO;
				break;
				
			case accessAllowed ... accessDeniedUnknownError:
			{
				// Checking if the barcode matches to what we've sent
				if ([serverResponse.barcode isEqualToString: self.lastScannedBarcode]) {
					
					// Showing the result
					[self displayScanResult: serverResponse];
					
					// Запускаем таймер, по окончании которого снова отображается "Ожидание Проверки"
					[self runStatusRevertTimer];
					
					// Упаковываем результат сканирования в формат лога
					TCTLScanResultItem *logItem = [[TCTLScanResultItem alloc] initItemWithBarcode:serverResponse.barcode
																					 FillTextWith:serverResponse];
					// Adding NSDictionary parsed from JSON response to logItem
					logItem.serverParsedResponse = [(NSDictionary *)responseObject objectForKey:@"params"];
					
					// Adding logItem to log table
					[self addScanResultItemToLog:logItem];
					
					// Displaying the logItem in the lower part of the screen
					[self displayLogResultItem:logItem];
					self.isAppBusy = NO;
				} else {
					// Если штрих-код в запросе и ответе не совпадают - показываем алерт
					self.warningAlert = [[UIAlertView alloc]initWithTitle:@"Ошибка"
																  message:@"Неверный ответ сервера"
																 delegate:self
														cancelButtonTitle:@"Повторить"
														otherButtonTitles:nil];
					[self.warningAlert show];
					[self displayReadyToScan];
				}
				break;
			}
				
			case errorNetworkError ... errorServerResponseUnkown:
				
			default:
				// Показываем алерт
				self.warningAlert = [[UIAlertView alloc]initWithTitle:@"Ошибка"
															  message:@"Неизвестный ответ сервера"
															 delegate:self
													cancelButtonTitle:@"Повторить"
													otherButtonTitles:nil];
				[self.warningAlert show];
				[self displayReadyToScan];
				
				break;
		}
	} else {
		// Показываем алерт
		self.warningAlert = [[UIAlertView alloc]initWithTitle:@"Ошибка"
													  message:@"Нет кода ответа сервера"
													 delegate:self
											cancelButtonTitle:@"Повторить"
											otherButtonTitles:nil];
		[self.warningAlert show];
		[self displayReadyToScan];
	}
	[self serverConnectionStatus:YES];
}

// ------------------------------------------------------------------------------
// This is how we handle the failure response from JSON-RPC
// ------------------------------------------------------------------------------
- (void)handleFailureResponse:(NSError *)error
{
	// Показываем алерт
	NSString *message = @"Ошибка соединения с сервером";
	
	switch (error.code) {
		case 0:
			message = [message stringByAppendingFormat:@"\nНеверный ответ сервера"];
			break;
		case NSURLErrorBadURL:
			message = [message stringByAppendingFormat:@"\nНеверный URL сервера"];
			break;
		case NSURLErrorTimedOut:
			message = [message stringByAppendingFormat:@"\nПревышено время ожидания"];
			break;
		case NSURLErrorUnsupportedURL:
			message = [message stringByAppendingFormat:@"\nОшибка в URL сервера"];
			break;
		case NSURLErrorCannotFindHost:
			message = [message stringByAppendingFormat:@"\nНеверный URL сервера"];
			break;
		case NSURLErrorCannotConnectToHost:
			message = [message stringByAppendingFormat:@"\nНе могу соединиться с сервером"];
			break;
		case NSURLErrorNetworkConnectionLost:
			message = [message stringByAppendingFormat:@"\nСетевое соединение потеряно"];
			break;
		case NSURLErrorDNSLookupFailed:
			message = [message stringByAppendingFormat:@"\nОшибка DNS"];
			break;
		case NSURLErrorHTTPTooManyRedirects:
			message = [message stringByAppendingFormat:@"\nСлишком много редиректов"];
			break;
		case NSURLErrorCannotParseResponse ... NSURLErrorCannotDecodeRawData:
			message = [message stringByAppendingFormat:@"\nНеверный формат ответа"];
			break;
		case NSURLErrorNotConnectedToInternet:
			message = [message stringByAppendingFormat:@"\nПроверьте сетевое соединение"];
			break;
		case NSURLErrorDataLengthExceedsMaximum:
			message = [message stringByAppendingFormat:@"\nПревышен максимальный размер данных"];
			break;
		case NSURLErrorClientCertificateRequired ... NSURLErrorSecureConnectionFailed:
			message = [message stringByAppendingFormat:@"\nОшибка безопасности (SSL)"];
			break;
		default:
			message = [message stringByAppendingFormat:@"\n%@ ошибка %li", error.domain, (long)error.code];
	}

	self.warningAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
												   message:message
												  delegate:self
										 cancelButtonTitle:@"Повторить"
										 otherButtonTitles:nil];
	[self.warningAlert show];
	
	self.isAppBusy = NO;
	[self displayReadyToScan];
	
	// Displaying the server connection fail
	[self serverConnectionStatus:NO];
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
	// Удаляем из строки возврат каретки
	barcode = [barcode stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	// Запоминаем последний код
	self.lastScannedBarcode = barcode;
	
	// Устанавливаем статус приложения
	self.isAppBusy = YES;
	[self displayProgress];
	
#if TEST_IPOD_WITHOUT_SCANNER == 1
	TCTLServerResponse *item = [TCTLServerResponse new];
	item.barcode = self.lastScannedBarcode;
	item.responseCode = accessAllowed;

	TCTLScanResultItem *logItem = [[TCTLScanResultItem alloc] initItemWithBarcode:self.lastScannedBarcode
																	 FillTextWith:item];
	logItem.serverParsedResponse = @{@"GUID": @"123",
									 @"ResponseCode": @"0x210",
									 @"TimeChecked": @"20140809T14:00:00",
									 };
	
	[self addScanResultItemToLog:logItem];
	[self displayScanResult: item];
	self.isAppBusy = NO;
	[self runStatusRevertTimer];
#else
	
	// Опрашиваем сервер и ждём ответ
	[[TCTLServerCommand sharedInstance] prepareWithServer:_serverURL
										   withCommand: getCodeResult
											  withGUID:_userGUID
										   withBarcode: barcode];
	// we're working JSON-RPC all the work should be done here inside the blocks
	[[TCTLServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
																	[self handleSuccessResponse:responseObject];
																}
																 failure:^(NSError *error) {
																	 [self handleFailureResponse:error];
																 }];
#endif
}

// -------------------------------------------------------------------------------
// Проверяем подключен ли сканер
// -------------------------------------------------------------------------------
- (BOOL)isScannerConnected
{
	BOOL connected;
#if TARGET_IPHONE_SIMULATOR
	connected = YES;
#elif TEST_IPOD_WITHOUT_SCANNER == 1
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
- (void)runStatusRevertTimer
{
	static  NSTimer	*timer;
	
	if (timer != nil) {
		[timer invalidate];
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:self.resultDisplayTime
											 target:self
										   selector:@selector(displayReadyToScan)
										   userInfo:nil
											repeats:NO];
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
-(void)setIsAppBusy: (BOOL)yes
{
	static  NSTimer	*timer;
	if (timer) {
		[timer invalidate];
	}
	
	if (yes) {
		_isAppBusy = YES;
		self.scanButton.enabled = NO;
		/* Not needed so far...
		// Запускаем таймер на 15 сек, по истечении отменяем статус занятости
		timer = [NSTimer scheduledTimerWithTimeInterval:XMLRPC_TIMEOUT
												 target:self
											   selector:@selector(cancelAppBusyStatus)
											   userInfo:nil
												repeats:NO]; */
	} else {
		_isAppBusy = NO;
		self.scanButton.enabled = YES;
	}

#ifdef DEBUG
	NSLog(@"setAppBusyStatus received: %hhd", yes);
#endif
}

// -------------------------------------------------------------------------------
// Отменяет статус занятости, после таймаута
// -------------------------------------------------------------------------------
- (void)cancelAppBusyStatus
{
#ifdef DEBUG
	NSLog(@"cancelAppBusyStatus received");
#endif
	self.isAppBusy = NO;
	[self displayReadyToScan];
}

// -------------------------------------------------------------------------------
// Отображает экран "Не Готов"
// -------------------------------------------------------------------------------
- (void)displayNotReady
{
	self.background.backgroundColor = [UIColor lightGrayColor];
	self.scannedStatus.text = @"НЕ ГОТОВ";
	self.scannedStatus.textColor = [UIColor darkGrayColor];
	self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: NO];
}

// -------------------------------------------------------------------------------
// Отображает начальный экран "Ожидание Проверки"
// -------------------------------------------------------------------------------
- (void)displayReadyToScan
{
	self.background.backgroundColor = [UIColor colorWithRed:0.92f
													  green:0.92f
													   blue:0.92f
													  alpha:1.0f];
	self.scannedStatus.text = @"ОЖИДАНИЕ ПРОВЕРКИ";
	self.scannedStatus.textColor = [UIColor lightGrayColor];
	self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: NO];
}

// -------------------------------------------------------------------------------
// Отображает экран "Поиск Билета"
// -------------------------------------------------------------------------------
- (void)displayProgress
{
	self.background.backgroundColor = [UIColor lightGrayColor];
	self.scannedStatus.text = @"ПОИСК БИЛЕТА";
	self.scannedStatus.textColor = [UIColor darkGrayColor];
	self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: YES];
}

// -------------------------------------------------------------------------------
// Отображает статус в зависимости от результата
// -------------------------------------------------------------------------------
- (void)displayScanResult: (TCTLServerResponse *)scanResult
{
	[self showWaitingSign: NO];
	switch (scanResult.responseCode) {
		case accessAllowed: {
			self.background.backgroundColor = [UIColor greenColor];
			self.scannedStatus.alpha = 0;
			self.scannedStatus.text = @"ДОСТУП РАЗРЕШЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.textColor = [UIColor clearColor];
			
			[self doAllowedStatusAnimation];

			break;
		}
		case accessDeniedTicketNotFound:
			self.background.backgroundColor = [UIColor redColor];
			self.scannedStatus.text = @"ДОСТУП ЗАПРЕЩЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.text = @"БИЛЕТА НЕТ В БАЗЕ";
			self.scannedSubStatus.textColor = [UIColor whiteColor];
			
			[self doDeniedStatusAnimation];
			
			break;
			
		case accessDeniedAlreadyPassed:
			self.background.backgroundColor = [UIColor redColor];
			self.scannedStatus.text = @"ДОСТУП ЗАПРЕЩЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.text = @"БИЛЕТ УЖЕ ПРОХОДИЛ";
			self.scannedSubStatus.textColor = [UIColor whiteColor];
			
			[self doDeniedStatusAnimation];
			
			break;
			
		case accessDeniedWrongEntrance:
			self.background.backgroundColor = [UIColor redColor];
			self.scannedStatus.text = @"ДОСТУП ЗАПРЕЩЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.text = @"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД";
			self.scannedSubStatus.textColor = [UIColor whiteColor];
			
			[self doDeniedStatusAnimation];
			
			break;
			
		case accessDeniedNoActiveEvent:
			self.background.backgroundColor = [UIColor redColor];
			self.scannedStatus.text = @"ДОСТУП ЗАПРЕЩЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.text = @"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ";
			self.scannedSubStatus.textColor = [UIColor whiteColor];
			
			[self doDeniedStatusAnimation];
			
			break;
			
		default:
			self.background.backgroundColor = [UIColor redColor];
			self.scannedStatus.text = @"ДОСТУП ЗАПРЕЩЁН";
			self.scannedStatus.textColor = [UIColor whiteColor];
			self.scannedSubStatus.text = @"НЕИЗВЕСТНАЯ ОШИБКА";
			self.scannedSubStatus.textColor = [UIColor whiteColor];
			
			[self doDeniedStatusAnimation];
			
			break;
	}
}

// -------------------------------------------------------------------------------
// Отображает правильную иконку коннекта к серверу
// -------------------------------------------------------------------------------
- (void)serverConnectionStatus: (BOOL)сonnected
{
	if (сonnected) {
		UIImage *serverIcon = [UIImage imageNamed: @"serverActive"];
		[self.serverConnectionStatus setImage: serverIcon
									 forState: UIControlStateNormal];
	} else {
		UIImage *serverIcon = [UIImage imageNamed: @"serverInactive"];
		[self.serverConnectionStatus setImage: serverIcon
									 forState: UIControlStateNormal];
	}
}

// -------------------------------------------------------------------------------
// Готовим массив лога сканирований
// -------------------------------------------------------------------------------
- (void)prepareScanResultItems
{
	// фильтрация истории сканирования
	if (self.scanResultItems) {
		for (TCTLScanResultItem *logItem in self.scanResultItems) {
			// если записи в логе больше 24 часов удаляем её
			if ([logItem.locallyCheckedTime compare: [[NSDate date] dateByAddingTimeInterval: -24*60*60]] == NSOrderedAscending) {
				[self.scanResultItems removeObject: logItem];
			}
		}
	} else {
		// если лога нет, то создаём пустой
		self.scanResultItems = [NSMutableArray new];
	}
}

// -------------------------------------------------------------------------------
// Добавляем результат сканирования в коллекцию результатов
// -------------------------------------------------------------------------------
- (void)addScanResultItemToLog:(TCTLScanResultItem *)logItem
{
	if (!self.scanResultItems) {
		self.scanResultItems = [NSMutableArray new];
	} else if ([self.scanResultItems count] == NUMBER_OF_HISTORY_ITEMS) {
		[self.scanResultItems removeLastObject];
	}
	[self.scanResultItems insertObject: logItem atIndex: 0];
}

// -------------------------------------------------------------------------------
// Отображаем внизу экрана статус последнего сканирования
// -------------------------------------------------------------------------------
- (void)displayLogResultItem:(TCTLScanResultItem *)logItem
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	[dateFormatter setDateStyle: NSDateFormatterNoStyle];
	
	NSString *title = [dateFormatter stringFromDate: logItem.locallyCheckedTime];
	title = [title stringByAppendingFormat: @" Билет %@", logItem.barcode];
	
	// Анимируем смену строчек лога
	[UIView animateWithDuration:0.2
						  delay:0.05
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.lastTicketNumberLabel.alpha = 0.5;
						 self.lastTicketNumberLabel.transform = CGAffineTransformMakeTranslation(0, 60);
					 }
					 completion:^(BOOL finished){
						 // Обновляем содержимое
						 self.lastTicketNumberLabel.text = title;

						 self.lastTicketNumberLabel.transform = CGAffineTransformMakeTranslation(-200, 0);
						 self.lastTicketNumberLabel.alpha = 1;
						 [UIView animateWithDuration:0.25
											   delay:0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  self.lastTicketNumberLabel.alpha = 1;
											  self.lastTicketNumberLabel.transform = CGAffineTransformMakeTranslation(0, 0);
										  }
										  completion:nil];
					 }];
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.lastTicketStatusLabel.transform = CGAffineTransformMakeTranslation(0, 80);
						 self.lastTicketStatusLabel.alpha = 0.5;
					 }
					 completion:^(BOOL finished){
						 // Обновляем содержимое
						 self.lastTicketStatusLabel.text = logItem.resultText;
						 if (logItem.allowedAccess) {
							 self.lastTicketStatusLabel.textColor = [UIColor greenColor];
						 } else {
							 self.lastTicketStatusLabel.textColor = [UIColor redColor];
						 }

						 self.lastTicketStatusLabel.transform = CGAffineTransformMakeTranslation(-250, 0);
						 self.lastTicketStatusLabel.alpha = 1;
						 
						 [UIView animateWithDuration:0.25
											   delay:0.15
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  self.lastTicketStatusLabel.transform = CGAffineTransformMakeTranslation(0, 0);
											  self.lastTicketStatusLabel.alpha = 1;
										  }
										  completion:nil];
					 }];
}

// -------------------------------------------------------------------------------
//	Анимируем появление нового статуса разрешения
// -------------------------------------------------------------------------------
-(void)doAllowedStatusAnimation
{
	// Playing the system Allowed sound
	AudioServicesPlaySystemSound(self.allowedSound);
	
	self.scannedStatus.alpha = 0;
	self.scannedStatus.transform = CGAffineTransformMakeScale(1.3, 1.3);
	[UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.scannedStatus.alpha = 0.8;
					 } completion:^(BOOL finished) {
						 [UIView animateWithDuration:0.15
											   delay:0
											 options:UIViewAnimationOptionCurveEaseInOut
										  animations:^{
											  self.scannedStatus.transform = CGAffineTransformMakeScale(1, 1);
											  self.scannedStatus.alpha = 1;
										  }
										  completion:nil];
					 }];
}

// -------------------------------------------------------------------------------
//	Анимируем появление нового статуса запрещения
// -------------------------------------------------------------------------------
-(void)doDeniedStatusAnimation
{
	// Playing the system Denied sound
	AudioServicesPlaySystemSound(self.deniedSound);
	
	// Animatiting the lables
	[UIView animateWithDuration:0.08
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.scannedStatus.transform = CGAffineTransformMakeTranslation(25, 0);
						 self.scannedSubStatus.transform = CGAffineTransformMakeTranslation(25, 0);
					 } completion:^(BOOL finished) {
						 [UIView animateWithDuration:0.06
											   delay:0
											 options:UIViewAnimationOptionCurveEaseInOut
										  animations:^{
											  self.scannedStatus.transform = CGAffineTransformMakeTranslation(-16, 0);
											  self.scannedSubStatus.transform = CGAffineTransformMakeTranslation(-16, 0);
										  }
										  completion:^(BOOL finished){
											  [UIView animateWithDuration:0.04
																	delay:0
																  options:UIViewAnimationOptionCurveEaseInOut
															   animations:^{
																   self.scannedStatus.transform = CGAffineTransformMakeTranslation(0, 0);
																   self.scannedSubStatus.transform = CGAffineTransformMakeTranslation(0, 0);
															   }
															   completion:nil];
										  }];
					 }];

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
    
    self.vibroStrength		= (NSInteger)[standardDefaults integerForKey: VIBRO_STRENGTH_S];
	self.scannerBeep		= [standardDefaults boolForKey: SCANNER_BEEP_S];
	self.disableAutolock	= [standardDefaults boolForKey: DISABLE_AUTOLOCK_S];
    self.userGUID			= [standardDefaults objectForKey: USER_GUID_S];
    self.resultDisplayTime	= (NSTimeInterval)[standardDefaults integerForKey:RESULT_DISPLAY_TIME_S];
	self.serverURL			= [NSURL URLWithString:[standardDefaults objectForKey: SERVER_URL_S]];
    
	if ([self isScannerConnected]) {
		[self setScannerPreferences];
	}
	
	if (self.disableAutolock) {
		[UIApplication sharedApplication].idleTimerDisabled = YES;
	} else {
		[UIApplication sharedApplication].idleTimerDisabled = NO;
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
	[[TCTLServerCommand sharedInstance] prepareWithServer:self.serverURL
											  withCommand:noOp
												 withGUID:self.userGUID
											  withBarcode:@""];
	
	[[TCTLServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
																	[self handleSuccessResponse:responseObject];
																}
																 failure:^(NSError *error) {
																	 [self handleFailureResponse:error];
																 }];
}

// -------------------------------------------------------------------------------
//	Инициирует запрос имени текущего устройства на сервере по GUID
// -------------------------------------------------------------------------------
- (void)invocateGetUserName
{
	[[TCTLServerCommand sharedInstance] prepareWithServer:self.serverURL
											  withCommand:getUserName
												 withGUID:self.userGUID
											  withBarcode:@""];

	[[TCTLServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
																	[self handleSuccessResponse:responseObject];
																}
																 failure:^(NSError *error) {
																	 [self handleFailureResponse:error];
																 }];
}

#pragma mark - Other delegates
// -------------------------------------------------------------------------------
//	Sent to the delegate when the user clicks a button on an alert view
// -------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

// -------------------------------------------------------------------------------
//	Sent to the delegate after an alert view is dismissed from the screen
// -------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#ifdef DEBUG
	NSLog(@"didDismissWithButtonIndex received");
#endif
	self.isAppBusy = NO;
	
	if ((alertView == self.manualBarcodeAlert) && ([[alertView textFieldAtIndex:0].text length] > 0)) {
		[self doScannedBarcodeCheck:[alertView textFieldAtIndex:0].text];
	}
}
@end
