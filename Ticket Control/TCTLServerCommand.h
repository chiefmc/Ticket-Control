//
//  TCTLServerCommand.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 27.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTLServerQueryResponse.h"

// -----------------------------------------------------------
// API обмена данными с билетным сервером
// Версия 1.0
// -----------------------------------------------------------


// Команды отправляемые билетному серверу
typedef NS_ENUM(int, ServerCommand) {
	noOp						= 0x100,	// отсутствие действий
	getUserName					= 0x110,	// запрашивает текстовое имя текущего контролёра
	getActiveEvent				= 0x120,	// запрашивает активное событие, на которое можно осуществлять контроль
	getCodeResult				= 0x200,	// отсылает серверу на проверку штрих-код
};

@interface TCTLServerCommand : NSObject

@property (readonly) ServerCommand		serverCommand;		// метод (команда) посылаемая серверу
@property (strong, readonly) NSString	*barcode;			// штрих-код проверяемого билета (может быть пустым)

@property (strong, readonly) TCTLServerQueryResponse *serverResponse; // Хранимый ответ от сервера

// Инициализаторы объекта
-(id)init;
-(id)initWithCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid;
-(id)initWithCommand: (ServerCommand) serverCommand withGUID: (NSString *) guid withBarcode: (NSString *) barcode;

// Посылает сформированную команду на сервер
-(void)doSendCommand;

// Возвращает полученный ответ от сервера или nil, если не операция окончилась ошибкой
-(TCTLServerQueryResponse *)getServerResponse;

@end
