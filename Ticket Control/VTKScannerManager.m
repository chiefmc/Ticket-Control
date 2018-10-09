//
//  VTKScannerManager.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKConstants.h"
#import "VTKScannerManager.h"
#import "VTKBarcodeScanner.h"
//#import "VTKMobilogicsScanner.h" // Mobilogics scanner support has been dropped in v1.2 due to use libstc++.6.dylib, which is not supported by XCode anymore
#import "VTKInfinitePeripheralsScanner.h"
#import "VTKHoneywellScanner.h"
#import "VTKDummyScanner.h"

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

- (void)setupScannerWithFramework: (VTKScannerFramework)framework
                     withDelegate:(id <VTKScannerDelegate>)delegate
{
#if TEST_IPOD_WITHOUT_SCANNER == 1
    [self setupScanner:[[VTKDummyScanner alloc] init]
     withFrameworkType:framework
          withDelegate:delegate];
#else
    switch (framework) {
        case VTKBarcodeFrameworkAppleCamera:
            NSLog(@"Apple Camera must be initialized using setupScanner:withFrameworkType:withDelegate: method!");
            break;

            // Mobilogics framework support has been dropped since v1.2
/*      case VTKBarcodeFrameworkMobilogics:
            [self setupScanner:[[VTKMobilogicsScanner alloc] init]
             withFrameworkType:framework
                  withDelegate:delegate];
            break;
*/
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
            NSLog(@"Unrecognized ScannerFramework (%d)! Ignoring...", framework);
            break;
    }
    
    _activeScannerType = framework;
#endif
}

- (void)setupScanner: (id<VTKBarcodeScanner>)scanner
   withFrameworkType: (VTKScannerFramework) framework
        withDelegate:(id<VTKScannerDelegate>)delegate
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
