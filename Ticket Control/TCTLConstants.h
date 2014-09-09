//
//  TCTLConstants.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Константы версионоости приложения
#define APP_VERSION				@"1.0"
#define API_VERSION				@"1.0"

#pragma mark - Константы названий параметров переменных, передаваемых через API
#define BARCODE_KEY				@"Barcode"
#define GUID_KEY				@"GUID"
#define CLIENT_APP_VERSION_KEY	@"ClientAppVersion"
#define SERVER_API_VERSION_KEY	@"ServerAPIVersion"

#define RESPONSE_CODE_KEY		@"ResponseCode"
#define USER_NAME_KEY			@"UserName"
#define EVENT_NAME_KEY			@"EventName"
#define EVENT_START_KEY			@"EventStart"
#define CONTROL_START_KEY		@"ControlStart"
#define CONTROL_END_KEY			@"ControlEnd"
#define AGENT_CHECKED_KEY		@"AgentChecked"
#define TIME_CHECKED_KEY		@"TimeChecked"
#define CLIENT_NEEDS_UPDATE_KEY	@"ClientNeedsUpdate"
#define SECTOR_KEY				@"Sector"
#define ROW_KEY					@"Row"
#define SEAT_KEY				@"Seat"

#pragma mark - Константы различных настроек
#define XMLRPC_TIMEOUT			15
#define XMLRPC_USER_AGENT		@"vTicketControl/1.0.0 (iOS)"
#define NUMBER_OF_HISTORY_ITEMS	50
#define DATETIME_SERVER_FORMAT	@"yyyyMMdd'T'HH':'mm':'ss"
#define DATETIME_TO_DISPLAY		@"HH':'mm':'ss' 'dd'/'MM'"

// Macro that defines that we're using JSON-RPC to whom it may concern
#define JSON_RPC

// Константы версионности
extern NSString* const clientAppVersion;
extern NSString* const serverAPIVersion;

// Константы настроек приложения Settings Bundle
extern NSString* const kVibroStrength;
extern NSString* const kDisableAutolock;
extern NSString* const kUserGUID;
extern NSString* const kResultDisplayTime;
extern NSString* const kServerURL;
extern NSString* const kScannerBeep;

// Текстовые константы для локализации
extern NSString* const textNotReady;
extern NSString* const textReadyToCheck;
extern NSString* const textLookingForTicket;
extern NSString* const textAccessAllowed;
extern NSString* const textAccessDenied;
extern NSString* const textTicketNotFound;
extern NSString* const textTicketAlreadyPassed;
extern NSString* const textWrongEntrance;
extern NSString* const textNoEventToControl;
extern NSString* const textUnknownError;
extern NSString* const textError;
extern NSString* const textRetry;
extern NSString* const textCancel;
extern NSString* const textOk;
extern NSString* const textWrongGUID;
extern NSString* const textInformation;
extern NSString* const textScannerBatteryCharge;
extern NSString* const textScannerIsNotConnected;
extern NSString* const textServerConnected;
extern NSString* const textNoServerConnection;
extern NSString* const textScannerBatteryOnCharge;