//
//  TCTLConstants.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 24.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;

#pragma mark - Константы версионоости приложения
#define APP_VERSION				@"1.0"
#define API_VERSION				@"1.0"
#define API_MIN_VERSION         @"1.0"

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
#define NUMBER_OF_HISTORY_ITEMS	20
#define DATETIME_SERVER_FORMAT	@"yyyyMMdd'T'HH':'mm':'ss"
#define DATETIME_TO_DISPLAY		@"dd' 'MMM' 'HH':'mm':'ss"

// Macro that defines that we're using JSON-RPC to whom it may concern
#define JSON_RPC


// Macro that defines that we want to test the iPod without a connection to actual scanner
#define TEST_IPOD_WITHOUT_SCANNER 0


// Константы настроек приложения Settings Bundle
#define VIBRO_STRENGTH_S		@"vibroStrength"
#define DISABLE_AUTOLOCK_S		@"disableAutolock"
#define USER_GUID_S				@"userGUID"
#define RESULT_DISPLAY_TIME_S	@"resultDisplayTime"
#define SERVER_URL_S			@"serverURL"
#define SCANNER_BEEP_S			@"scannerBeep"
