//
//  VTKMobilogicsScanner.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKMobilogicsScanner.h"
#import "VTKScannerManager.h"
#import <MobilogicsCore/Framework.h>
#import <Barcode/Framework.h>

@implementation VTKMobilogicsScanner

- (instancetype)init
{
    self = [super init];
    
    [[MLScanner sharedInstance] setup];
    [[MLScanner sharedInstance] addAccessoryDidConnectNotification:self];
    [[MLScanner sharedInstance] addAccessoryDidDisconnectNotification:self];
    [[MLScanner sharedInstance] addReceiveCommandHandler:self];
    [[MLScanner sharedInstance] configSyncSwitch:YES];
    
    return self;
}

- (void)dealloc
{
    [[MLScanner sharedInstance] removeAccessoryDidConnectNotification:self];
    [[MLScanner sharedInstance] removeAccessoryDidDisconnectNotification:self];
    [[MLScanner sharedInstance] removeReceiveCommandHandler:self];
}

#pragma mark Delegate methods
- (BOOL)isHandler:(NSObject <ReceiveCommandProtocol> *)command
{
    if ([command isKindOfClass:[ReceiveCommand class]]) {
        return TRUE;
    }
    
    return FALSE;
}

- (void)disconnectNotify
{
    [self.delegate scannerDisconnectedNotification];
}

- (void)connectNotify
{
    [self.delegate scannerConnectedNotification];
}

- (void)handleInformationUpdate
{
    [self.delegate scannerInformationUpdateNotification];
}

- (void)handleLowPower
{
    [self.delegate scannerLowPowerNotification];
}

- (void)handleRequest:(ReceiveCommand *)command
{
    NSString *scannedString = [command receiveString];
    
    // Trimming the scanned string from CRLF in the end
    scannedString = [scannedString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    [self.delegate scannerBarcodeScannedNotification:scannedString];
}

#pragma mark overriden methods

- (BOOL)isConnected
{
    return [[MLScanner sharedInstance] isConnected];
}

- (NSNumber *)getBatteryRemain
{
    MLScanner *scanner;
    scanner = [MLScanner sharedInstance];
    [scanner batteryRemain];
    
    //TODO: надо это в отдельный метод снести
    NSNumber *batRemain;
    
    if ([self isConnected]) {
        batRemain = [[MLScanner sharedInstance] batteryCapacity];
    } else {
        batRemain = @(-1);
    }
    return batRemain;
}

- (void)invocateBarcodeScan
{
    [[MLScanner sharedInstance] scan];
}

- (void)chargeBatteryFromScanner
{
    [[MLScanner sharedInstance] chargeBattery];
}

- (void)turnBeepOn:(BOOL)yes
{
    [[MLScanner sharedInstance] beepSwitch:yes];
}

- (void)setScannerVibroLevel:(unsigned int)level
{
    [[MLScanner sharedInstance] vibraMotorStrength: level];
}

- (void)wakeup
{
    // Scheduling the reinizialization of the scanner hardware
    [self performSelector:@selector(reInitTheScannerDevice)
               withObject:nil
               afterDelay:5.0f];
}

- (void)updateAccessoryInfo
{
    [[MLScanner sharedInstance] updateAccessoryInfo];
}

- (BOOL)isBatteryOnCharge
{
    return [[MLScanner sharedInstance] batteryOnCharge];
}

-(void)reInitTheScannerDevice
{
    // Trying to re-initiazle the scanner if it is not responding. It might be necessary after a long sleep
    if (![[MLScanner sharedInstance] isConnected]) {
        [MLScanner sharedInstance];
    }
}

@end
