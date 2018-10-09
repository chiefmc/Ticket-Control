//
//  VTKScanViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKScannerDelegate.h"
#import "VTKSettingsDelegate.h"
@import UIKit;

/**
 *  This is the ViewController of the main screen of the app, where all the scanning work takes place
 */
@interface VTKScanViewController : UIViewController <VTKScannerDelegate, VTKSettingsDelegate, UIAlertViewDelegate>

/**
 *  Array of scan result items (weak pointer to one from TCTCLSettings)
 */
@property (nonatomic, weak) NSMutableArray	    *scanResultItems;
@property (nonatomic, weak) IBOutlet UIButton   *scanButton;
@property (nonatomic, weak) IBOutlet UIButton   *scannerBatStatusIcon;


/**
 @inheritDoc
 */
- (void) invokeScannerSetup;

/**
 @inheritDoc
 */
- (void)setBatteryRemainIcon;

//- (IBAction)tappedScan:(id)sender;              // Сканирует штрихкод
//- (IBAction)showScannerBatDetails:(id)sender;	// Показывает tip с детальным статусом батареи саней
//- (IBAction)numKeypadTapped:(id)sender;	// Вызывает окно ввода штрих-кода вручную
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;

@end
