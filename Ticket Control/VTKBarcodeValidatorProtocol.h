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
- (void)validateBarcode:(NSString *)barcode
                success:(void(^)(VTKValidatorResponse *result))success
                failure:(void(^)(NSError *error))failure;

@end