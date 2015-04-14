//
//  TCTLScanResultItem.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;

@class VTKValidatorResponse;

/**
 *  This is a model class, that stores a single barcode scan result
 */
@interface VTKScanResultItem : NSObject

@property (nonatomic, copy, readonly) NSString	*barcode;				// Barcode of the ticket scanned
@property (nonatomic, readonly) BOOL			allowedAccess;			// Did we allowed the entrance
@property (nonatomic, copy, readonly) NSString	*resultText;			// A resulting text message we displayed to user
@property (nonatomic, strong, readonly) NSDate	*locallyCheckedTime;	// Time the barcode was checked at
@property (nonatomic, copy, readonly) NSString	*hasBeenCheckedBy;		// The name of the steward that checked the ticketed
@property (nonatomic, strong, readonly) NSDate	*hasBeenCheckedAt;		// The time ticket was checked at
@property (nonatomic, strong) NSDictionary		*serverParsedResponse;	// Parsed server response with all the extra data we get from the server

-(instancetype)init;

/**
 *  The designated initializer for the class
 *
 *  @param barcode        An NSString containing the scanned barcode
 *  @param serverResponse The server response object
 *
 *  @return the inialized object
 */
-(instancetype)initItemWithValidatorResponse: (VTKValidatorResponse *)validatorResponse NS_DESIGNATED_INITIALIZER;

@end
