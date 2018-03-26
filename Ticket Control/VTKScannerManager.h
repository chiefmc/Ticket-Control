//
//  VTKScannerManager.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

@import Foundation;
#import "VTKScannerDelegateProtocol.h"
#import "VTKBarcodeScannerProtocol.h"

@class VTKBarcodeScanner;

/**
 *  Enumerates supported barcode scanner frameworks
 */
typedef NS_ENUM(unsigned int, VTKScannerFramework) {
    /**
     *  The iOS built-in framework that uses the device's camera to read barcodes
     */
    VTKBarcodeFrameworkAppleCamera = 0,
    /**
     *  The Mobilogics framework, that support their devices: aScan, iScan, iPDT380 abd iPDT5
     */
    VTKBarcodeFrameworkMobilogics = 1,
    /**
     *  The Infinite Peripherals framework, that supports their devices.
     */
    VTKBarcodeFrameworkInfinitePeripherals = 2,
    /**
     *  The Honeywell framework, that supports their devices.
     */
    VTKBarcodeFrameworkHoneywell = 3
};


/**
 *  This singleton class manages all barcode scanner connections and handles all opearations
 */
@interface VTKScannerManager : NSObject

/**
 *  The pointer to a delegate object. You must set it up right after the <code>+setup</code> been called.
 */
@property (nonatomic, weak, readonly) id <VTKScannerDelegateProtocol> delegate;

/**
 *  Contains the currently connected barcode scanner type
 */
@property (nonatomic, readonly) VTKScannerFramework activeScannerType;

/**
 *  Has the currenly connected scanner handler or nil if no scanner connected
 */
@property (nonatomic, strong, readonly) id <VTKBarcodeScannerProtocol> scanner;

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
- (void)setupScannerWithFramework: (VTKScannerFramework)framework
                     withDelegate: (id <VTKScannerDelegateProtocol>)delegate;

/**
 Sets up the scanner with given scanner object that must conform to the VTKBarcodeScannerProtocol protocol

 @param scanner An initialized scanner object
 @param delegate A delegate object
 */
- (void)setupScanner: (id<VTKBarcodeScannerProtocol>)scanner
   withFrameworkType: (VTKScannerFramework) framework
        withDelegate: (id<VTKScannerDelegateProtocol>)delegate;

@end
