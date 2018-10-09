//
//  VTKDummyScanner.h
//  Ticket Control
//
//  Created by Yevgen Lysenko on 10/8/18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeScanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface VTKDummyScanner : NSObject <VTKBarcodeScanner>

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

NS_ASSUME_NONNULL_END
