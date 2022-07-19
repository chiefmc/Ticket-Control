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

@interface VTKMobilogicsScanner ()

@property (nonatomic, weak) MLScanner *scanner;

@end


@implementation VTKMobilogicsScanner

- (instancetype)init
{
    self = [super init];

    self.scanner = [MLScanner sharedInstance];
    [self.scanner setup];
    [self.scanner addAccessoryDidConnectNotification:self];
    [self.scanner addAccessoryDidDisconnectNotification:self];
    [self.scanner addReceiveCommandHandler:self];
    [self.scanner configSyncSwitch:YES];
    
    return self;
}

- (void)dealloc
{
    [self.scanner removeAccessoryDidConnectNotification:self];
    [self.scanner removeAccessoryDidDisconnectNotification:self];
    [self.scanner removeReceiveCommandHandler:self];
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
    return [self.scanner isConnected];
}

- (void)postponeBatteryRemain
{
    [self.scanner batteryRemain];
}

- (NSNumber *)getBatteryRemain
{
    if ([self isConnected]) {
        return [self.scanner batteryCapacity];
    }
    return @(-1);
}

- (void)invocateBarcodeScan
{
    [self.scanner scan];
}

- (void)chargeBatteryFromScanner
{
    [self.scanner chargeBattery];
}

- (void)turnBeepOn:(BOOL)yes
{
    [self.scanner beepSwitch:yes];
}

- (void)setScannerVibroLevel:(unsigned int)level
{
    [self.scanner vibraMotorStrength: level];
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
    [self.scanner updateAccessoryInfo];
}

- (BOOL)isBatteryOnCharge
{
    return [self.scanner batteryOnCharge];
}

-(void)reInitTheScannerDevice
{
    // Trying to re-initiazle the scanner if it is not responding. It might be necessary after a long sleep
    if (![self.scanner isConnected]) {
        self.scanner = [MLScanner sharedInstance];
    }
}

@end
