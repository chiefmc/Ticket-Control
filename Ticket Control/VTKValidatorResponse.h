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

// Возможные коды ответа от валидатора
typedef NS_ENUM(unsigned int, VTKValidatorResponseCode) {
    VTKValidatorResponseAccessAllowed,// Проход разрешён
    VTKValidatorResponseAccessDeniedTicketNotFound,// Проход запрещён – билет не найден в базе
    VTKValidatorResponseAccessDeniedAlreadyPassed, // Проход запрещён – билет уже проходил. Возвращает параметры: agentChecked с именем контролёра, пропустившего билет, timeChecked с датой/временем
    VTKValidatorResponseAccessDeniedWrongEntrance, // Проход запрещён – вход через другую зону (например через VIP-вход)
    VTKValidatorResponseAccessDeniedNoActiveEvent, // Проход запрещён – нет активного события
    VTKValidatorResponseAccessDeniedUnknownError,  // Проход запрещён – неизвестная ошибка
    VTKValidatorResponseErrorNetworkError,         // Ошибка возвращается, если по каким-то причинам ответ от сервера не был получен
    VTKValidatorResponseErrorServerResponseUnkown, // Ошибка возращается парсером, если он не смог распознать полученный от сервера ответ
};

/**
 *  This is a ticket server response data model class. It contains a single response item
 */
@interface VTKValidatorResponse : NSObject

@property (nonatomic) VTKValidatorResponseCode	responseCode;	// код ответа от сервера (см. выше)
@property (copy, nonatomic) NSString	*barcode;			    // штрих-код проверенного билета
@property (copy, nonatomic) NSString	*userName;			    // текстовое имя пользователя
@property (copy, nonatomic) NSString	*eventName;			    // текстовое название ивента
@property (strong, nonatomic) NSDate	*eventStart;		    // дата/время начала ивента
@property (strong, nonatomic) NSDate	*controlStart;		    // дата/время начала контроля на этот ивент
@property (strong, nonatomic) NSDate	*controlEnd;		    // дата/время окончания контроля на этот ивент
@property (copy, nonatomic) NSString	*agentChecked;		    // пользователь системы (контроллёр), через которого этот билет уже проходил
@property (strong, nonatomic) NSDate	*timeChecked;		    // дата/время в которое этот билет уже проходил
@property (nonatomic) BOOL				clientNeedsUpdate;	    // сервер возвращает вместе с именем пользователя, если нужно обновить клиент
@property (strong, nonatomic) NSNumber	*errorCode;			    // код ошибки, возвращённый JSON-RPC фреймворком
@property (copy, nonatomic) NSString	*errorDescription;	    // описание ошибки, переданное фреймворком

@end
