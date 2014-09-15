//
//  TCTLServerQueryResponse.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;

// -----------------------------------------------------------
// This is a class that implements a Ticket server exchange API
// Current supported API version 1.0
// -----------------------------------------------------------

// Возможные коды ответа от билетного сервера
typedef NS_ENUM(unsigned int, ServerResponse) {
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
	errorNetworkError			= 0x301,	// Ошибка возвращается, если по каким-то причинам ответ от сервера не был получен
	errorServerResponseUnkown	= 0x302,	// Ошибка возращается парсером, если он не смог распознать полученный от сервера ответ
};

// ----------------------------------------------------------
// Класс ответа сервера
// ----------------------------------------------------------
@interface TCTLServerResponse : NSObject

@property (nonatomic) ServerResponse	responseCode;		// код ответа от сервера (см. выше)
@property (copy, nonatomic) NSString	*barcode;			// штрих-код проверенного билета
@property (copy, nonatomic) NSString	*userName;			// текстовое имя пользователя
@property (copy, nonatomic) NSString	*eventName;			// текстовое название ивента
@property (strong, nonatomic) NSDate	*eventStart;		// дата/время начала ивента
@property (strong, nonatomic) NSDate	*controlStart;		// дата/время начала контроля на этот ивент
@property (strong, nonatomic) NSDate	*controlEnd;		// дата/время окончания контроля на этот ивент
@property (copy, nonatomic) NSString	*agentChecked;		// пользователь системы (контроллёр), через которого этот билет уже проходил
@property (strong, nonatomic) NSDate	*timeChecked;		// дата/время в которое этот билет уже проходил
@property (nonatomic) BOOL				clientNeedsUpdate;	// сервер возвращает вместе с именем пользователя, если нужно обновить клиент
@property (strong, nonatomic) NSNumber	*errorCode;			// код ошибки, возвращённый XMLRPC фреймворком
@property (copy, nonatomic) NSString	*errorDescription;	// описание ошибки, переданное фреймворком

@end
