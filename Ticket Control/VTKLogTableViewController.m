//
//  TCTLLogTableViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 26.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKLogTableViewController.h"
#import "VTKScanViewController.h"
#import "VTKScanResultItem.h"
#import "VTKLogDetailTableViewController.h"

@interface VTKLogTableViewController ()

@property (weak, nonatomic) VTKScanResultItem *scanResultItem;

@end

@implementation VTKLogTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
	VTKScanResultItem *scanResultItem = [self.scanResultItems objectAtIndex: indexPath.row];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	[dateFormatter setDateStyle: NSDateFormatterNoStyle];
	
	NSString *title = [dateFormatter stringFromDate: scanResultItem.locallyCheckedTime];
	title = [title stringByAppendingFormat: NSLocalizedString(@" Билет %@", @"Строка лога"), scanResultItem.barcode];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [[scanResultItem.statusText stringByAppendingString: @": "]
                                 stringByAppendingString: scanResultItem.extendedStatusText];
	
	// Setting text colors and accessiories
    if (scanResultItem.allowedAccess) {
        [cell.detailTextLabel setTextColor: [UIColor greenColor]];
    } else {
        [cell.detailTextLabel setTextColor: [UIColor redColor]];
    }
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	// Selecting object to tranfer with the segue
	self.scanResultItem = self.scanResultItems[indexPath.row];
	
	// We're going into detailed view
    [self performSegueWithIdentifier:@"logItemDetails" sender:self];
}

/**
 *  returns supported by this view controller interface orientations
 *
 *  @return returns a bit mask of allowed orientations
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // | UIInterfaceOrientationMaskPortraitUpsideDown;
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
	if ([segue.destinationViewController isKindOfClass:[VTKLogDetailTableViewController class]]) {
		VTKLogDetailTableViewController *destination = segue.destinationViewController;
		destination.logItem = self.scanResultItem;
	}
}

@end
