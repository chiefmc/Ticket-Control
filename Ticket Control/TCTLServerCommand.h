//
//  TCTLServerCommand.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTLServerResponse.h"
#import <XMLRPC/XMLRPC.h>

// -----------------------------------------------------------
// API обмена данными с билетным сервером
// Версия 1.0
// -----------------------------------------------------------


// Команды отправляемые билетному серверу
typedef NS_ENUM(unsigned int, ServerCommand) {
	noOp						= 0x100,	// отсутствие действий
	getUserName					= 0x110,	// запрашивает текстовое имя текущего контролёра
	getActiveEvent				= 0x120,	// запрашивает активное событие, на которое можно осуществлять контроль
	getCodeResult				= 0x200,	// отсылает серверу на проверку штрих-код
};

@interface TCTLServerCommand : NSObject

@property (readonly) ServerCommand		serverCommand;		// метод (команда) посылаемая серверу

// Class method (singleton)
+(id)sharedInstance;

// Initializers
-(id)init;
-(void)initWithServer: (NSURL *)serverURL
		  withCommand: (ServerCommand)
serverCommand withGUID: (NSString *) guid
		  withBarcode: (NSString *) barcode;

// Invoking the prepared command to the JSON-RPC command and calls blocks
-(void)doPreparedCommandWithJSONsuccess:(void(^)(id responseObject))success
								failure:(void(^)(NSError *error))failure;

// Unpacking data from XML-RPC/JSON-RPC response and sending back
-(TCTLServerResponse *)unpackResponse:(id)responseObject;

// Возвращает полученный ответ от сервера или nil, если не операция окончилась ошибкой
//-(TCTLServerResponse *)getServerResponse;

@end
