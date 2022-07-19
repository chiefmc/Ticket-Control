//
//  VTKInfinitePeripheralsScanner.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 08.02.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKInfinitePeripheralsScanner.h"

@interface VTKInfinitePeripheralsScanner ()

@property (nonatomic, weak) DTDevices *scanner;
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) NSTimer* batteryCheckTimer;

@end

@implementation VTKInfinitePeripheralsScanner

- (instancetype)init
{
    self = [super init];

    self.connected = NO;
    self.scanner = [DTDevices sharedDevice];
    [self.scanner addDelegate:self];
    [self.scanner connect];
    self.batteryCheckTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                              target:self
                                                            selector:@selector(postponeBatteryRemain)
                                                            userInfo:nil
                                                             repeats:YES];
    return self;
}

- (void)dealloc
{
    [self.scanner disconnect];
    [self.scanner removeDelegate:self];
    self.delegate = nil;
    self.scanner = nil;
    self.batteryCheckTimer = nil;
}

#pragma mark VTKBarcodeScannerProtocol delegate methods

- (void)postponeBatteryRemain
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scannerInformationUpdateNotification)])
    [self.delegate scannerInformationUpdateNotification];
}

- (NSNumber *)getBatteryRemain
{
    DTBatteryInfo *batteryInfo = [self.scanner getBatteryInfo:nil];
    int currentCapacity = [batteryInfo capacity];
#ifdef DEBUG
    NSLog(@"Received battery level: %d", currentCapacity);
#endif
    if ([self isConnected]) {
        // If the device's battery voltage has dropped below 5% we need to notify the user
        if (currentCapacity <= 5 &&
            self.delegate &&
            [self.delegate respondsToSelector:@selector(scannerLowPowerNotification)]) {
            [self.delegate scannerLowPowerNotification];
        }
        return [NSNumber numberWithInt:currentCapacity];
    }
    return @(-1);
}

- (NSTimeInterval)getTimeRemainingToPowerOff
{
    NSTimeInterval timeRemaining;
    [self.scanner getTimeRemainingToPowerOff:&timeRemaining
                                       error:nil];
    return timeRemaining;
}

- (void)invocateBarcodeScan
{
    [self.scanner barcodeStartScan:nil];
    [self performSelector:@selector(stopBarcodeScan)
               withObject:self
               afterDelay:1.0f];
}

- (void)stopBarcodeScan
{
    if (self.scanner && [self.scanner respondsToSelector: @selector(barcodeStopScan:)]) {
        [self.scanner barcodeStopScan:nil];
    }
}

- (BOOL)isConnected {
    return self.connected;
}

- (BOOL)isBatteryOnCharge
{
    DTBatteryInfo *batteryInfo = [self.scanner getBatteryInfo:nil];
    return batteryInfo.charging;
}

- (void)chargeBatteryFromScanner
{
    [self.scanner setCharging:YES
                        error:nil];
}

- (void)turnBeepOn: (BOOL)yes
{

}

- (void)setScannerVibroLevel: (unsigned int)level
{

}

- (void)wakeup
{
    [self.scanner connect];
}

- (void)updateAccessoryInfo
{

}

#pragma mark DTDeviceDelegate delegate methods

- (void)barcodeData:(NSString *)barcode type:(int)type
{
    // You can use this data as you wish
    // Here I write barcode data into the console
#ifdef DEBUG
    NSLog(@"Barcode data: %@", barcode);
#endif
    [self.delegate scannerBarcodeScannedNotification: barcode];
}

/**
 Delegate method, being called upon hardware connect actions

 @param state Shows current hardware connection state
 */
- (void)connectionState:(int)state {
    switch (state) {
        case CONN_DISCONNECTED:
            self.connected = NO;
            [self.delegate scannerDisconnectedNotification];
            break;
        case CONN_CONNECTING:
            self.connected = NO;
            [self.delegate scannerDisconnectedNotification];
            break;
        case CONN_CONNECTED:
            self.connected = YES;
            [self.delegate scannerConnectedNotification];
            break;
    }
}

-(void)deviceButtonPressed:(int)which
{
#ifdef DEBUG
    NSLog(@"Scanner button was pressed: %d", which);
#endif
}

@end
