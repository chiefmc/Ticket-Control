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
#import <AFJSONRPCClient/AFJSONRPCClient.h>
#import <xmlrpc/XMLRPC.h>

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
// Packing data into NSDictionary
// -------------------------------------------------------------------------
- (NSDictionary *)packParameters
{
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
	return parameters;
}

// -------------------------------------------------------------------------
// Packing data into XML request
// -------------------------------------------------------------------------
-(XMLRPCRequest *)packXMLRequest
{
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL:_serverURL];
	NSString *method = [[NSString new] stringByAppendingFormat: @"0x%x", _serverCommand];
	
	NSDictionary *parameters = [self packParameters];
	[request setMethod: method withParameter: parameters];
	
	[request setTimeoutInterval: XMLRPC_TIMEOUT];
	[request setUserAgent: XMLRPC_USER_AGENT];
	
	return request;
}

// -------------------------------------------------------------------------
// Unpacking data from XML-RPC/JSON-RPC response and sending back
// -------------------------------------------------------------------------
-(TCTLServerResponse *)unpackResponse:(id)responseObject
{
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		NSDictionary *decodedResponse	= (NSDictionary *)responseObject;

		TCTLServerResponse *response = [TCTLServerResponse alloc];
		
		// Preparing formatter with pre-set date/time format
		NSDateFormatter *dateFormat = [NSDateFormatter new];
		[dateFormat setDateFormat:DATETIME_LOG_FORMAT];

		NSString *responseCodeStr	= decodedResponse[RESPONSE_CODE_KEY];
		NSScanner *scanner			= [NSScanner scannerWithString:responseCodeStr];
		unsigned int responseCodeInt;
		if ([scanner scanHexInt:&responseCodeInt]) {
			response.responseCode		= responseCodeInt;
			response.barcode			= decodedResponse[BARCODE_KEY];
			response.userName			= decodedResponse[USER_NAME_KEY];
			response.eventName			= decodedResponse[EVENT_NAME_KEY];
			response.eventStart			= [dateFormat dateFromString:decodedResponse[EVENT_START_KEY]];
			response.controlStart		= [dateFormat dateFromString:decodedResponse[CONTROL_START_KEY]];
			response.controlEnd			= [dateFormat dateFromString:decodedResponse[CONTROL_END_KEY]];
			response.agentChecked		= decodedResponse[AGENT_CHECKED_KEY];
			response.timeChecked		= [dateFormat dateFromString:decodedResponse[TIME_CHECKED_KEY]];
			response.clientNeedsUpdate	= [decodedResponse[CLIENT_NEEDS_UPDATE_KEY] boolValue];
		} else {
			response.responseCode		= errorServerResponseUnkown;
		}
		return response;
	} else return nil;
}

// -------------------------------------------------------------------------
// Sending an async XML-RPC command
// -------------------------------------------------------------------------
-(void)doPreparedCommandWithXMLdelegate: (id<XMLRPCConnectionDelegate>)delegate
{
	XMLRPCConnectionManager *xmlManager = [XMLRPCConnectionManager sharedManager];
	
	[xmlManager spawnConnectionWithXMLRPCRequest:[self packXMLRequest]
										delegate:delegate];
}

// -------------------------------------------------------------------------
// Invoking the prepared command to the JSON-RPC command and callback blocks
// -------------------------------------------------------------------------
-(void)doPreparedCommandWithJSONsuccess:(void(^)(id responseObject))success
								failure:(void(^)(NSError *error))failure;
{
	AFJSONRPCClient *jsonClient = [AFJSONRPCClient clientWithEndpointURL:_serverURL];
	
	NSString *method = [[NSString new] stringByAppendingFormat: @"0x%x", _serverCommand];
	[jsonClient invokeMethod:method
			  withParameters:[self packParameters]
					 success:^(AFHTTPRequestOperation *operation, id responseCode) {
#ifdef DEBUG
						 NSLog(@"JSON-RPC success. Response code: %@\nOperation: %@", responseCode, operation.responseObject);
#endif
						 success(operation.responseObject);
					 }
					 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
						 NSLog(@"JSON-RPC failure! Operation: %@\n Error: %@", operation, error);
#endif
						 failure(error);
					 }];
}
@end
