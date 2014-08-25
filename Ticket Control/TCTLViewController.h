//
//  TCTLViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCTLViewController : UIViewController <ReceiveCommandHandler, NotificationHandler>

@property (nonatomic, weak) IBOutlet UILabel    *userName;
@property (nonatomic, weak) IBOutlet UILabel    *scannedStatus;
@property (nonatomic, weak) IBOutlet UILabel    *scannedSubStatus;
@property (nonatomic, weak) IBOutlet UIButton	*scannerBatStatusIcon;
@property (nonatomic, weak) IBOutlet UIButton	*serverConnectionStatus;
@property (nonatomic, weak) IBOutlet UIView		*background;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView	*waitSign;

- (IBAction)tappedScan:(id)sender;              // Сканирует штрихкод
- (IBAction)sledShowSledBatDetails:(id)sender;  // Показывает tip с детальным статусом батареи саней
- (IBAction)showServerConnectionInfo:(id)sender;// Показывает tip со статусом соединения с билетным сервером

@end
