//
//  VTKServerAPI.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 11.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

@import Foundation;

/**
 *  Methods sent to a Ticketing server
 */
typedef NS_ENUM(unsigned int, VTKAPI10Method) {
    VTKAPI10MethodNoOp               = 0x100,// отсутствие действий
    VTKAPI10MethodGetCurrentUserName = 0x110,// запрашивает текстовое имя текущего контролёра
    VTKAPI10MethodGetNearestEvent    = 0x120,// запрашивает активное событие, на которое можно осуществлять контроль
    VTKAPI10MethodValidateBarcode    = 0x200,// отсылает серверу на проверку штрих-код
};

/**
 *  Возможные коды ответа от билетного сервера
 */
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
 *  Controls which API version will be used to communicate with the server
 */
@property (nonatomic, copy) NSString *APIVersionInUse;

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

/**
 *  "No Operation", aka ping. Just a check if the server responses.
 *  Also returns server API version.
 *
 *  @param success Success block executed upon success.
 *  @param failure Failure block, executed upon any unexpected error (errors returned by server will be handed over to success block).
 */
- (void)noOpWithSuccess:(void(^)(id responseObject))success
                failure:(void(^)(NSError *error))failure;

/**
 *  Fetches from server the name of the current user of the device (by its GUID)
 *
 *  @param success Success block executed upon success.
 *  @param failure Failure block, executed upon any unexpected error (errors returned by server will be handed over to success block). 
 */
- (void)getCurrentUserNameWithSuccess:(void(^)(id responseObject))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  Fetches the name and params of the nearest event for ticket check
 *
 *  @param success Success block executed upon success.
 *  @param failure Failure block, executed upon any unexpected error (errors returned by server will be handed over to success block). 
 */
- (void)getNearestEventWithSuccess:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure;

/**
 *  Validates the barcode with the server
 *
 *  @param barcode The string, representing the barcode.
 *  @param success Success block executed upon success.
 *  @param failure Failure block, executed upon any unexpected error (errors returned by server will be handed over to success block). 
 */
- (void)validateBarcode:(NSString *)barcode
            WithSuccess:(void(^)(id responseObject))success
                failure:(void(^)(NSError *error))failure;

@end
