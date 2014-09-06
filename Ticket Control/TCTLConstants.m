//
//  TCTLConstants.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTLConstants.h"

// Константы версионности
NSString* const clientAppVersion = APP_VERSION;
NSString* const serverAPIVersion = API_VERSION;

// Константы настроек приложения Settings Bundle
NSString* const kVibroStrength			= @"vibroStrength";
NSString* const kDisableAutolock		= @"disableAutolock";
NSString* const kUserGUID				= @"userGUID";
NSString* const kResultDisplayTime		= @"resultDisplayTime";
NSString* const kServerURL				= @"serverURL";
NSString* const kScannerBeep			= @"scannerBeep";

// Текстовые константы для локализации
NSString* const textNotReady			= @"НЕ ГОТОВ";
NSString* const textReadyToCheck		= @"ОЖИДАНИЕ ПРОВЕРКИ";
NSString* const	textLookingForTicket	= @"ПОИСК БИЛЕТА";
NSString* const textAccessAllowed		= @"ДОСТУП РАЗРЕШЁН";
NSString* const textAccessDenied		= @"ДОСТУП ЗАПРЕЩЁН";
NSString* const textTicketNotFound		= @"БИЛЕТА НЕТ В БАЗЕ";
NSString* const textTicketAlreadyPassed = @"БИЛЕТ УЖЕ ПРОХОДИЛ";
NSString* const textWrongEntrance		= @"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД";
NSString* const textNoEventToControl	= @"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ";
NSString* const	textUnknownError		= @"НЕИЗВЕСТНАЯ ОШИБКА";
NSString* const textError				= @"Ошибка";
NSString* const textRetry				= @"Повторить";
NSString* const textCancel				= @"Отмена";
NSString* const textOk					= @"Ok";
NSString* const textWrongGUID			= @"Неверный GUID! Обратитесь к Администратору системы";
NSString* const textInformation			= @"Информация";
NSString* const textScannerBatteryCharge = @"Заряд батареи сканнера: ";
NSString* const textScannerIsNotConnected = @"Сканнер не подключен";
NSString* const textServerConnected		= @"Соединение с сервером установлено";
NSString* const textNoServerConnection	= @"Нет соединения с сервером";
NSString* const textScannerBatteryOnCharge = @"Батарея сканера заряжается";