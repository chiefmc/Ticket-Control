//
//  TCTLScanResultItem.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLScanResultItem.h"
#import "TCTLConstants.h"
#import "TCTLServerResponse.h"

@implementation TCTLScanResultItem

// -------------------------------------------------------------
// Заполняем данные объекта
// -------------------------------------------------------------

-(instancetype)init
{
	return [self initItemWithBarcode: @"" FillTextWith: nil];
}
- (instancetype)initItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerResponse *)serverResponse
{
	self = [super init];
	if (!serverResponse) return nil;
	
	_barcode = barcode;

	switch (serverResponse.responseCode) {
		case accessAllowed:
			_resultText = @"ДОСТУП РАЗРЕШЁН";;
			_allowedAccess = YES;
			break;
		case accessDeniedTicketNotFound:
			_resultText = [[@"ДОСТУП ЗАПРЕЩЁН" stringByAppendingString: @": "] stringByAppendingString:@"БИЛЕТА НЕТ В БАЗЕ"];
			_allowedAccess = NO;
			break;
		case accessDeniedAlreadyPassed:
			_resultText = [[@"ДОСТУП ЗАПРЕЩЁН" stringByAppendingString: @": "] stringByAppendingString:@"БИЛЕТ УЖЕ ПРОХОДИЛ"];
			_allowedAccess = NO;
			break;
		case accessDeniedWrongEntrance:
			_resultText = [[@"ДОСТУП ЗАПРЕЩЁН" stringByAppendingString: @": "] stringByAppendingString:@"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД"];
			_allowedAccess = NO;
			break;
		case accessDeniedNoActiveEvent:
			_resultText = [[@"ДОСТУП ЗАПРЕЩЁН" stringByAppendingString: @": "] stringByAppendingString:@"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ"];
			_allowedAccess = NO;
			break;
		default:
			_resultText = [[@"ДОСТУП ЗАПРЕЩЁН" stringByAppendingString: @": "] stringByAppendingString:@"НЕИЗВЕСТНАЯ ОШИБКА"];
			_allowedAccess = NO;
			break;
	}
	_locallyCheckedTime = [NSDate date];
	_hasBeenCheckedBy = serverResponse.agentChecked;
	_hasBeenCheckedAt = serverResponse.timeChecked;
	
	return self;
}
@end
