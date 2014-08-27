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
- (void)setItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerQueryResponse *)serverResponse
{
	if (!serverResponse) return;
	
	self.barcode = barcode;

	switch (serverResponse.responseCode) {
		case accessAllowed:
			self.resultText = textAccessAllowed;
			self.allowedAccess = YES;
			break;
		case accessDeniedTicketNotFound:
			self.resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textTicketNotFound];
			self.allowedAccess = NO;
			break;
		case accessDeniedAlreadyPassed:
			self.resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textTicketAlreadyPassed];
			self.allowedAccess = NO;
			break;
		case accessDeniedWrongEntrance:
			self.resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textWrongEntrance];
			self.allowedAccess = NO;
			break;
		case accessDeniedNoActiveEvent:
			self.resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textNoEventToControl];
			self.allowedAccess = NO;
			break;
		default:
			self.resultText = [[textAccessDenied stringByAppendingString: @": "] stringByAppendingString:textUnknownError];
			self.allowedAccess = NO;
			break;
	}
	self.locallyCheckedTime = [NSDate date];
	self.hasBeenCheckedBy = serverResponse.agentChecked;
	self.hasBeenCheckedAt = serverResponse.timeChecked;
}
@end
