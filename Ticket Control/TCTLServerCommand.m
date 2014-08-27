//
//  TCTLServerCommand.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLServerCommand.h"
#import "TCTLConstants.h"
#import <XMLRPC.h>

@interface TCTLServerCommand ()

@property (strong, nonatomic) NSString	*guid;				// GUID клиента (может быть пустым)
@property (strong, nonatomic) NSString	*clientAPPVersion;	// Версия приложения
@property (strong, nonatomic) NSString	*serverAPIVersion;	// Ожидаемая версия API от сервера

@end

@implementation TCTLServerCommand

-(id)init
{
	return [self initWithCommand: noOp withGUID: @"" withBarcode: @""];
}

-(id)initWithCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid
{
	return [self initWithCommand: serverCommand withGUID: guid withBarcode: @""];
}

-(id)initWithCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid withBarcode: (NSString *) barcode
{
	self = [super init];
	
	if (self) {
		_serverCommand		= serverCommand;
		_guid				= guid;
		_barcode			= barcode;
		_clientAPPVersion	= clientAPPVersion;
		_serverAPIVersion	= serverAPIVersion;
		_serverResponse		= nil;
	}
	return self;
}

-(void)doSendCommand
{
	_serverResponse = [TCTLServerQueryResponse alloc];
#ifdef DEBUG
	// Возвращаем фиксированный результат, если дебажим
	_serverResponse.responseCode = accessAllowed;
#endif
}

-(TCTLServerQueryResponse *)getServerResponse
{
	return self.serverResponse;
}

@end
