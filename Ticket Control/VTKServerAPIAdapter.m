//
//  VTKServerAPIAdapter.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 12.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKServerAPIAdapter.h"
#import "VTKServerAPI.h"

@implementation VTKServerAPIAdapter

- (void)validateBarcode:(NSString *)barcode success:(void (^)(VTKValidatorResponse *))success failure:(void (^)(NSError *))failure
{
    [[VTKServerAPI manager] validateBarcode:barcode
                                WithSuccess:^(id responseObject) {
                                    
                                }
                                    failure:^(NSError *error) {
                                    
                                }];
    VTKValidatorResponse *response = [VTKValidatorResponse new];
    response.barcode = @"1234567890123";
    response.responseCode = VTKAPI10ResponseAccessAllowed;
    
    success(response);
}

@end
