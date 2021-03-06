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

/**
 *  The item that was selected in tableView
 */
@property (weak, nonatomic) TCTLScanResultItem *logItem;

@end
