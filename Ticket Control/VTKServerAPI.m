//
//  VTKServerAPI.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 11.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKServerAPI.h"
#import "TCTLSettings.h"

@implementation VTKServerAPI

+(instancetype)manager
{
    static VTKServerAPI *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] privateInit];
    });
    return manager;
}

/**
 *  This method must not be called as this is a Singleton-type object
 *  Will throw exception on compile.
 *
 *  @return None
 */
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Wrong usage of singleton object"
                                   reason:@"You're trying to init the signleton object. Please use the +manager instead."
                                 userInfo:nil];
}

- (instancetype)privateInit
{
    return [super init];
}

@end
