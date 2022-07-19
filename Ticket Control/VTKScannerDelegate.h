//
//  VTKScannerDelegateProtocol.h
//  Ticket Control
//
//  Created by Yevgen Lysenko on 26.03.18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

#ifndef VTKScannerDelegateProtocol_h
#define VTKScannerDelegateProtocol_h


#endif /* VTKScannerDelegateProtocol_h */

/**
 *  The protocol, that is used to handle the communication between the app and the scanner
 */
@protocol VTKScannerDelegate <NSObject>

@required
/**
 *  Callback method to handle the scanned barcode
 */
- (void)scannerBarcodeScannedNotification: (NSString *)barcode;

@optional
/**
 *  Callback method to handle the scanner connection
 */
- (void)scannerConnectedNotification;

/**
 *  Callback method to handle the scanner disconnection
 */
- (void)scannerDisconnectedNotification;

/**
 *  Callback method to handle the scanner battery level update and other possible non-critical messages
 */
- (void)scannerInformationUpdateNotification;

/**
 *  Callback method to handle the scanner's low battery notification
 */
- (void)scannerLowPowerNotification;

@end
