//
//  TCTLLogDetailTableViewController.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 04.09.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLLogDetailTableViewController.h"
#import "TCTLConstants.h"

@interface TCTLLogDetailTableViewController ()

@property (weak, nonatomic) NSMutableArray *logKeys;		// Names of the keys we get from the logItem's NSDictionary
@property (weak, nonatomic) NSMutableArray *logValues;	// Values of the above keys

@end

@implementation TCTLLogDetailTableViewController

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
	
	// Translating Date/Time to a readable format
	
	// Dictionaries to translate
	NSDictionary* logKeysTranslation = @{
										 BARCODE_KEY				: @"Штрих-код",
										 GUID_KEY					: @"GUID устройства",
										 CLIENT_APP_VERSION_KEY		: @"Версия приложения",
										 SERVER_API_VERSION_KEY		: @"Версия API",
										 RESPONSE_CODE_KEY			: @"Код ответа",
										 USER_NAME_KEY				: @"Точка контроля",
										 EVENT_NAME_KEY				: @"Мероприятие",
										 EVENT_START_KEY			: @"Дата/Время начала",
										 CONTROL_START_KEY			: @"Начало контроля",
										 CONTROL_END_KEY			: @"Окончание контроля",
										 AGENT_CHECKED_KEY			: @"Проходил через",
										 TIME_CHECKED_KEY			: @"Время прохода",
										 CLIENT_NEEDS_UPDATE_KEY	: @"Необходимо обновление",
										 SECTOR_KEY					: @"Сектор",
										 ROW_KEY					: @"Ряд",
										 SEAT_KEY					: @"Место",
										 };
	
	NSDictionary* logValuesTranslation = @{
										   @"true" : @"да",
										   @"false": @"нет",
										   @"0x100": @"Ok",
										   @"0x111": @"Имя точки контроля",
										   @"0x112": @"Неизвестный GUID",
										   @"0x121": @"Активное событие",
										   @"0x122": @"Нет активного события",
										   @"0x210": @"Доступ разрешён",
										   @"0x211": @"Билет не найден",
										   @"0x212": @"Билет уже проходил",
										   @"0x213": @"Неверный вход",
										   @"0x214": @"Нет активного события",
										   @"0x220": @"Неизвестная ошибка",
										   @"0x301": @"Ошибка сети",
										   @"0x302": @"Неизвестный ответ",
										   };
	
	// Cleaning the details from hidden data
	NSDictionary *log = (NSDictionary *)_logItem.serverParsedResponse;
		
	// Extracting keys and values from the logItem
	_logKeys	= [NSMutableArray arrayWithArray:[log allKeys]];
	_logValues	= [NSMutableArray arrayWithArray:[log allValues]];
	
	// Translating keys and values into readable format
	unsigned int i = 0;
	NSString *key;
	NSString *value;
	
	// This is date/time tamplates to operate the data in server's response
	NSDateFormatter *dateFormatFromServer = [NSDateFormatter new];
	[dateFormatFromServer setDateFormat:DATETIME_SERVER_FORMAT];
	
	NSDateFormatter *dateFormatToDisplay = [NSDateFormatter new];
	[dateFormatToDisplay setDateFormat:DATETIME_TO_DISPLAY];
	
	// Below are a temp vars for date from server and a converted localized string
	NSDate   *dateTime;
	NSString *dateTimeConverted;
	
	for (NSString *logKey in log) {
		if ([logKey isEqualToString:GUID_KEY])
		{
			// If the item is the GUID - we're hiding it's value
			[_logValues replaceObjectAtIndex:i
								  withObject:@"***-***"];
		} else if (([logKey isEqualToString:EVENT_START_KEY]) ||
				   ([logKey isEqualToString:CONTROL_START_KEY]) ||
				   ([logKey isEqualToString:CONTROL_END_KEY]) ||
				   ([logKey isEqualToString:TIME_CHECKED_KEY]))
		{
			// If the parameter is date/time, we're changing it to a viewable format
			dateTime = [dateFormatFromServer dateFromString:_logValues[i]];
			dateTimeConverted = [dateFormatToDisplay stringFromDate:dateTime];
			[_logValues replaceObjectAtIndex:i
								  withObject:dateTimeConverted];
		}
		
		// We're  going through dictionary
		key = logKeysTranslation[logKey];
		if (key) {
			[_logKeys replaceObjectAtIndex:i
								withObject:key];
		}
		value = logValuesTranslation[log[logKey]];
		if (value) {
			[_logValues replaceObjectAtIndex:i
								  withObject:value];
		}
		i++;
	}
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
    return [_logItem.serverParsedResponse count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logDetailItemCell" forIndexPath:indexPath];
    
    // Configure the cell...
	
	cell.textLabel.text			= _logKeys[indexPath.row];
	cell.detailTextLabel.text	= _logValues[indexPath.row];

    return cell;
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
