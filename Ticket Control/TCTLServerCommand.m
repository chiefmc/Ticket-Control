//
//  TCTLServerCommand.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLServerCommand.h"
#import "TCTLConstants.h"
#import <Foundation/Foundation.h>

@interface TCTLServerCommand ()

@property (weak, nonatomic) NSString	*guid;				// GUID клиента (может быть пустым)
@property (weak, nonatomic) NSURL		*serverURL;			// URL XML-RPC сервера
@property (weak, readonly) NSString		*barcode;			// штрих-код проверяемого билета (может быть пустым)

@end

@implementation TCTLServerCommand

+(id)sharedInstance {
    static TCTLServerCommand *sharedServerCommand = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServerCommand = [[self alloc] init];
    });
    return sharedServerCommand;
}

-(id)init
{
	return [super init];
}

-(void)initWithServer: (NSURL *)serverURL withCommand: (ServerCommand)serverCommand withGUID: (NSString *)guid withBarcode: (NSString *)barcode
{
	if (self) {
		_serverURL			= serverURL;
		_serverCommand		= serverCommand;
		_guid				= guid;
		_barcode			= barcode;
	}
}
// -------------------------------------------------------------------------
// Упаковывает данные в формат запроса и возращает его
// -------------------------------------------------------------------------
-(XMLRPCRequest *)packRequest
{
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:_serverURL];
	NSString *method = [[[NSString alloc] init] stringByAppendingFormat: @"0x%x", _serverCommand];
	
	// Проверяем данные на nil
	if (!_guid) {
		_guid = @"";
	}
	if (!_barcode) {
		_barcode = @"";
	}
	
	NSDictionary *parameters = @{GUID_KEY				:_guid,
								 BARCODE_KEY			:_barcode,
								 CLIENT_APP_VERSION_KEY	:APP_VERSION,
								 SERVER_API_VERSION_KEY	:API_VERSION};
	[request setMethod: method withParameter: parameters];
	
	[request setTimeoutInterval: XMLRPC_TIMEOUT];
	[request setUserAgent: XMLRPC_USER_AGENT];
	
	return request;
}

// -------------------------------------------------------------------------
// Распаковываем данные из XML-RPC ответа и возвращаем
// -------------------------------------------------------------------------
-(TCTLServerResponse *)unpackResponse:(id)xmlResponseObject
{
	TCTLServerResponse *response = [TCTLServerResponse alloc];
	NSDictionary *decodedXML = (NSDictionary *)xmlResponseObject;
	
	// Подготавливаем форматтер с шаблоном под дату/время стандарта ISO8601
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:ISO8601_DATETIME_FORMAT];

	NSString *responseCodeStr	= decodedXML[RESPONSE_CODE_KEY];
	NSScanner *scanner			= [NSScanner scannerWithString:responseCodeStr];
	unsigned int responseCodeInt;
	if ([scanner scanHexInt:&responseCodeInt]) {
		response.responseCode		= responseCodeInt;
		response.barcode			= decodedXML[BARCODE_KEY];
		response.userName			= decodedXML[USER_NAME_KEY];
		response.eventName			= decodedXML[EVENT_NAME_KEY];
		response.eventStart			= [dateFormat dateFromString:decodedXML[EVENT_START_KEY]];
		response.controlStart		= [dateFormat dateFromString:decodedXML[CONTROL_START_KEY]];
		response.controlEnd			= [dateFormat dateFromString:decodedXML[CONTROL_END_KEY]];
		response.agentChecked		= decodedXML[AGENT_CHECKED_KEY];
		response.timeChecked		= [dateFormat dateFromString:decodedXML[TIME_CHECKED_KEY]];
		response.clientNeedsUpdate	= [decodedXML[CLIENT_NEEDS_UPDATE_KEY] boolValue];
	} else {
		response.responseCode		= errorServerResponseUnkown;
	}
	return response;
}

// -------------------------------------------------------------------------
// Выполняет синхронно команду и фиксирует результат
// -------------------------------------------------------------------------
-(void)doSendCommand: (id<XMLRPCConnectionDelegate>)delegate
{
	XMLRPCConnectionManager *xmlManager = [XMLRPCConnectionManager sharedManager];
	
	[xmlManager spawnConnectionWithXMLRPCRequest: [self packRequest] delegate:delegate];
}

@end
