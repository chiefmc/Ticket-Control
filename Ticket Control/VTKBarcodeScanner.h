//
//  VTKBarcodeScanner.h
//	Barcode scanner Hardware Abstraction Layer (HAL) foundation class
//  Ticket Control
//
//  Created by Евгений Лысенко on 05.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;

/**
 *  An abstract foundation class that describes generic methods. Not intended for direct usage.
 */
@interface VTKBarcodeScanner : NSObject

/**
 *  The delegate object that will receive all callbacks
 */
@property (nonatomic, weak) id delegate;

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
- (NSNumber *)batteryRemain;

/**
 *  Invocates the scanner hardware to read the barcode. The decoded string will be sent by <code>-barcodeScannedNotification:</code> callback method to the delegate upon successful reading.
 */
- (void)invocateBarcodeScan;

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

@end
