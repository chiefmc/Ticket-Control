//
//  TCTLLogTableViewController.h
//  Ticket Control
//
//  Created by Евгений Лысенко on 26.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

@import UIKit;


@interface VTKLogTableViewController : UITableViewController

/**
 *  Array with the log of scan details
 */
@property (weak, nonatomic) NSMutableArray *scanResultItems;

@end
