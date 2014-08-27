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

@property (nonatomic) NSString		*barcode;				// Штрих-код сосканированного билета
@property (nonatomic) BOOL			allowedAccess;			// Признак разрешён ли вход
@property (nonatomic) NSString		*resultText;			// Код результата от сервера
@property (nonatomic) NSDate		*locallyCheckedTime;	// Время в которое код был сканирован
@property (nonatomic) NSString		*hasBeenCheckedBy;		// Если билет уже проходил, здесь хранится имя контроллёра
@property (nonatomic) NSDate		*hasBeenCheckedAt;		// Если билет уже проходил, здесь хранится время прохода

- (void)setItemWithBarcode: (NSString *)barcode FillTextWith: (TCTLServerQueryResponse *)serverResponse;

@end
