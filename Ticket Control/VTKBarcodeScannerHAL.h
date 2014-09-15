//
//  VTBarcodeScannerHAL.h
//	Barcode scanner Hardware Abstraction Layer (HAL) class
//  Ticket Control
//
//  Created by Евгений Лысенко on 05.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import Foundation;

@protocol BarcodeCommandHandler <NSObject>

-(void)barcodeScannedNotification;

@end

@protocol BarcodeNotificationHandler <NSObject>

-(void)handleInformationUpdate;

@end

@interface VTKBarcodeScannerHAL : NSObject <ReceiveCommandHandler, NotificationHandler>

// Class method that resturns a shared static instance for the below operations
+(instancetype)sharedInstance;


// Types of currently supported frameworks
typedef NS_ENUM(unsigned int, VTBarcodeFramework) {
	mobilogicsFramework,
	appleCameraFramework,
};

// This should be the first method to initate the sharedInstance connection to a hardware
-(void)setupWith: (VTBarcodeFramework)framework;

@end
