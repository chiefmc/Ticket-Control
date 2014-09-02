//
//  TCTLViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMLRPC/XMLRPC.h>

@interface TCTLViewController : UIViewController <ReceiveCommandHandler, NotificationHandler,XMLRPCConnectionDelegate>

@property (nonatomic, weak) IBOutlet UIView		*mainView;
@property (nonatomic, weak) IBOutlet UILabel    *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel    *scannedStatus;
@property (nonatomic, weak) IBOutlet UILabel    *scannedSubStatus;
@property (nonatomic, weak) IBOutlet UILabel	*lastTicketNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel	*lastTicketStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton	*scannerBatStatusIcon;
@property (nonatomic, weak) IBOutlet UIButton	*scanButton;
@property (nonatomic, weak) IBOutlet UIButton	*serverConnectionStatus;
@property (nonatomic, weak) IBOutlet UIView		*background;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView	*waitSign;
@property (nonatomic, weak) IBOutlet UIButton	*rotateViewOrientation;

// Массив-история сосканированных кодов
@property (nonatomic, strong) NSMutableArray	*scanResultItems;

- (IBAction)tappedScan:(id)sender;              // Сканирует штрихкод
- (IBAction)showScannerBatDetails:(id)sender;	// Показывает tip с детальным статусом батареи саней
- (IBAction)showServerConnectionInfo:(id)sender;// Показывает tip со статусом соединения с билетным сервером
//- (IBAction)logTableButtonTapped:(id)sender;	// Вызывает таблицу лога результатов сканирования
- (IBAction)unwindToMainScreen:(UIStoryboardSegue *)segue;		// Возвращает на главный экран
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;

// Делегаты получения сообщений от XMLRPC
- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)xmlResponse;
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;
- (BOOL)request: (XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace;
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

@end
