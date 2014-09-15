//
//  TCTLScannerHAL.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 05.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeScannerHAL.h"

@implementation VTKBarcodeScannerHAL

+(instancetype)sharedInstance {
    static VTKBarcodeScannerHAL *scannerHAL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scannerHAL = [[self alloc] init];
    });
    return scannerHAL;
}

- (void)connectNotify
{
	
}

- (void)disconnectNotify
{
	
}

- (void)handleRequest:(NSObject <ReceiveCommandProtocol> *)command
{
	
}

- (void)handleInformationUpdate
{
	
}

// ------------------------------------------------------------------------------
// Replies to MLBarcode frameword that it is able to handle the requests
// ------------------------------------------------------------------------------
- (BOOL)isHandler:(NSObject <ReceiveCommandProtocol> *)command
{
#ifdef DEBUG
	NSLog(@"isHandler received");
#endif
	
	if ([command isKindOfClass:[ReceiveCommand class]]) {
		return TRUE;
	}
	
	return FALSE;
}

@end
