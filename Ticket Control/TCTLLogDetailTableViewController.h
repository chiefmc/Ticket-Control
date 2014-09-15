//
//  TCTLLogDetailTableViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 04.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import UIKit;
#import "TCTLScanResultItem.h"

@interface TCTLLogDetailTableViewController : UITableViewController

@property (weak, nonatomic) TCTLScanResultItem *logItem;	// A log item to display details from

@end
