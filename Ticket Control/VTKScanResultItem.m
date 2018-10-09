//
//  VTKScanResultItem.m
//  Ticket Scanner
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKScanResultItem.h"
#import "VTKConstants.h"
#import "VTKValidatorResponse.h"

@implementation VTKScanResultItem

-(instancetype)init
{
	return [self initItemWithValidatorResponse:nil];
}

- (instancetype)initItemWithValidatorResponse:(VTKValidatorResponse *)validatorResponse
{
	self = [super init];
	if (!validatorResponse) return self;
	
    _barcode      = validatorResponse.barcode;
    _responseCode = validatorResponse.responseCode;

	switch (validatorResponse.responseCode) {
		case VTKAPI10ResponseAccessAllowed:
			_statusText = NSLocalizedString(@"ДОСТУП РАЗРЕШЁН", @"Статус в логе");
            _extendedStatusText = @"";
			_allowedAccess = YES;
			break;
		case VTKAPI10ResponseAccessDeniedTicketNotFound:
//            _statusText = [[NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе")
//                            stringByAppendingString: @": "]
//                           stringByAppendingString:NSLocalizedString(@"БИЛЕТА НЕТ В БАЗЕ", @"Статус в логе")];
            _statusText = NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе");
            _extendedStatusText = NSLocalizedString(@"БИЛЕТА НЕТ В БАЗЕ", @"Статус в логе");
			_allowedAccess = NO;
			break;
		case VTKAPI10ResponseAccessDeniedAlreadyPassed:
            _statusText = NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе");
            _extendedStatusText = NSLocalizedString(@"БИЛЕТ УЖЕ ПРОХОДИЛ", @"Статус в логе");
			_allowedAccess = NO;
			break;
		case VTKAPI10ResponseAccessDeniedWrongEntrance:
            _statusText = NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе");
            _extendedStatusText = NSLocalizedString(@"ДОСТУП ЧЕРЕЗ ДРУГОЙ ВХОД", @"Статус в логе");
			_allowedAccess = NO;
			break;
		case VTKAPI10ResponseAccessDeniedNoActiveEvent:
            _statusText = NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе");
            _extendedStatusText = NSLocalizedString(@"НЕТ СОБЫТИЯ ДЛЯ КОНТРОЛЯ", @"Статус в логе");
			_allowedAccess = NO;
			break;
		default:
            _statusText = NSLocalizedString(@"ДОСТУП ЗАПРЕЩЁН", @"Статус в логе");
            _extendedStatusText = NSLocalizedString(@"НЕИЗВЕСТНАЯ ОШИБКА", @"Статус в логе");
			_allowedAccess = NO;
			break;
	}
	_locallyCheckedTime = [NSDate date];
	_hasBeenCheckedBy = validatorResponse.agentChecked;
	_hasBeenCheckedAt = validatorResponse.timeChecked;
	
	return self;
}
@end
