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

// Синглтон
+(id)sharedInstance;

// Инициализаторы объекта
-(id)init;
//-(id)initWithServer: (NSURL *)serverURL withCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid;
-(void)initWithServer: (NSURL	*)serverURL withCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid withBarcode: (NSString *) barcode;

// Инициирует отправление сформированной команды на сервер
-(void)doPreparedCommandWithDelegate: (id<XMLRPCConnectionDelegate>)delegate;

// Распаковываем данные из XML-RPC ответа и возвращаем
-(TCTLServerResponse *)unpackResponse:(id)xmlResponse;

// Возвращает полученный ответ от сервера или nil, если не операция окончилась ошибкой
//-(TCTLServerResponse *)getServerResponse;

@end
