//
//  VTKScanViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKConstants.h"
#import "VTKScannerManager.h"
#import "VTKSettings.h"
#import "VTKScanViewController.h"
#import "VTKScanResultItem.h"
#import "VTKValidatorResponse.h"
#import "VTKServerCommand.h"
#import "VTKLogTableViewController.h"
#import "VTKBarcodeScanner.h"
#import "VTKServerAPI.h"
@import AudioToolbox;

@interface VTKScanViewController ()

/**
 *  Признак того, что система не готова сканировать следующий код. Если YES, то система будет игнорировать все сканирования
 */
@property (nonatomic) BOOL notReadyToScan;

/**
 *  Признак того, что сервер подключён
 */
@property (nonatomic) BOOL isServerConnected;

// View outlets
@property (nonatomic, weak) IBOutlet UIView		*mainView;
@property (nonatomic, weak) IBOutlet UILabel    *scannedStatus;
@property (nonatomic, weak) IBOutlet UILabel    *scannedSubStatus;
@property (nonatomic, weak) IBOutlet UILabel	*lastTicketNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel	*lastTicketStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton	*numKeypad;
@property (nonatomic, weak) IBOutlet UIView		*background;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView	*waitSign;

@property (nonatomic) BOOL serverConnectionStatus;

// Служебные переменные
@property (nonatomic) BOOL				isUserNameSet;
@property (nonatomic) BOOL				isUpsideDown;
@property (nonatomic, copy) NSString 	*lastScannedBarcode;
@property (nonatomic, strong) UIAlertView *warningAlert;
@property (nonatomic, strong) UIAlertView *manualBarcodeAlert;
@property (assign) SystemSoundID		deniedSound;
@property (assign) SystemSoundID		allowedSound;
@property (nonatomic, weak) VTKScannerManager *scanner;
@property (nonatomic, weak) VTKSettings *settings;

@end

@implementation VTKScanViewController

#pragma mark - Actions:

/**
 *  Invocates barcode scan via the scanner framework
 *
 *  @param sender the object that trigerred the action
 */
- (IBAction)tappedScan:(id)sender
{
    // Если система не занята, то запускаем сканирование
	if (!self.notReadyToScan) {
        [[VTKScannerManager sharedInstance].scanner invocateBarcodeScan];

#if TARGET_IPHONE_SIMULATOR
		[self doScannedBarcodeCheck: @"1234567890123"];
#elif TEST_IPOD_WITHOUT_SCANNER == 1
		[self doScannedBarcodeCheck: @"1234567890123"];
#endif
	}
}

/**
 *  Displaying the alert box to enter the barcode manually
 *
 *  @param sender the object that trigerred the action
 */
- (IBAction)numKeypadTapped:(id)sender
{
	if (!self.notReadyToScan) {
		self.notReadyToScan = YES;

		self.manualBarcodeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите штрих-код", @"Текст в диалоговом окне ввода штрихкода вручную")
															 message:@""
															delegate:self
												   cancelButtonTitle:NSLocalizedString(@"Готово", @"Кнопка Готово")
												   otherButtonTitles:nil];
		self.manualBarcodeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
		UITextField *barcodeField	= [self.manualBarcodeAlert textFieldAtIndex:0];
		barcodeField.keyboardType	= UIKeyboardTypeNumberPad;
		barcodeField.placeholder	= @"1234567890123";
		barcodeField.font			= [UIFont systemFontOfSize:22];
		[self.manualBarcodeAlert show];
	}
}

/**
 *  Displaying the alert with a battery status
 *
 *  @param sender the object that trigerred the action
 */
- (IBAction)showScannerBatDetails:(id)sender
{
    id <VTKBarcodeScanner> scanner = [VTKScannerManager sharedInstance].scanner;
#ifdef DEBUG
	NSLog(@"showScannerBatDetails received");
#endif
	
	// Updating accessory info as per Mobilogics framework manual
	[scanner updateAccessoryInfo];
	NSString *message;
	if ([self isScannerConnected]) {
		if ([self isScannerOnCharge]) {
			message = NSLocalizedString(@"Батарея сканера заряжается", @"Сообщение в алерте");
		} else {
			message = [NSLocalizedString(@"Заряд батареи сканнера: ", @"Сообщение в алерте") stringByAppendingFormat: @"%@%%", [self getScannerBatRemain]];
		}
	} else {
		message = NSLocalizedString(@"Сканнер не подключен", @"Сообщение в алерте");
	}
	self.warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Информация", @"Заголовок алерта")
												   message:message
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Ok", @"Кнопка Ок")
										 otherButtonTitles:nil];
	[self.warningAlert show];
    [scanner chargeBatteryFromScanner];
}

/**
 *  Shows an alert with ticket server connection status
 *
 *  @param sender the object that trigerred the action
 */
- (IBAction)showServerConnectionInfo:(id)sender
{
	NSString *message;
	if (self.isServerConnected) {
		message = NSLocalizedString(@"Соединение с сервером установлено", @"Сообщение в алерте");
	} else {
		message = NSLocalizedString(@"Нет соединения с сервером", @"Сообщение в алерте");
	}
	 self.warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Информация", @"Заголовок алерта")
													message:message
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Ok", @"Кнопка Ок")
										  otherButtonTitles:nil];
	[self.warningAlert show];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"logTableSegue" sender:self];
}

/**
 *  @inheritdoc
 */
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if (([identifier isEqual: @"logTableSegue"]) && (!self.notReadyToScan)) {
		return YES;
	} else {
		return NO;
	}
}

/**
 *  @inheritdoc
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#ifdef DEBUG
	NSLog(@"prepareForSegue received");
#endif
	if ([segue.identifier isEqualToString: @"logTableSegue"]) {
		// Setting AppBusy status, before going into Log Table
		self.notReadyToScan = YES;
		
		// Sending data to Log Table
		if ([[segue.destinationViewController topViewController] isKindOfClass:[VTKLogTableViewController class]]) {
			VTKLogTableViewController *tableView = (VTKLogTableViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
			tableView.scanResultItems = self.scanResultItems;
		}
	} 
}

/**
 *  An action of returning back to the main app screen
 *
 *  @param segue identifier of the segue
 */
- (IBAction)unwindToMainScreen:(UIStoryboardSegue *)segue
{
#ifdef DEBUG
	NSLog(@"unwindToMainScreen received.");
#endif
	// Set AppBusy status to available upon return to main app screen
	self.notReadyToScan = NO;
}

/**
 Sets up scanner hardware
 Normally called after the app settings has been read from device's storage
 */
- (void)invokeScannerSetup
{
    [self invocateGetUserName];

    VTKScannerFramework scannerType = self.settings.scannerDeviceType;
    self.scanner = [VTKScannerManager sharedInstance];

    // Setup the pre-selected scanner framework and prepare to use if the scanner is not Apple Camera
    // As in that case the setup will be done upper in SplitCamViewController
    if (scannerType != VTKBarcodeFrameworkAppleCamera) {
        [self.scanner setupScannerWithFramework:scannerType
                                   withDelegate:self];
#ifdef DEBUG
        NSLog(@"Scanner type: %d", scannerType);
#endif
    }

#ifdef DEBUG
    // Allow an alert window with detailed bat data
    [self.scannerBatStatusIcon setUserInteractionEnabled:YES];
#endif
}

#pragma mark - UIViewController methods
/**
 *  @inheritdoc
 */
- (void)viewDidLoad
{
	[super viewDidLoad];

    self.settings = [VTKSettings storage];

    self.settings.delegate = self;

    // Do any additional setup after loading the view, typically from a nib.
	self.isUpsideDown = NO;

    self.scanResultItems = self.settings.scanResultItems;

    [self displayNotReady];
	
	// Preparing sound resources
	NSURL *deniedURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"denied"
																			   ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)deniedURL, &_deniedSound);
	
	NSURL *allowedURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"allowed"
																			    ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)allowedURL, &_allowedSound);
	
	// по умолчанию считаем, что связи нет
//    [self serverConnectionStatus: NO];

    // Add back button to Navigation bar
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
//                                                                                          target: self
//                                                                                          action: @selector(doneAction)];

	// Устанавливаем имя пользователя на главном экране в значение имени текущего девайса
	self.navigationItem.title = [UIDevice currentDevice].name;
	self.isUserNameSet = NO;
}

/**
 *  Being called upon the 'Close' button press
 */
- (void)doneAction
{
    [self.presentingViewController dismissViewControllerAnimated: YES
                                                      completion: nil];
}

/**
 *  @inheritdoc
 */
- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"didReceiveMemoryWarning received");
#endif

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Is being called right after the view has been initially drawn
 *
 *  @param animated states if the appearance should be animated
 */
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
#ifdef DEBUG
	NSLog(@"viewDidAppear done.");
#endif
}


/**
 *  @inheritdoc
 */
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}

/**
 *  @inheritdoc
 */
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//
//}

/**
 *  @inheritdoc
 */
-(BOOL) shouldAutorotate {
	return NO;
}

/**
 *  returns supported by this view controller interface orientations
 *
 *  @return returns a bit mask of allowed orientations
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - VTKScannerDelegate

/**
 *  Being called-back by the framework after the scanner connection
 */
- (void)scannerConnectedNotification
{
	// Показываем статус готовности к сканированию
	self.notReadyToScan = NO;
	[self displayReadyToScan];
	
	// Инициируем опрос заряда батареи
	[self performSelector:@selector(postponeBatteryRemain)
			   withObject:nil
			   afterDelay:0.8f];
}

/**
 *  Is being called upon scanner hardware disconnection
 */
- (void)scannerDisconnectedNotification
{
	// Показываем статус неготовности к сканированию
	self.notReadyToScan = YES;
	[self displayNotReady];
	
	// Отображаем статус отключённого девайса
	[self setBatteryRemainIcon];
}

/**
 *  This method is being called after scanner succefully scaned a barcode
 *
 *  @param command command description
 */
- (void)scannerBarcodeScannedNotification:(NSString *)barcode
{
	// Если система занята, то игнорируем результаты сканирования
	if (!self.notReadyToScan) {
		[self doScannedBarcodeCheck: barcode];
	}
}

/**
 *   Handler, that is being called by the framework to update the device bat status
 */
- (void)scannerInformationUpdateNotification
{
	// Обрабатываем обновлённую информацию о заряде
	[self setBatteryRemainIcon];
}

/**
 *  Handler, that is called when the scanner battery gets critically low
 */
- (void)scannerLowPowerNotification
{
	self.notReadyToScan = YES;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Информация", @"Заголовок алерта")
													message:NSLocalizedString(@"Низкий заряд батареи сканера. Пожалуйста, подключите сканер к зарядному устройству", @"Cообщение алерта")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Ок", @"Кнопка Ок")
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark - Server response handlers

/**
 *  Handles the success response from JSON-RPC
 *
 *  @param responseObject the NSDictionary that contains the parsed JSON response
 */
- (void)handleSuccessResponse:(id)validatorResponse
{
    VTKValidatorResponse *parsedResponse = [[VTKServerCommand sharedInstance] unpackResponse:validatorResponse];
	if (parsedResponse) {
		switch (parsedResponse.responseCode) {
            case VTKAPI10ResponseResultOk:
                [self displayReadyToScan];
                self.notReadyToScan = NO;
                break;

            case VTKAPI10ResponseSetActiveUser:
                self.navigationItem.title = parsedResponse.userName;
                self.isUserNameSet = YES;
                self.notReadyToScan = NO;
                break;

            case VTKAPI10ResponseSetActiveUserNotFound:
                self.isUserNameSet = NO;

                // Setting the user name on the main view to a current device's name
                self.navigationItem.title = [UIDevice currentDevice].name;

                // Showing alert
                self.warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Заголовок алерта")
                                                               message:NSLocalizedString(@"Неверный GUID! Обратитесь к администратору системы", @"Сообщение алерта")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Отмена", @"Кнопка Отмена")
                                                     otherButtonTitles:nil];
                [self.warningAlert show];
                [self displayReadyToScan];
                break;

            case VTKAPI10ResponseSetActiveEvent:
    //TODO: Пока не реализовано
                self.notReadyToScan = NO;
                break;

            case VTKAPI10ResponseSetActiveEventNotFound:
    //TODO: Пока не реализовано
                self.notReadyToScan = NO;
                break;

			case VTKAPI10ResponseAccessAllowed ... VTKAPI10ResponseAccessDeniedUnknownError:
			{
				// Checking if the barcode matches to what we've sent
				if ([parsedResponse.barcode isEqualToString: self.lastScannedBarcode]) {
                    // Упаковываем результат сканирования в формат лога
                    VTKScanResultItem *scanResultItem = [[VTKScanResultItem alloc] initItemWithValidatorResponse: parsedResponse];
                    // Adding NSDictionary parsed from JSON response to logItem
                    scanResultItem.serverParsedResponse = [(NSDictionary *)validatorResponse objectForKey:@"params"];

					// Showing the result
					[self displayScanResult: scanResultItem];
					
					// Запускаем таймер, по окончании которого снова отображается "Ожидание Проверки"
					[self runStatusRevertTimer];

					// Adding logItem to log table
					[self addScanResultItemToLog: scanResultItem];
					
					// Displaying the logItem in the lower part of the screen
					[self displaySustainedScanResult: scanResultItem];
					self.notReadyToScan = NO;
				} else {
					// Если штрих-код в запросе и ответе не совпадают - показываем алерт
					self.warningAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Ошибка", @"Заголовок алерта")
																  message:NSLocalizedString(@"Неверный ответ сервера", @"Сообщение алерта")
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Повторить", @"Кнопка Повторить")
														otherButtonTitles:nil];
					[self.warningAlert show];
					[self displayReadyToScan];
				}
				break;
			}
				
			case VTKAPI10ResponseErrorNetworkError ... VTKAPI10ResponseErrorServerResponseUnkown:
				
			default:
				// Показываем алерт
				self.warningAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Ошибка", @"Заголовок алерта")
															  message:NSLocalizedString(@"Неизвестный ответ сервера", @"Сообщение алерта")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Повторить", @"Кнопка Повторить")
													otherButtonTitles:nil];
				[self.warningAlert show];
				[self displayReadyToScan];
				
				break;
		}
	} else {
		// Показываем алерт
		self.warningAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Ошибка", @"Заголовок алерта")
													  message:NSLocalizedString(@"Нет кода ответа сервера", @"Сообщение алерта")
													 delegate:self
											cancelButtonTitle:NSLocalizedString(@"Повторить", @"Кнопка Повторить")
											otherButtonTitles:nil];
		[self.warningAlert show];
		[self displayReadyToScan];
	}
//    [self serverConnectionStatus:YES];
}

/**
 *  This is how we handle the failure response from JSON-RPC
 *
 *  @param error Error description
 */
- (void)handleFailureResponse:(NSError *)error
{
	// Показываем алерт
	NSString *message = NSLocalizedString(@"Ошибка соединения с сервером", "Сообщение алерта - 1я строка");
	
	switch (error.code) {
		case 0:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nНеверный ответ сервера", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorBadURL:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nНеверный URL сервера", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorTimedOut:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nПревышено время ожидания", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorUnsupportedURL:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nОшибка в URL сервера", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorCannotFindHost:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nНеверный URL сервера", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorCannotConnectToHost:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nНе могу соединиться с сервером", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorNetworkConnectionLost:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nСетевое соединение потеряно", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorDNSLookupFailed:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nОшибка DNS", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorHTTPTooManyRedirects:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nСлишком много редиректов", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorCannotParseResponse ... NSURLErrorCannotDecodeRawData:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nНеверный формат ответа", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorNotConnectedToInternet:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nПроверьте сетевое соединение", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorDataLengthExceedsMaximum:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nПревышен максимальный размер данных", @"Сообщение алерта - 2я строка")];
			break;
		case NSURLErrorClientCertificateRequired ... NSURLErrorSecureConnectionFailed:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\nОшибка безопасности (SSL)", @"Сообщение алерта - 2я строка")];
			break;
		default:
			message = [message stringByAppendingFormat:NSLocalizedString(@"\n%@ ошибка %li", @"Сообщение алерта - 2я строка"), error.domain, (long)error.code];
	}

	self.warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", @"Заголовок алерта")
												   message:message
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Повторить", @"Сообщение алерта")
										 otherButtonTitles:nil];
	[self.warningAlert show];
	
	self.notReadyToScan = NO;
	[self displayReadyToScan];
	
	// Displaying the server connection fail
//    [self serverConnectionStatus:NO];
}

#pragma mark - Scanner methods

/**
 *  Does the barcode lookup & check and passes the data further to show the result
 *
 *  @param barcode An NSString that contains the scanned barcode to lookup
 */
- (void)doScannedBarcodeCheck: (NSString *)barcode
{
	// Удаляем из строки возврат каретки
	barcode = [barcode stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	// Запоминаем последний код
	self.lastScannedBarcode = barcode;
	
	// Устанавливаем статус приложения
	self.notReadyToScan = YES;
	[self displayProgress];
	
#if TEST_IPOD_WITHOUT_SCANNER == 1
	VTKValidatorResponse *parsedResponse = [VTKValidatorResponse new];
    parsedResponse.barcode               = self.lastScannedBarcode;
    parsedResponse.responseCode          = VTKAPI10ResponseAccessAllowed;

    VTKScanResultItem *scanResultItem = [[VTKScanResultItem alloc] initItemWithValidatorResponse: parsedResponse];

	scanResultItem.serverParsedResponse = @{@"GUID": @"123",
                                    @"ResponseCode": @"0x210",
									 @"TimeChecked": @"20140809T14:00:00",
									 };
	
	[self addScanResultItemToLog: scanResultItem];
	[self displayScanResult: scanResultItem];
    [self displaySustainedScanResult: scanResultItem];
	self.notReadyToScan = NO;
	[self runStatusRevertTimer];
#else

	// Опрашиваем сервер и ждём ответ
	[[VTKServerCommand sharedInstance] prepareWithServer: self.settings.serverURL
                                             withCommand: getCodeResult
                                                withGUID: self.settings.userGUID
                                             withBarcode: barcode];
	// we're working JSON-RPC all the work should be done here inside the blocks
	[[VTKServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
                                                                    [self handleSuccessResponse: responseObject];
                                                                }
                                                                failure:^(NSError *error) {
                                                                    [self handleFailureResponse: error];
                                                                }];

#endif
}

 /**
 *  Checks if the hardware barcode scanner is connected and returns the result
 *
 *  @return YES if the scanner has been found
 */
- (BOOL)isScannerConnected
{
	BOOL connected;
#if TARGET_IPHONE_SIMULATOR
	connected = YES;
#elif TEST_IPOD_WITHOUT_SCANNER == 1
	connected = YES;
#else
	connected = [[VTKScannerManager sharedInstance].scanner isConnected];
#endif
	
#ifdef DEBUG
	NSLog(@"isScannerConnected received: %hhd", (char)connected);
#endif
	return connected;
}

/**
 *  Returns the hardware scanner remaining battery in percent
 *
 *  @return Returns the NSNumber of percents
 */
- (NSNumber *)getScannerBatRemain
{
	NSNumber *remain;
#if TARGET_IPHONE_SIMULATOR
	remain = @101;
#else
	// get battery info
	remain = [[VTKScannerManager sharedInstance].scanner getBatteryRemain];
#endif

#ifdef DEBUG
	NSLog(@"getScannerBatRemain received: %@", remain);
#endif
	return remain;
}

/**
 *  Checks if hardware scanner is being charged at the moment and returns the result
 *
 *  @return YES if the scanner is on charge
 */
- (BOOL)isScannerOnCharge
{
#ifdef DEBUG
	NSLog(@"isScannerOnCharge received");
#endif

#if TARGET_IPHONE_SIMULATOR
	return  YES;
#endif
	return [[VTKScannerManager sharedInstance].scanner isBatteryOnCharge];
}

/**
 *  Initiates the charging of iDevice from the scanner's battery
 */
- (void)chargeiDeviceBattery {
#ifdef DEBUG
	NSLog(@"chargeiDeviceBattery received");
#endif
  [[VTKScannerManager sharedInstance].scanner chargeBatteryFromScanner];
}

#pragma mark - Utility methods
/**
 *  Turns on and off the wait sign
 *
 *  @param show specifies if the wait sign should be shown
 */
- (void)showWaitingSign:(BOOL)show
{
	if (show) {
		[self.waitSign startAnimating];
        [self avoidScans:YES];
	} else {
		[self.waitSign stopAnimating];
        [self avoidScans:NO];
	}
}

/**
 Checks if the Barcode Scanner supports method avoidScans: and calls it

 @param yes BOOL to be sent to Scanner
 */
- (void)avoidScans:(BOOL)yes
{
    id<VTKBarcodeScanner> scanner = [VTKScannerManager sharedInstance].scanner;
    if ([scanner respondsToSelector:@selector(avoidScans:)]) {
        [scanner avoidScans: yes];
    }
}

/**
 *  Starts the timer, after the run out of which the Ticket Check result status display will be reset
 */
- (void)runStatusRevertTimer
{
	static NSTimer	*timer;
	
	if (timer) {
		[timer invalidate];
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:self.settings.resultDisplayTime
											 target:self
										   selector:@selector(displayReadyToScan)
										   userInfo:nil
											repeats:NO];
}

/**
 *  Initiates the scanner charge check. The result comes as a callback from the framework
 */
- (void)postponeBatteryRemain
{
#ifdef DEBUG
	NSLog(@"postponeBatteryRemain received");
#endif

#if TARGET_IPHONE_SIMULATOR
    [self setBatteryRemainIcon];
#elif TEST_IPOD_WITHOUT_SCANNER == 1
    [self setBatteryRemainIcon];
#else
    [[VTKScannerManager sharedInstance].scanner postponeBatteryRemain];
#endif
}

/**
 *  Displays the scanner battery remain icon corresponding to the data returned by the scanner framework
 */
- (void)setBatteryRemainIcon
{
#ifdef DEBUG
	NSLog(@"setBatteryRemainIcon received");
#endif
	UIImage *batIcon;
	if ([self isScannerConnected]) { // проверяем подключен ли сканер
		NSInteger batRemain = [[self getScannerBatRemain] integerValue];
#ifdef DEBUG
        NSLog(@"Battery remain info received from scanner framework: %ld", (long)batRemain);
#endif
		
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

/**
 *  Setter for isAppBusy. Sets the busy status of the app, which defines if the app is ready for a new barcode scan. Also resets the status display timer
 *
 *  @param yes YES if need to set app busy status
 */
-(void)setNotReadyToScan: (BOOL)yes
{
	static  NSTimer	*timer;
	if (timer) {
		[timer invalidate];
	}
	
	if (yes) {
		_notReadyToScan = YES;
		self.scanButton.enabled = NO;
	} else {
		_notReadyToScan = NO;
		self.scanButton.enabled = YES;
	}

#ifdef DEBUG
	NSLog(@"setAppBusyStatus received: %d", yes);
#endif
}

/**
 *  Cancels the app busy status and displays "Ready to scan" as a status
 */
- (void)cancelAppBusyStatus
{
#ifdef DEBUG
	NSLog(@"cancelAppBusyStatus received");
#endif
	self.notReadyToScan = NO;
	[self displayReadyToScan];
}

/**
 *  Displays the status "Not Ready"
 */
- (void)displayNotReady
{
    self.background.backgroundColor = [UIColor lightGrayColor];
    self.scannedStatus.text         = NSLocalizedString(@"НЕ ГОТОВ", @"Отображение главного статуса");
    self.scannedStatus.textColor    = [UIColor darkGrayColor];
    self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: NO];
}

/**
 *  Displays the status "Awaiting for check"
 */
- (void)displayReadyToScan
{
	self.background.backgroundColor = [UIColor colorWithRed:0.92f
													  green:0.92f
													   blue:0.92f
													  alpha:1.0f];
    self.scannedStatus.text         = NSLocalizedString(@"ОЖИДАНИЕ ПРОВЕРКИ", @"Отображение главного статуса");
    self.scannedStatus.textColor    = [UIColor lightGrayColor];
    self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: NO];
}

/**
 *  Displays the status "Searching the ticket"
 */
- (void)displayProgress
{
    self.background.backgroundColor = [UIColor lightGrayColor];
    self.scannedStatus.text         = NSLocalizedString(@"ПОИСК БИЛЕТА", @"Отображение главного статуса");
    self.scannedStatus.textColor    = [UIColor darkGrayColor];
    self.scannedSubStatus.textColor = [UIColor clearColor];
	[self showWaitingSign: YES];
}

/**
 *  Displays the status depending on the ticket check result
 *
 *  @param scanResult The result of the check, that should be displayed
 */
- (void)displayScanResult: (VTKScanResultItem *)scanResultItem
{
	[self showWaitingSign: NO];
    if (scanResultItem.allowedAccess) {
        self.background.backgroundColor = [UIColor greenColor];
        self.scannedStatus.alpha        = 0;
        self.scannedStatus.text         = scanResultItem.statusText;
        self.scannedStatus.textColor    = [UIColor whiteColor];
        self.scannedSubStatus.textColor = [UIColor clearColor];

        [self doAllowedStatusAnimation];
    } else {
        self.background.backgroundColor = [UIColor redColor];
        self.scannedStatus.text         = scanResultItem.statusText;
        self.scannedStatus.textColor    = [UIColor whiteColor];
        self.scannedSubStatus.text      = scanResultItem.extendedStatusText;
        self.scannedSubStatus.textColor = [UIColor whiteColor];

        [self doDeniedStatusAnimation];
    }
}

#pragma mark - Result log methods

/**
 *  Adds last scan result to the log
 *
 *  @param logItem The item to add to log
 */
- (void)addScanResultItemToLog:(VTKScanResultItem *)logItem
{
	if (!self.scanResultItems) {
        NSLog(@"Can't add scan result to log as the log is nil!");
        return;
	} else if ([self.scanResultItems count] == NUMBER_OF_HISTORY_ITEMS) {
		[self.scanResultItems removeLastObject];
	}
	[self.scanResultItems insertObject: logItem atIndex: 0];
}

/**
 *  Displays the last scan result at lower part of the screen with animation
 *
 *  @param logItem The item to display
 */
- (void)displaySustainedScanResult:(VTKScanResultItem *)scanResultItem
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	[dateFormatter setDateStyle: NSDateFormatterNoStyle];
	
	NSString *title = [dateFormatter stringFromDate: scanResultItem.locallyCheckedTime];
	title = [title stringByAppendingFormat: NSLocalizedString(@" Билет %@", @"Строка лога"), scanResultItem.barcode];
	
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
                         self.lastTicketStatusLabel.text = [[scanResultItem.statusText stringByAppendingString: @": "]
                                                            stringByAppendingString:scanResultItem.extendedStatusText];
						 if (scanResultItem.allowedAccess) {
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

/**
 *  Animates the new allowed status
 */
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

/**
 *  Animates the new refuse status
 */
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



#pragma mark - Server query methods

/**
 *  Checks if the ticket server responds
 */
- (void)invocateServerAliveCheck
{
	[[VTKServerCommand sharedInstance] prepareWithServer:self.settings.serverURL
											  withCommand:noOp
												 withGUID:self.settings.userGUID
											  withBarcode:@""];
	
	[[VTKServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
																	[self handleSuccessResponse:responseObject];
																}
																 failure:^(NSError *error) {
																	 [self handleFailureResponse:error];
																 }];
}

/**
 *  Initiates the name of the current entry point on the server by the GUID of the current device
 */
- (void)invocateGetUserName
{
	[[VTKServerCommand sharedInstance] prepareWithServer:self.settings.serverURL
											  withCommand:getUserName
												 withGUID:self.settings.userGUID
											  withBarcode:@""];

	[[VTKServerCommand sharedInstance] doPreparedCommandWithJSONsuccess:^(id responseObject) {
																	[self handleSuccessResponse:responseObject];
																}
																 failure:^(NSError *error) {
																	 [self handleFailureResponse:error];
																 }];
}

#pragma mark - Other delegates
/**
 *  Sent to the delegate when the user clicks a button on an alert view
 *
 *  @param alertView   The alert view that sent the message
 *  @param buttonIndex The button that was used to close the alert box
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

/**
 *  Sent to the delegate after an alert view is dismissed from the screen
 *
 *  @param alertView   The alert view that sent the message
 *  @param buttonIndex The button that was used to close the alert box
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	self.notReadyToScan = NO;
	
	if ((alertView == self.manualBarcodeAlert) && ([[alertView textFieldAtIndex:0].text length] > 0)) {
		[self doScannedBarcodeCheck:[alertView textFieldAtIndex:0].text];
	}
}
@end
