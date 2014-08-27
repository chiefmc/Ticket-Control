//
//  TCTLScanResultItem.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLScanResultItem.h"
#import "TCTLConstants.h"
#import "TCTLServerQueryResponse.h"

@implementation TCTLScanResultItem

// -------------------------------------------------------------
// Заполняем данные объекта
// -------------------------------------------------------------

-(id)init
{
	return [self initItemWithBarcode: @"" FillTextWith: nil];
}
- (id)initItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerQueryResponse *)serverResponse
{
	self = [super init];
	if (!serverResponse) return nil;
	
	_barcode = barcode;

	switch (serverResponse.responseCode) {
		case accessAllowed:
			_resultText = textAccessAllowed;
			_allowedAccess = YES;
			break;
		case accessDeniedTicketNotFound:
			_resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textTicketNotFound];
			_allowedAccess = NO;
			break;
		case accessDeniedAlreadyPassed:
			_resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textTicketAlreadyPassed];
			_allowedAccess = NO;
			break;
		case accessDeniedWrongEntrance:
			_resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textWrongEntrance];
			_allowedAccess = NO;
			break;
		case accessDeniedNoActiveEvent:
			_resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textNoEventToControl];
			_allowedAccess = NO;
			break;
		default:
			_resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textUnknownError];
			_allowedAccess = NO;
			break;
	}
	_locallyCheckedTime = [NSDate date];
	_hasBeenCheckedBy = serverResponse.agentChecked;
	_hasBeenCheckedAt = serverResponse.timeChecked;
	
	return self;
}
@end
