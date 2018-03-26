//
//  TCTLScanResultItem.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKScanResultItem.h"
#import "VTKConstants.h"
#import "VTKValidatorResponse.h"

@implementation VTKScanResultItem

// -------------------------------------------------------------
// Заполняем данные объекта
// -------------------------------------------------------------

-(instancetype)init
{
	return [self initItemWithValidatorResponse:nil];
}

- (instancetype)initItemWithValidatorResponse:(VTKValidatorResponse *)validatorResponse
{
	self = [super init];
	if (!validatorResponse) return self;
	
	_barcode = validatorResponse.barcode;

    //TODO: Нужно энкапсулировать этот код в отдельный объект
	switch (validatorResponse.responseCode) {
		case VTKValidatorResponseAccessAllowed:
			_resultText = NSLocalizedString(@"ДОСТУП РАЗРЕШЁН", @"Статус в логе");
			_allowedAccess = YES;
			break;
		case VTKValidatorResponseAccessDeniedTicketNotFound:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"БИЛЕТА НЕТ В БАЗЕ", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case VTKValidatorResponseAccessDeniedAlreadyPassed:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"БИЛЕТ УЖЕ ПРОХОДИЛ", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case VTKValidatorResponseAccessDeniedWrongEntrance:
			_resultText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
                            stringByAppendingString: @": "]
                           stringByAppendingString:NSLocalizedString(@"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД", @"Статус в логе")];
			_allowedAccess = NO;
			break;
		case VTKValidatorResponseAccessDeniedNoActiveEvent:
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
	_hasBeenCheckedBy = validatorResponse.agentChecked;
	_hasBeenCheckedAt = validatorResponse.timeChecked;
	
	return self;
}
@end
