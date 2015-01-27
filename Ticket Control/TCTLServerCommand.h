//
//  TCTLServerCommand.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;
#import "TCTLServerResponse.h"

// --------------------------------------------------------------
// This class implements a Ticket server exchange API
// Current supported API version 1.0
// --------------------------------------------------------------

/**
 *  Contains commands sent to a Ticketing server
 */
typedef NS_ENUM(unsigned int, ServerCommand) {
    noOp           = 0x100,// отсутствие действий
    getUserName    = 0x110,// запрашивает текстовое имя текущего контролёра
    getActiveEvent = 0x120,// запрашивает активное событие, на которое можно осуществлять контроль
    getCodeResult  = 0x200,// отсылает серверу на проверку штрих-код
};

/**
 *  Controller class that opearates JSON-RPC commands to a Ticketing server. 
 *	This class is a singleton. Call the +(instancetype)sharedInstance to
 *	operate the class.
 */
@interface TCTLServerCommand : NSObject

/**
 *  The command the object was initialized with, that is sent to a Ticketing server
 */
@property (readonly, nonatomic) ServerCommand serverCommand;

/**
 *  The class method (singleton)
 *
 *  @return Returns the sharedInsrance of the class to opearate with.
 */
+ (instancetype)sharedInstance;

/**
 *  Since this is a singleton class, the init shouldn't be called directly.
 *	Use +(instancetype)sharedInstance
 *
 *  @return The method throws exception and doesn't return anything.
 */
- (id)init;

/**
 *  Prepares the class for each opearation with given parameters.
 *
 *  @param serverURL     The URL of the server the command will be executed with
 *  @param serverCommand The command to be executed
 *  @param guid          The GUID of the device, that is used to authorize at the server
 *  @param barcode       The barcode of the ticket to check (if the command needs it)
 */
- (void)prepareWithServer: (NSURL *)serverURL
			  withCommand: (ServerCommand)
	serverCommand withGUID: (NSString *) guid
			  withBarcode: (NSString *) barcode;

/**
 *  Invokes the prepared command to the JSON-RPC command and calls blocks
 *
 *  @param success A block that gets executed if the JSON-RPC ends with success,
 *	the responseObject is an NSDictionary that contains the result
 *  @param failure A block that gets executed if the JSON-RPC fails,
 *	the *error is an NSError that contains the error
 */
- (void)doPreparedCommandWithJSONsuccess:(void(^)(id responseObject))success
								 failure:(void(^)(NSError *error))failure;

/**
 *  Unpacks the data from JSON-RPC response and returns the result.
 *
 *  @param responseObject - the dictionary that is returned after the JSON-RPC call
 *
 *  @return Returns a response unpacked into a TCTLServerResponse
 */
- (TCTLServerResponse *)unpackResponse:(id)responseObject;

@end
