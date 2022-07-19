//
//  VTKServerAPI.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 11.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKServerAPI.h"
#import "VTKSettings.h"
#import "VTKConstants.h"
#import "AFJSONRPCClient.h"

@implementation VTKServerAPI

#pragma mark Singleton methods

+(instancetype)manager
{
    static VTKServerAPI *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] privateInit];
        // Setting the minimum available version of API to use as a start
        manager.APIVersionInUse = API_MIN_VERSION;
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

/**
 *  Setter for the APIVersionInUse. The API's only permitted values are either API_VERSION or API_MIN_VERSION macros.
 *
 *  @param APIVersionInUse Checks the value for validity. Throws exception if its not recognized.
 */
- (void)setAPIVersionInUse:(NSString *)APIVersionInUse
{
    if ([APIVersionInUse isEqualToString: API_MIN_VERSION] || [APIVersionInUse isEqualToString: API_VERSION]) {
        _APIVersionInUse = API_VERSION;
    } else {
        @throw [NSException exceptionWithName:@"Wrong API version supplied!"
                                       reason:@"Please use either API_VERSION or API_MIN_VERSION macros to set the API version."
                                     userInfo:nil];
    }
}

#pragma mark private core methods

/**
 *  Prepares the request to server API with the specified parameters.
 *
 *  @param barcode The barcode to be checked
 *
 *  @return NSDictionary with the prepared request
 */
- (NSDictionary *)prepareRequestWithBarcode: (NSString *)barcode
{
    NSString *guid = [VTKSettings storage].userGUID;
    // Проверяем данные
    if (!guid) {
        guid = @"";
    }
    if (!barcode) {
        barcode = @"";
    }
    
    NSDictionary *parameters = @{GUID_KEY				:guid,
                                 BARCODE_KEY			:barcode,
                                 CLIENT_APP_VERSION_KEY	:APP_VERSION,
                                 SERVER_API_VERSION_KEY	:API_VERSION};
    return parameters;
}

/**
 *  Prepares the request to server API with no extra parameters (just the GUID and API versions are included)
 *
 *  @return NSDictionary with the prepared request
 */
- (NSDictionary *)prepareEmptyRequest
{
    NSString *guid = [VTKSettings storage].userGUID;
    // Проверяем данные
    if (!guid) {
        guid = @"";
    }
    
    NSDictionary *parameters = @{GUID_KEY				:guid,
                                 CLIENT_APP_VERSION_KEY	:APP_VERSION,
                                 SERVER_API_VERSION_KEY	:self.APIVersionInUse};
    return parameters;
}

/**
 *  Executes the specified command with the JSON-RPC interface and calls appropriate block upon completetion.
 *
 *  @param method     The method to be executed
 *  @param parameters The NSDictionary of parameters sent along with the request
 *  @param success    Success block to be executed upon a successful execution
 *  @param failure    Failure block to be executed upon a failure.
 */
-(void)executeMethod:(NSString *)method
      withParameters:(NSDictionary *)parameters
             success:(void(^)(id responseObject))success
             failure:(void(^)(NSError *error))failure;
{
    AFJSONRPCClient *jsonClient = [AFJSONRPCClient clientWithEndpointURL:[VTKSettings storage].serverURL];
    
//    NSString *method = [[NSString new] stringByAppendingFormat: @"0x%x", self.serverCommand];
    [jsonClient invokeMethod:method
              withParameters:parameters
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

/**
 *  Converts the number to a string in hex format (with 0x prefix)
 *
 *  @param hex The number to be converted
 *
 *  @return The resulting NSString
 */
- (NSString *)convertHexToString:(unsigned int)hex
{
    NSString *converted = [[NSString new] stringByAppendingFormat: @"0x%x", hex];
    return converted;
}

#pragma mark API v1.0+ methods

-(void)noOpWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = [self prepareEmptyRequest];
    NSString *method = [self convertHexToString:VTKAPI10MethodNoOp];
    [self executeMethod:method
         withParameters:params
                success:success
                failure:failure];
}

- (void)getCurrentUserNameWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = [self prepareEmptyRequest];
    NSString *method = [self convertHexToString:VTKAPI10MethodGetCurrentUserName];
    [self executeMethod:method
         withParameters:params
                success:success
                failure:failure];
}

- (void)getNearestEventWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = [self prepareEmptyRequest];
    NSString *method = [self convertHexToString:VTKAPI10MethodGetNearestEvent];
    [self executeMethod:method
         withParameters:params
                success:success
                failure:failure];
}

- (void)validateBarcode:(NSString *)barcode WithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = [self prepareRequestWithBarcode:barcode];
    NSString *method = [self convertHexToString:VTKAPI10MethodValidateBarcode];
    [self executeMethod:method
         withParameters:params
                success:success
                failure:failure];
}

#pragma mark API v2.0+ methods

@end
