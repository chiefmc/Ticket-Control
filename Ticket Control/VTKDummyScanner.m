//
//  VTKDummyScanner.m
//  Ticket Control
//
//  Created by Yevgen Lysenko on 10/8/18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

#import "VTKDummyScanner.h"

@implementation VTKDummyScanner

- (instancetype)init
{
    self = [super init];
    return self;
}

#pragma mark VTKBarcodeScannerProtocol delegate methods

- (NSNumber *)getBatteryRemain {
    return @(100);
}

- (void)invocateBarcodeScan {
    // dummy
}

- (BOOL)isConnected {
    return YES;
}

- (BOOL)isBatteryOnCharge
{
    return NO;
}

- (void)chargeBatteryFromScanner
{
    // dummy
}

- (void)turnBeepOn: (BOOL)yes
{
    // dummy
}

- (void)setScannerVibroLevel: (unsigned int)level
{
    // dummy
}

- (void)wakeup
{
    // dummy
}

- (void)updateAccessoryInfo
{
    // dummy
}

@end
