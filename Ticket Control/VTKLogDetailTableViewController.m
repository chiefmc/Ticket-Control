//
//  TCTLLogDetailTableViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 04.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKLogDetailTableViewController.h"
#import "VTKConstants.h"

@interface VTKLogDetailTableViewController ()

@property (strong, nonatomic) NSMutableArray *logKeys;		// Names of the keys we get from the logItem's NSDictionary
@property (strong, nonatomic) NSMutableArray *logValues;	// Values of the above keys

@end

@implementation VTKLogDetailTableViewController

/**
 *  @inheritdoc
 */
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 *  Sets initial translation dictionary for keys we get from server API.
 *
 *  @return inialized NSDictionary
 */
- (NSDictionary *)logKeysTranslation
{
    static NSDictionary *logKeysTranslated;
    if (!logKeysTranslated) {
        logKeysTranslated = @{
                              BARCODE_KEY				: NSLocalizedString(@"Штрих-код", @"элемент лога события"),
                              GUID_KEY					: NSLocalizedString(@"GUID устройства", @"элемент лога события"),
                              CLIENT_APP_VERSION_KEY	: NSLocalizedString(@"Версия приложения", @"элемент лога события"),
                              SERVER_API_VERSION_KEY	: NSLocalizedString(@"Версия API", @"элемент лога события"),
                              RESPONSE_CODE_KEY			: NSLocalizedString(@"Код ответа", @"элемент лога события"),
                              USER_NAME_KEY				: NSLocalizedString(@"Точка контроля", @"элемент лога события"),
                              EVENT_NAME_KEY			: NSLocalizedString(@"Мероприятие", @"элемент лога события"),
                              EVENT_START_KEY			: NSLocalizedString(@"Дата/Время начала", @"элемент лога события"),
                              CONTROL_START_KEY			: NSLocalizedString(@"Начало контроля", @"элемент лога события"),
                              CONTROL_END_KEY			: NSLocalizedString(@"Окончание контроля", @"элемент лога события"),
                              AGENT_CHECKED_KEY			: NSLocalizedString(@"Проходил через", @"элемент лога события"),
                              TIME_CHECKED_KEY			: NSLocalizedString(@"Время прохода", @"элемент лога события"),
                              CLIENT_NEEDS_UPDATE_KEY	: NSLocalizedString(@"Необходимо обновление", @"элемент лога события"),
                              SECTOR_KEY				: NSLocalizedString(@"Сектор", @"элемент лога события"),
                              ROW_KEY					: NSLocalizedString(@"Ряд", @"элемент лога события"),
                              SEAT_KEY					: NSLocalizedString(@"Место", @"элемент лога события"),
                              };
    }
    return logKeysTranslated;
}

/**
 *  Sets initial translation dictionary for values we get from server API.
 *
 *  @return inialized NSDictionary
 */
- (NSDictionary *)logValuesTranslation
{
    static NSDictionary *logValuesTranslated;
    if (!logValuesTranslated) {
        logValuesTranslated = @{
                                @"true" : NSLocalizedString(@"да", @"элемент лога события"),
                                @"false": NSLocalizedString(@"нет", @"элемент лога события"),
                                @"0x100": NSLocalizedString(@"Ok", @"элемент лога события"),
                                @"0x111": NSLocalizedString(@"Имя точки контроля", @"элемент лога события"),
                                @"0x112": NSLocalizedString(@"Неизвестный GUID", @"элемент лога события"),
                                @"0x121": NSLocalizedString(@"Активное событие", @"элемент лога события"),
                                @"0x122": NSLocalizedString(@"Нет активного события", @"элемент лога события"),
                                @"0x210": NSLocalizedString(@"Доступ разрешён", @"элемент лога события"),
                                @"0x211": NSLocalizedString(@"Билет не найден", @"элемент лога события"),
                                @"0x212": NSLocalizedString(@"Билет уже проходил", @"элемент лога события"),
                                @"0x213": NSLocalizedString(@"Неверный вход", @"элемент лога события"),
                                @"0x214": NSLocalizedString(@"Нет активного события", @"элемент лога события"),
                                @"0x220": NSLocalizedString(@"Неизвестная ошибка", @"элемент лога события"),
                                @"0x301": NSLocalizedString(@"Ошибка сети", @"элемент лога события"),
                                @"0x302": NSLocalizedString(@"Неизвестный ответ", @"элемент лога события"),
                                };
    }
    return logValuesTranslated;
}

/**
 *  @inheritdoc
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Let's clean the details from hidden data and translate them
	NSDictionary *log = (NSDictionary *)self.logItem.serverParsedResponse;
		
	// Extracting keys and values from the logItem
	self.logKeys	= [NSMutableArray arrayWithArray:[log allKeys]];
	self.logValues	= [NSMutableArray arrayWithArray:[log allValues]];
	
	// Translating keys and values into readable format
	unsigned int i = 0;
	NSString *key;
	NSString *value;
	
	// This is date/time templates to operate the data in server's response
    static NSDateFormatter *dateFormatterFromServer;
    if (!dateFormatterFromServer) {
        dateFormatterFromServer = [NSDateFormatter new];
        [dateFormatterFromServer setDateFormat:DATETIME_SERVER_FORMAT];
        [dateFormatterFromServer setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // change in 1.2 - assuming the server time is in UTC
    }
    static NSDateFormatter *dateFormatterToDisplay;
    if (!dateFormatterToDisplay) {
        dateFormatterToDisplay = [NSDateFormatter new];
        [dateFormatterToDisplay setDateFormat:DATETIME_TO_DISPLAY];
        [dateFormatterToDisplay setTimeZone:[NSTimeZone localTimeZone]]; // formatter of the time to local time
    }
	
	// Below are temp vars for date from server and a converted localized string
	NSDate   *dateTime;
	NSString *dateTimeConverted;
	
    // Now we need to enumarate the dictionary, translating its data to a human readable form
	for (NSString *currentLogKey in log) {
		if ([currentLogKey isEqualToString:GUID_KEY]) {
            // If the item is the GUID - we're hiding it's value
			[self.logValues replaceObjectAtIndex:i
									  withObject:@"******"];
		} else if (([currentLogKey isEqualToString:EVENT_START_KEY]) ||
				   ([currentLogKey isEqualToString:CONTROL_START_KEY]) ||
				   ([currentLogKey isEqualToString:CONTROL_END_KEY]) ||
                   ([currentLogKey isEqualToString:TIME_CHECKED_KEY])) {
            // If the parameter is date/time, we're changing it to a viewable format
			dateTime = [dateFormatterFromServer dateFromString:self.logValues[i]];
			dateTimeConverted = [dateFormatterToDisplay stringFromDate:dateTime];
            if (dateTimeConverted) { // check if the formatter returned a valid response
                [self.logValues replaceObjectAtIndex:i
                                          withObject:dateTimeConverted];
            }
		}
		
		// We're going through dictionary
		key = self.logKeysTranslation[currentLogKey];
		if (key) {
			[self.logKeys replaceObjectAtIndex:i
									withObject:key];
		}
		value = self.logValuesTranslation[log[currentLogKey]];
		if (value) {
			[self.logValues replaceObjectAtIndex:i
									  withObject:value];
		}
		i++;
	}
}

/**
 *  @inheritdoc
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/**
 *  @inheritdoc
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.logItem.serverParsedResponse count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
	
	cell.textLabel.text			= self.logKeys[indexPath.row];
	cell.detailTextLabel.text	= self.logValues[indexPath.row];

    return cell;
}

/**
 *  returns supported by this view controller interface orientations
 *
 *  @return returns a bit mask of allowed orientations
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
