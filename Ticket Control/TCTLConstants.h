//
//  TCTLConstants.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>

// Константы версионности
NSString* const clientAPPVersion = @"1.0";
NSString* const serverAPIVersion = @"1.0";

// Константы настроек приложения Settings Bundle
NSString* const kVibroStrength			= @"vibroStrength";
NSString* const kDisableAutolock		= @"disableAutolock";
NSString* const kUserGUID				= @"userGUID";
NSString* const kResultDisplayTime		= @"resultDisplayTime";
NSString* const kServerURL				= @"serverURL";

// Текстовые константы для локализации
NSString* const textReadyToCheck		= @"ОЖИДАНИЕ ПРОВЕРКИ";
NSString* const	textLookingForTicket	= @"ПОИСК БИЛЕТА";
NSString* const textAccessAllowed		= @"ДОСТУП РАЗРЕШЁН";
NSString* const textAccessDenied		= @"ДОСТУП ЗАПРЕЩЁН";
NSString* const textTicketNotFound		= @"БИЛЕТА НЕТ В БАЗЕ";
NSString* const textTicketAlreadyPassed = @"БИЛЕТ УЖЕ ПРОХОДИЛ";
NSString* const textWrongEntrance		= @"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД";
NSString* const textNoEventToControl	= @"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ";
NSString* const	textUnknownError		= @"НЕИЗВЕСТНАЯ ОШИБКА";