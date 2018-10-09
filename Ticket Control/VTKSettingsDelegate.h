//
//  VTKSettingsDelegateProtocol.h
//  Ticket Control
//
//  Created by Yevgen Lysenko on 10/7/18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

#import "VTKScannerManager.h"

@protocol VTKSettingsDelegate <NSObject>

@required

/**
 Invokes scanner setup with the delegate
 */
- (void)invokeScannerSetup;

@end
