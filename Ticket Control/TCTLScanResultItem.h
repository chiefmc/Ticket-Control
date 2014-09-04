//
//  TCTLScanResultItem.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TCTLServerResponse;

@interface TCTLScanResultItem : NSObject

@property (strong, readonly) NSString	*barcode;				// Barcode of the ticket scanned
@property (readonly) BOOL				allowedAccess;			// Did we allowed the entrance
@property (strong, readonly) NSString	*resultText;			// A resulting text message we displayed to user
@property (strong, readonly) NSDate		*locallyCheckedTime;	// Time the barcode was checked at
@property (strong, readonly) NSString	*hasBeenCheckedBy;		// The name of the steward that checked the ticketed
@property (strong, readonly) NSDate		*hasBeenCheckedAt;		// The time ticket was checked at
@property (strong, nonatomic) NSDictionary *serverParsedResponse;		// Parsed server response with all the extra data we get from the server

// Initialization methods
-(id)init;
-(id)initItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerResponse *)serverResponse;

@end
