//
//  VTKScannerManager.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKScannerManager.h"
#import "VTKBarcodeScannerProtocol.h"
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

- (void)setupScannerWithFramework: (VTKScannerFramework)framework withDelegate:(id <VTKScannerDelegateProtocol>)delegate
{
    switch (framework) {
        case VTKBarcodeFrameworkMobilogics:
            [self setupScanner:[[VTKMobilogicsScanner alloc] init]
             withFrameworkType:framework
                  withDelegate:delegate];
            break;
            
        case VTKBarcodeFrameworkHoneywell:
            [self setupScanner:[[VTKHoneywellScanner alloc] init]
             withFrameworkType:framework
                  withDelegate:delegate];
            break;
            
        case VTKBarcodeFrameworkInfinitePeripherals:
            [self setupScanner:[[VTKInfinitePeripheralsScanner alloc] init]
             withFrameworkType:framework
                  withDelegate:delegate];
            break;
            
        default:
            NSLog(@"Unrecognized ScannerFramework! Ignoring...");
            break;
    }
    
    _activeScannerType = framework;
}

- (void)setupScanner: (id<VTKBarcodeScannerProtocol>)scanner
   withFrameworkType: (VTKScannerFramework) framework
        withDelegate:(id<VTKScannerDelegateProtocol>)delegate
{
    if (scanner) {
        _scanner = scanner;
        _scanner.delegate = delegate;
        _activeScannerType = framework;
    } else {
        NSLog(@"Tried to call setupScanner: withDelegate: with nil scanner! ");
    }
}

@end
