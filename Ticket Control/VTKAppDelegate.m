//
//  TCTLAppDelegate.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "VTKSettings.h"
#import "VTKAppDelegate.h"
#import "VTKScannerManager.h"
#import "VTKScanResultItem.h"

@implementation VTKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize and load the app's settings
    [[VTKSettings storage] load];
    
    // Готовим лог ответов от сервера
    [self prepareScanResultItems];
    
    return YES;
}

/**
 *  Prepares the log containing scan results from last session. It deletes all entries older than 24 hours.
 */
- (void)prepareScanResultItems
{
    // фильтрация истории сканирования
    NSMutableArray *scanResultItems = [VTKSettings storage].scanResultItems;
    if (scanResultItems) {
        for (VTKScanResultItem *logItem in scanResultItems) {
            // если записи в логе больше 24 часов удаляем её
            if ([logItem.locallyCheckedTime compare: [[NSDate date] dateByAddingTimeInterval: -24*60*60]] == NSOrderedAscending) {
                [scanResultItems removeObject: logItem];
            }
        }
    } else {
        // если лога нет, то создаём пустой
        [VTKSettings storage].scanResultItems = [NSMutableArray new];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    id<VTKBarcodeScannerProtocol> scanner = [VTKScannerManager sharedInstance].scanner;
    if (scanner) {
        [scanner wakeup];
    }
}

/**
 *  @inheritdoc
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Tear down the settings storage
    [[VTKSettings storage] close];
}

@end
