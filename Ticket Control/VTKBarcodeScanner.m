//
//  VTKBarcodeScanner.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 05.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeScanner.h"

@implementation VTKBarcodeScanner

- (instancetype)init
{
    return [super init];
}

- (BOOL)isConnected
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (NSNumber *)batteryRemain
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (void)invocateBarcodeScan
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (NSString *)scanWithCamera
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (void)chargeBatteryFromScanner
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (void)turnBeepOn: (BOOL)yes
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (void)setScannerVibroLevel: (unsigned int)level
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];
}

- (void)wakeup
{
    @throw [NSException exceptionWithName:@"Abstract class"
                                   reason:@"You're calling a method from an abstract class. Please use a child class instead."
                                 userInfo:nil];    
}
@end
