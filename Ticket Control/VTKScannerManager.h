//
//  VTKScannerManager.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

@import Foundation;

@class VTKBarcodeScanner;

/**
 *  The protocol, that is used to handle the communication between the app and the scanner
 */
@protocol VTKScannerDelegate

@required
/**
 *  Callback method to handle the scanned barcode
 */
- (void)scannerBarcodeScannedNotification: (NSString *)barcode;

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


/**
 *  Enumerates supported barcode scanner frameworks
 */
typedef NS_ENUM(unsigned int, VTKScannerFramework){
    /**
     *  The iOS built-in framework that uses the device's camera to read barcodes
     */
    VTKBarcodeFrameworkAppleCamera,
    /**
     *  The Mobilogics framework, that support their devices: aScan, iScan, iPDT380 abd iPDT5
     */
    VTKBarcodeFrameworkMobilogics,
    /**
     *  The Infinite Peripherals framework, that supports their devices.
     */
    VTKBarcodeFrameworkInfinitePeripherals,
    /**
     *  The Honeywell framework, that supports their devices.
     */
    VTKBarcodeFrameworkHoneywell
};


/**
 *  This singleton class manages all barcode scanner connections and handles all opearations
 */
@interface VTKScannerManager : NSObject

/**
 *  The pointer to a delegate object. You must set it up right after the <code>+setup</code> been called.
 */
@property (nonatomic, weak) id <VTKScannerDelegate> delegate;

/**
 *  Contains the currently connected barcode scanner type
 */
@property (nonatomic, readonly) VTKScannerFramework activeScannerType;

/**
 *  Has the currenly connected scanner handler or nil if no scanner connected
 */
@property (nonatomic, strong, readonly) VTKBarcodeScanner *connectedScanner;

/**
 *  This class method returns the singleton object
 *
 *  @return Returns the signleton object
 */
+ (instancetype)sharedInstance;

/**
 *  You must call this method prior to using any other method. It initializes the related frameworks and checks the hardware. Use it somewhere early in the code, like <code>-application: didFinishLaunchingWithOptions:</code> of UIApplicationDelegate
 *
 *  @param framework The type of framework with <code>VTKScannerFramework</code> to try to initialize
 *  @param delegate  The delegate object that will receive all the callbacks. Must conform to VTKScannerDelegate protocol
 */
- (void)setupScannerFramework: (VTKScannerFramework)framework withDelegate: (id <VTKScannerDelegate>)delegate;

/**
 *  Invocates the barcode scan with scanning hardware. The scanned result will be sent upon succefull reading with callback method <code>-barcodeScannedNotification:</code>
 */
- (void)scan;

/**
 *  Initiates the barcode scan from the iOS device's built-in camera.
 *
 *  @return Returns the scanned string or nil if scan was unsuccessful for any reason.
 */
- (NSString *)scanWithCamera;

/**
 *  This method is used to try and wake the scanner framework from sleep mode
 */
- (void)wakeup;

@end
