//
//  TCTLScanResultItem.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 23.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TCTLServerQueryResponse;

@interface TCTLScanResultItem : NSObject

@property (strong, readonly) NSString	*barcode;				// Штрих-код сосканированного билета
@property (readonly) BOOL				allowedAccess;			// Признак разрешён ли вход
@property (strong, readonly) NSString	*resultText;			// Код результата от сервера
@property (strong, readonly) NSDate		*locallyCheckedTime;	// Время в которое код был сканирован
@property (strong, readonly) NSString	*hasBeenCheckedBy;		// Если билет уже проходил, здесь хранится имя контроллёра
@property (strong, readonly) NSDate		*hasBeenCheckedAt;		// Если билет уже проходил, здесь хранится время прохода

// Методы-инициализаторы
-(id)init;
-(id)initItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerQueryResponse *)serverResponse;

@end
