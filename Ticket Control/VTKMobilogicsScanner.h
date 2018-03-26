//
//  VTKMobilogicsScanner.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeScannerProtocol.h"

@interface VTKMobilogicsScanner : NSObject <VTKBarcodeScannerProtocol, ReceiveCommandHandler, NotificationHandler>

/**
 *  A delegate object that will receive all callbacks
 */
@property (nonatomic, weak) id <VTKScannerDelegateProtocol> delegate;

/**
 *  Checks if the scanner is connected
 *
 *  @return returns YES if the scanner is connected
 */
- (BOOL)isConnected;

/**
 *  @inheritDoc
 */
- (NSNumber *)getBatteryRemain;

/**
 *  @inheritDoc
 */
- (void)invocateBarcodeScan;

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
