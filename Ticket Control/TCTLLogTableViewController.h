//
//  TCTLLogTableViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 26.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import UIKit;

@interface TCTLLogTableViewController : UITableViewController

// Переменная с результатами сканирования
@property (strong, nonatomic) NSMutableArray *scanResultItems;

// -(IBAction)unwindToLogTable:(UIStoryboardSegue *)segue;

@end
