//
//  TCTLServerQueryResponse.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>

// -----------------------------------------------------------
// API обмена данными с билетным сервером
// Версия 1.0
// -----------------------------------------------------------


// Команды отправляемые билетному серверу
typedef enum ServerCommand:int {
	noOp						= 0x100,	// отсутствие действий
	getUserName					= 0x110,	// запрашивает текстовое имя текущего контролёра
	getActiveEvent				= 0x120,	// запрашивает активное событие, на которое можно осуществлять контроль
	getCodeResult				= 0x200,	// отсылает серверу на проверку штрих-код
} ServerCommand;

// Возможные коды ответа от билетного сервера
typedef enum ServerResponse:int {
	resultOk					= 0x100,	// ответ от сервера, что он команду получил
	setActiveUser				= 0x111,	// возвращает параметр userName с именем контролёра в базе сервера
	setActiveUserNotFound		= 0x112,	// Контролёр  с таким GUID не найден
	setActiveEvent				= 0x121,	// возвращает параметры:eventName с именем активного события, eventStart с датой/временем начала события, controlStart с датой/временем начала контроля, controlEnd с датой/временем окончания контроля
	setActiveEventNotFound		= 0x122,	// На данный момент нет событий для контроля
	
	accessAllowed				= 0x210,	// Проход разрешён
	accessDeniedTicketNotFound	= 0x211,	// Проход запрещён – билет не найден в базе
	accessDeniedAlreadyPassed	= 0x212,	// Проход запрещён – билет уже проходил. Возвращает параметры: agentChecked с именем контролёра, пропустившего билет, timeChecked с датой/временем
	accessDeniedWrongEntrance	= 0x213,	// Проход запрещён – вход через другую зону (например через VIP-вход)
	accessDeniedNoActiveEvent	= 0x214,	// Проход запрещён – нет активного события
	accessDeniedUnknownError	= 0x220,	// Проход запрещён – неизвестная ошибка
} ServerResponse;

// ----------------------------------------------------------
// Класс для обмена данными между и владельцем
// ----------------------------------------------------------
@interface TCTLServerQueryResponse : NSObject

@property (nonatomic) ServerResponse responseCode;	// код ответа от сервера (см. выше)
@property (nonatomic) NSString	*userName;			// текстовое имя пользователя
@property (nonatomic) NSString	*eventName;			// текстовое название ивента
@property (nonatomic) NSDate	*eventStart;		// дата/время начала ивента
@property (nonatomic) NSDate	*controlStart;		// дата/время начала контроля на этот ивент
@property (nonatomic) NSDate	*controlEnd;		// дата/время окончания контроля на этот ивент
@property (nonatomic) NSString	*agentChecked;		// пользователь системы (контроллёр), через которого этот билет уже проходил
@property (nonatomic) NSDate	*timeChecked;		// дата/время в которое этот билет уже проходил
@property (nonatomic) BOOL		*clientNeedsUpdate;	// сервер возвращает вместе с именем пользователя, если нужно обновить клиент

@end
