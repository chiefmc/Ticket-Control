//
//  VTKScannerManager.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKScannerManager.h"
#import "VTKBarcodeScanner.h"
#import "VTKAppleCameraScanner.h"
#import "VTKMobilogicsScanner.h"
#import "VTKInfinitePeripheralsScanner.h"
#import "VTKHoneywellScanner.h"

@implementation VTKScannerManager

+ (instancetype)sharedInstance
{
    static VTKScannerManager *scannerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scannerManager = [[self alloc] privateInit];
    });
    return scannerManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Wrong usage of singleton object"
                                   reason:@"You're trying to init the signleton object. Please use the +sharedInstance instead."
                                 userInfo:nil];
}

- (instancetype)privateInit
{
    return [super init];
}

- (void)setupScannerFramework: (VTKScannerFramework)framework withDelegate:(id <VTKScannerDelegate>)delegate
{
    _delegate = delegate;
    
    switch (framework) {
        case VTKBarcodeFrameworkAppleCamera:
            _connectedScanner = [[VTKAppleCameraScanner alloc] init];
            break;
            
        case VTKBarcodeFrameworkMobilogics:
            _connectedScanner = [[VTKMobilogicsScanner alloc] init];
            break;
            
        case VTKBarcodeFrameworkHoneywell:
            _connectedScanner = [[VTKHoneywellScanner alloc] init];
            break;
            
        case VTKBarcodeFrameworkInfinitePeripherals:
            _connectedScanner = [[VTKInfinitePeripheralsScanner alloc] init];
            break;
            
        default:
            break;
    }
    
    _activeScannerType = framework;
    
    // Forwarding the delegate directly to the scanner handler
    self.connectedScanner.delegate = self.delegate;
}

- (void)scan
{
    if (self.connectedScanner) {
        [self.connectedScanner invocateBarcodeScan];
    }
}

- (NSString *)scanWithCamera
{
    //TODO: Not implemented yet
    return @"1234567890123";
}

- (void)wakeup
{
    if (self.connectedScanner) {
        [self.connectedScanner wakeup];
    }
}

@end
