//
//  VTKBarcodeScanner.h
//	Barcode scanner Hardware Abstraction Layer (HAL) foundation class
//  Ticket Control
//
//  Created by Евгений Лысенко on 05.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;
#import "VTKScannerDelegate.h"

/**
 *  A protocol that describes generic methods. Not intended for direct usage.
 */
@protocol VTKBarcodeScanner <NSObject>

@required
/**
 *  A delegate object that will receive all callbacks
 */
@property (nonatomic, weak) id <VTKScannerDelegate> delegate;

/**
 *  Checks if the scanner is connected
 *
 *  @return returns YES if the scanner is connected
 */
- (BOOL)isConnected;

/**
 *  Returns the current barcode scanner's battery charge in percents.
 *
 *  @return Returns battery remain in percents. Returns negative value (<0) if no scanner connected or >100 if the scanner is being charged.
 */
- (NSNumber *)getBatteryRemain;

/**
 *  Invocates the scanner hardware to read the barcode. The decoded string will be sent by <code>-barcodeScannedNotification:</code> callback method to the delegate upon successful reading.
 */
- (void)invocateBarcodeScan;

@optional
/**
 *  Signals the hardware scanner to start charging the iDevice from the scanner's own battery. If no scanner connected - ignores the message.
 */
- (void)chargeBatteryFromScanner;

/**
 *  Turns the hardware scanner's beep signal ON and OFF if available
 *
 *  @param yes YES if you want to turn the beep on
 */
- (void)turnBeepOn: (BOOL)yes;

/**
 *  Sets the hardware scanner's vibro strength if available
 *
 *  @param level The strength of vibro motor. [0-3] for Mobilogics, where 0 - off and 3 - strong.
 */
- (void)setScannerVibroLevel: (unsigned int)level;

/**
 *  This method is used to wakeup the framework after an inactivity period
 */
- (void)wakeup;

/**
 Inocates the hardware's state update (needed at least for Mobilogics devices prior to battery level check)
 */
- (void)updateAccessoryInfo;

/**
 Returns YES is the scanner's battery is currently being charged

 @return YES if charged
 */
- (BOOL)isBatteryOnCharge;


/**
 Send message to the scanner that it needs to hold all scans until next call with yes param set to `NO`

 @param yes YES to stop all scans
 */
- (void)avoidScans: (BOOL)yes;

/**
 Initializes background checks for remaining battery charge
 */
- (void)postponeBatteryRemain;

@end
