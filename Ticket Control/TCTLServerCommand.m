//
//  TCTLServerCommand.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLServerCommand.h"
#import "TCTLConstants.h"
#import <AFJSONRPCClient/AFJSONRPCClient.h>

@interface TCTLServerCommand ()

@property (nonatomic, copy  ) NSString *guid;// client's GUID (may be empty with some methods)
@property (nonatomic, strong) NSURL    *serverURL;// URL XML-RPC сервера
@property (readonly, copy   ) NSString *barcode;// штрих-код проверяемого билета (может быть пустым)

@end

@implementation TCTLServerCommand

+(instancetype)sharedInstance {
    static TCTLServerCommand *sharedServerCommand = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServerCommand = [[self alloc] privateInit];
    });
    return sharedServerCommand;
}

/**
 *  This is a private init method
 *
 *  @return Returns initialized instance
 */
-(instancetype)privateInit
{
	return [super init];
}

/**
 *  This is a dummy method, overriding the inherited one. Throws an exception if called. This method shouldn't be called. User +sharedStorage instead.
 *
 *  @return This method is a dummy method. Will throw exception upon call
 */
-(instancetype)init
{
	@throw [NSException exceptionWithName:@"Singleton"
								   reason:@"This classs is designed for singleton use. Use +shareInstance instead."
								 userInfo:nil];
}

-(void)prepareWithServer: (NSURL *)serverURL
			 withCommand: (ServerCommand)serverCommand
				withGUID: (NSString *)guid
			 withBarcode: (NSString *)barcode
{
	if (self) {
        _serverURL     = serverURL;
        _serverCommand = serverCommand;
        _guid          = guid;
        _barcode       = barcode;
	}
}

// -------------------------------------------------------------------------
// Packing data into NSDictionary
// -------------------------------------------------------------------------
- (NSDictionary *)packParameters
{
	// Проверяем данные на nil
	if (!self.guid) {
		_guid = @"";
	}
	if (!self.barcode) {
		_barcode = @"";
	}
	
	NSDictionary *parameters = @{GUID_KEY				:_guid,
								 BARCODE_KEY			:_barcode,
								 CLIENT_APP_VERSION_KEY	:APP_VERSION,
								 SERVER_API_VERSION_KEY	:API_VERSION};
	return parameters;
}

// -------------------------------------------------------------------------
// Unpacking data from JSON-RPC response and returning the result
// -------------------------------------------------------------------------
-(TCTLServerResponse *)unpackResponse:(id)responseObject
{
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		// Getting inner [params] dictionary
		NSDictionary *decodedResponse	= [(NSDictionary *)responseObject objectForKey:@"params"];

		TCTLServerResponse *response = [TCTLServerResponse alloc];
		
		// Preparing formatter with pre-set date/time format
		NSDateFormatter *dateFormat = [NSDateFormatter new];
		[dateFormat setDateFormat:DATETIME_SERVER_FORMAT];

		// Getting server response code from [params]
		NSString *responseCodeStr	= decodedResponse[RESPONSE_CODE_KEY];
		
		// Checking the response code string for nil
		if (!responseCodeStr) return nil;
		
		// Getting the hex value from the resonseCode string
		NSScanner *scanner			= [NSScanner scannerWithString:responseCodeStr];
		unsigned int responseCodeInt;
		if ([scanner scanHexInt:&responseCodeInt]) {
            response.responseCode      = responseCodeInt;
            response.barcode           = decodedResponse[BARCODE_KEY];
            response.userName          = decodedResponse[USER_NAME_KEY];
            response.eventName         = decodedResponse[EVENT_NAME_KEY];
            response.eventStart        = [dateFormat dateFromString:decodedResponse[EVENT_START_KEY]];
            response.controlStart      = [dateFormat dateFromString:decodedResponse[CONTROL_START_KEY]];
            response.controlEnd        = [dateFormat dateFromString:decodedResponse[CONTROL_END_KEY]];
            response.agentChecked      = decodedResponse[AGENT_CHECKED_KEY];
            response.timeChecked       = [dateFormat dateFromString:decodedResponse[TIME_CHECKED_KEY]];
            response.clientNeedsUpdate = [decodedResponse[CLIENT_NEEDS_UPDATE_KEY] boolValue];
		} else {
			response.responseCode = errorServerResponseUnkown;
		}
		return response;
	} else return nil;
}

// -------------------------------------------------------------------------
// Invoking the prepared command to the JSON-RPC command and callback blocks
// -------------------------------------------------------------------------
-(void)doPreparedCommandWithJSONsuccess:(void(^)(id responseObject))success
								failure:(void(^)(NSError *error))failure;
{
	AFJSONRPCClient *jsonClient = [AFJSONRPCClient clientWithEndpointURL:self.serverURL];
	
	NSString *method = [[NSString new] stringByAppendingFormat: @"0x%x", self.serverCommand];
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
