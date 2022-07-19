//
//  VTKServerAPIAdapter.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 12.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "VTKBarcodeValidatorProtocol.h"
@import Foundation;

/**
 *  This is the VTKServerAPI adapter object, used as an abstaction layer from the concrete Server API implementation
 */
@interface VTKServerAPIAdapter : NSObject <VTKBarcodeValidatorProtocol>

@end
