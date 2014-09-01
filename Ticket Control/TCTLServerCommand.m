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
#import "XMLDictionary.h"

@interface TCTLServerCommand ()

@property (strong, nonatomic) NSString	*guid;				// GUID клиента (может быть пустым)
@property (strong, nonatomic) NSURL		*serverURL;			// URL XML-RPC сервера

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
		//_serverResponse		= nil;
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
	
#ifdef DEBUG
	NSLog(@"XMLRPC encoded body: %@", [request body]);
#endif
	
	return request;
}

// -------------------------------------------------------------------------
// Распаковываем данные из XML-RPC ответа и возвращаем
// -------------------------------------------------------------------------
-(TCTLServerResponse *)unpackResponse:(XMLRPCResponse *)xmlResponse
{
	TCTLServerResponse *response = [TCTLServerResponse alloc];
	
	// Если XMLRPC вернул пустой ответ
	if (!xmlResponse) {
		response.responseCode		= errorNetworkError;
	} else {
#ifdef DEBUG
		NSLog(@"xmlResponse from server: %@", [xmlResponse body]);
#endif
		// Если обработка XMLRPC вернула ошибку, то...
		if ([xmlResponse isFault]) {
			response.responseCode		= errorNetworkError;
			response.errorCode			= xmlResponse.faultCode;
			response.errorDescription	= xmlResponse.faultString;
		} else {
			NSDictionary *decodedXML = [NSDictionary dictionaryWithXMLString:[xmlResponse body]];
#ifdef DEBUG
			// NSLog(@"unpackResponse XML into: %@", decodedXML);
#endif
			// Подготавливаем форматтер с шаблоном под дату/время стандарта ISO8601
			NSDateFormatter *dateFormat = [NSDateFormatter new];
			[dateFormat setDateFormat:@"yyyyMMdd'T'HH':'mm':'ss"];
			
			response.responseCode		= [[decodedXML objectForKey:RESPONSE_CODE_KEY] integerValue];
			response.barcode			= [[decodedXML objectForKey:BARCODE_KEY] stringValue];
			response.userName			= [[decodedXML objectForKey:USER_NAME_KEY] stringValue];
			response.eventName			= [[decodedXML objectForKey:EVENT_NAME_KEY] stringValue];
			response.eventStart			= [dateFormat dateFromString:[[decodedXML objectForKey:EVENT_START_KEY] stringValue]];
			response.controlStart		= [dateFormat dateFromString:[[decodedXML objectForKey:CONTROL_START_KEY] stringValue]];
			response.controlEnd			= [dateFormat dateFromString:[[decodedXML objectForKey:CONTROL_END_KEY] stringValue]];
			response.agentChecked		= [[decodedXML objectForKey:AGENT_CHECKED_KEY] stringValue];
			response.timeChecked		= [dateFormat dateFromString:[[decodedXML objectForKey:TIME_CHECKED_KEY] stringValue]];
			response.clientNeedsUpdate	= [[decodedXML objectForKey:CLIENT_NEEDS_UPDATE_KEY] boolValue];
		}
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
/*
#ifdef DEBUG
	// Возвращаем фиксированный результат, если дебажим
	switch (_serverCommand) {
		case noOp:
			_serverResponse.responseCode = resultOk;
			break;
			
		case getCodeResult:
			_serverResponse.responseCode = accessAllowed;
			break;
			
		default:
			_serverResponse.responseCode = errorNetworkError;
			break;
	}
#endif */
}

/*
-(TCTLServerResponse *)getServerResponse
{
	return _serverResponse;
} 
*/

@end
