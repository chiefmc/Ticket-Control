//
//  VTKBarcodeValidatorProtocol.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 12.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKValidatorResponse.h"
@import Foundation;

/**
 *  Protocol describes barcode validating methods
 */
@protocol VTKBarcodeValidatorProtocol

@required

/**
 Validates the barcode and calls the appropriate callback closure as a result

 @param barcode String, representing the barcode that needs to be validated
 @param success Callback that is being called after the barcode has been validated (even if the validation has failed). You need to check the result code for the validation result
 @param failure Callback that is called if the validation did not happen due to network or server failure reason
 */
- (void)validateBarcode:(NSString *)barcode
                success:(void(^)(VTKValidatorResponse *result))success
                failure:(void(^)(NSError *error))failure;

@end
