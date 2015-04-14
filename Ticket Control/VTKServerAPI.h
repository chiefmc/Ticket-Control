//
//  VTKServerAPI.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 11.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeValidatorProtocol.h"
@import Foundation;

// Возможные коды ответа от билетного сервера
typedef NS_ENUM(unsigned int, VTKAPI10ResponseCode) {
    VTKAPI10ResponseResultOk                   = 0x100,// ответ от сервера, что он команду получил
    VTKAPI10ResponseSetActiveUser              = 0x111,// возвращает параметр userName с именем контролёра в базе сервера
    VTKAPI10ResponseSetActiveUserNotFound      = 0x112,// Контролёр с таким GUID не найден
    VTKAPI10ResponseSetActiveEvent             = 0x121,// возвращает параметры:eventName с именем активного события, eventStart с датой/временем начала события, controlStart с датой/временем начала контроля, controlEnd с датой/временем окончания контроля
    VTKAPI10ResponseSetActiveEventNotFound     = 0x122,// На данный момент нет событий для контроля
    
    VTKAPI10ResponseAccessAllowed              = 0x210,// Проход разрешён
    VTKAPI10ResponseAccessDeniedTicketNotFound = 0x211,// Проход запрещён – билет не найден в базе
    VTKAPI10ResponseAccessDeniedAlreadyPassed  = 0x212,// Проход запрещён – билет уже проходил. Возвращает параметры: agentChecked с именем контролёра, пропустившего билет, timeChecked с датой/временем
    VTKAPI10ResponseAccessDeniedWrongEntrance  = 0x213,// Проход запрещён – вход через другую зону (например через VIP-вход)
    VTKAPI10ResponseAccessDeniedNoActiveEvent  = 0x214,// Проход запрещён – нет активного события
    VTKAPI10ResponseAccessDeniedUnknownError   = 0x220,// Проход запрещён – неизвестная ошибка
    VTKAPI10ResponseErrorNetworkError          = 0x301,// Ошибка возвращается, если по каким-то причинам ответ от сервера не был получен
    VTKAPI10ResponseErrorServerResponseUnkown  = 0x302,// Ошибка возращается парсером, если он не смог распознать полученный от сервера ответ
};

/**
 *  Ticketing Server API communicator object
 */
@interface VTKServerAPI : NSObject

/**
 *  Returns singleton instance to operate on
 *
 *  @return Returns singleton instance
 */
+ (instancetype)manager;

//-------------------------------------------------------------------------------------
//
// v-Ticket system barcode checking API v1.0 methods
//
//-------------------------------------------------------------------------------------

- (void)noOp;// отсутствие действий
- (NSString *)getUserName;// запрашивает текстовое имя текущего контролёра
- (void)getActiveEvent;// запрашивает активное событие, на которое можно осуществлять контроль
- (VTKAPI10ResponseCode)getCodeResult;// отсылает серверу на проверку штрих-код

@end
