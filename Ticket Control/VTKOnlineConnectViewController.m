//
//  VTKOnlineConnectViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKOnlineConnectViewController.h"
#import "VTKScanViewController.h"
#import "VTKServerAPIAdapter.h"
#import "VTKSettings.h"

@interface VTKOnlineConnectViewController ()

@end

@implementation VTKOnlineConnectViewController

/**
 *  @inheritdoc
 */
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Setting up tab bar item
        self.tabBarItem.title         = NSLocalizedString(@"Онлайн", @"Название закладки");
    }
    
    return self;
}

/**
 *  @inheritdoc
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

/**
 *  @inheritdoc
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Presents modally VTKScanViewController
 *
 *  @param sender Pointer to the object that sent the message
 */
- (IBAction)startScanAction:(id)sender {
    UIStoryboard *storyboard   = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VTKScanViewController *svc = (VTKScanViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    //TODO: добавить установку текста заголовка контроллера
//    svc.barcodeValidator       = [[VTKServerAPIAdapter alloc] init];
//    svc.scanResultItems        = [VTKSettings storage].scanResultItems;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:svc];
    navController.restorationIdentifier   = NSStringFromClass([navController class]);
    navController.modalPresentationStyle  = UIModalPresentationFormSheet;
    navController.modalTransitionStyle    = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
