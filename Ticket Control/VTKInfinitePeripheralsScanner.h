//
//  VTKInfinitePeripheralsScanner.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeScanner.h"
#import "DTdevices.h"

@interface VTKInfinitePeripheralsScanner : NSObject <VTKBarcodeScanner, DTDeviceDelegate>

/**
 *  A delegate object that will receive all callbacks
 */
@property (nonatomic, weak) id <VTKScannerDelegate> delegate;

/**
 @inheritDoc
 */
- (NSNumber *)getBatteryRemain;

/**
 @inheritDoc
 */
- (void)postponeBatteryRemain;

/**
 @inheritDoc
 */

- (void)invocateBarcodeScan;

/**
 @inheritDoc
 */

- (BOOL)isConnected;

/**
 *  @inheritDoc
 */
- (void)chargeBatteryFromScanner;

/**
 *  @inheritDoc
 */
- (void)turnBeepOn: (BOOL)yes;

/**
 *  @inheritDoc
 */
- (void)setScannerVibroLevel: (unsigned int)level;

/**
 *  @inheritDoc
 */
- (void)wakeup;

/**
 @inheritDocs
 */
- (void)updateAccessoryInfo;

/**
 @inheritDoc
 */
- (BOOL)isBatteryOnCharge;

@end
