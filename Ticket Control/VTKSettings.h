//
//  TCTLSettings.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 10.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

@import Foundation;
#import "VTKScannerManager.h"

@interface VTKSettings : NSObject

/**
 *  Returns the Singleton settings object
 *
 *  @return Returns the Singleton instance
 */
+ (instancetype)storage;

/**
 *  Initializes the settings storage, reads the app's defaults.
 */
- (void)load;

/**
 *  Tears down the storage, saves what needs to be saved
 */
- (void)close;

// Переменные в которые читаются настройки приложения из Settings Bundle
@property (nonatomic) NSInteger             vibroStrength;
@property (nonatomic) BOOL				    disableAutolock;
@property (nonatomic, copy) NSString	    *userGUID;
@property (nonatomic) NSTimeInterval	    resultDisplayTime;
@property (nonatomic, strong) NSURL		    *serverURL;
@property (nonatomic) BOOL				    scannerBeep;
@property (nonatomic) VTKScannerFramework   scannerDeviceType;

// Массив-история сосканированных кодов, который использует VTKScanViewController
@property (nonatomic, strong) NSMutableArray	*scanResultItems;

@end
