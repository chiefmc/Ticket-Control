//
//  TCTLLogTableViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 26.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLLogTableViewController.h"
#import "TCTLMainViewController.h"
#import "TCTLScanResultItem.h"
#import "TCTLLogDetailTableViewController.h"

@interface TCTLLogTableViewController ()

@property (weak, nonatomic) TCTLScanResultItem *logItem;

@end

@implementation TCTLLogTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		//TCTLViewController *mainWindowViewController = (TCTLViewController *)self.navigationController.parentViewController;
		//self.scanResultItems = mainWindowViewController.scanResultItems;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.scanResultItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
	TCTLScanResultItem *logItem = [self.scanResultItems objectAtIndex: indexPath.row];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	[dateFormatter setDateStyle: NSDateFormatterNoStyle];
	
	NSString *title = [dateFormatter stringFromDate: logItem.locallyCheckedTime];
	title = [title stringByAppendingFormat: NSLocalizedString(@" Билет %@", @"Строка лога"), logItem.barcode];
    cell.textLabel.text = title;
	cell.detailTextLabel.text = logItem.resultText;
	
	// Setting text colors and accessiories
	if (logItem.allowedAccess) {
		[cell.detailTextLabel setTextColor: [UIColor greenColor]];
		[cell setAccessoryType: UITableViewCellAccessoryNone];
	} else {
		[cell.detailTextLabel setTextColor: [UIColor redColor]];
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	// Selecting object to tranfer with the segue
	self.logItem = self.scanResultItems[indexPath.row];
	
	// If the item is a NOT an Allowed-access one, we going into detailed view
	if (!self.logItem.allowedAccess) {
		[self performSegueWithIdentifier:@"logItemDetails" sender:self];
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.destinationViewController isKindOfClass:[TCTLLogDetailTableViewController class]]) {
		TCTLLogDetailTableViewController *destination = segue.destinationViewController;
		destination.logItem = self.logItem;
	}
}

@end
