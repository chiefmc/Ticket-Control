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
			_resultText = NSLocalizedString(@"ДОСТУП РАЗРЕШЁН", @"Статус в логе");
			_allowedAccess = YES;
			break;
		case accessDeniedTicketNotFound:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"БИЛЕТА НЕТ В БАЗЕ", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case accessDeniedAlreadyPassed:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"БИЛЕТ УЖЕ ПРОХОДИЛ", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case accessDeniedWrongEntrance:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case accessDeniedNoActiveEvent:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		default:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"НЕИЗВЕСТНАЯ ОШИБКА", @"Статус в логе")];
			_allowedAccess = NO;
			break;
	}
	_locallyCheckedTime = [NSDate date];
	_hasBeenCheckedBy = serverResponse.agentChecked;
	_hasBeenCheckedAt = serverResponse.timeChecked;
	
	return self;
}
@end
