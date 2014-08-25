//
//  TCTLAppDelegate.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 21.08.14.
//  Copyright (c) 2014 v-Ticket system. All rights reserved.
//

#import "TCTLAppDelegate.h"

@implementation TCTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// The registration domain is volatile.  It does not persist across launches.
    // You must register your defaults at each launch; otherwise you will get
    // (system) default values when accessing the values of preferences the
    // user (via the Settings app) or your app (via set*:forKey:) has not
    // modified.  Registering a set of default values ensures that your app always
    // has a known good set of values to operate on.
	[self populateRegistrationDomain];
    // Override point for customization after application launch.
	[[MLScanner sharedInstance] setup];
	
    return YES;
}

// -------------------------------------------------------------------------------
//	populateRegistrationDomain
//  Locates the file representing the root page of the settings for this app,
//  invokes loadDefaults:fromSettingsPage:inSettingsBundleAtURL: on it,
//  and registers the loaded values as the app's defaults.
// -------------------------------------------------------------------------------

- (void)populateRegistrationDomain
{
    NSURL *settingsBundleURL = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"bundle"];
    
	if (!settingsBundleURL) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    // loadDefaults:fromSettingsPage:inSettingsBundleAtURL: expects its caller
    // to pass it an initialized NSMutableDictionary.
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
    
    // Invoke loadDefaults:fromSettingsPage:inSettingsBundleAtURL: on the property
    // list file for the root settings page (always named Root.plist).
    [self loadDefaults:appDefaults fromSettingsPage:@"Root.plist" inSettingsBundleAtURL:settingsBundleURL];
    
    // appDefaults is now populated with the preferences and their default values.
    // Add these to the registration domain.
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// -------------------------------------------------------------------------------
//	loadDefaults:fromSettingsPage:inSettingsBundleAtURL:
//  Helper function that parses a Settings page file, extracts each preference
//  defined within along with its default value, and adds it to a mutable
//  dictionary.  If the page contains a 'Child Pane Element', this method will
//  recurs on the referenced page file.
// -------------------------------------------------------------------------------
- (void)loadDefaults:(NSMutableDictionary*)appDefaults fromSettingsPage:(NSString*)plistName inSettingsBundleAtURL:(NSURL*)settingsBundleURL
{
    // Each page of settings is represented by a property-list file that follows
    // the Settings Application Schema:
    // <https://developer.apple.com/library/ios/#documentation/PreferenceSettings/Conceptual/SettingsApplicationSchemaReference/Introduction/Introduction.html>.
    
    // Create an NSDictionary from the plist file.
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfURL:[settingsBundleURL URLByAppendingPathComponent:plistName]];
    
    // The elements defined in a settings page are contained within an array
    // that is associated with the root-level PreferenceSpecifiers key.
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    for (NSDictionary *prefItem in prefSpecifierArray)
		// Each element is itself a dictionary.
    {
        // What kind of control is used to represent the preference element in the
        // Settings app.
        NSString *prefItemType = prefItem[@"Type"];
        // How this preference element maps to the defaults database for the app.
        NSString *prefItemKey = prefItem[@"Key"];
        // The default value for the preference key.
        NSString *prefItemDefaultValue = prefItem[@"DefaultValue"];
        
        if ([prefItemType isEqualToString:@"PSChildPaneSpecifier"])
			// If this is a 'Child Pane Element'.  That is, a reference to another
			// page.
        {
            // There must be a value associated with the 'File' key in this preference
            // element's dictionary.  Its value is the name of the plist file in the
            // Settings bundle for the referenced page.
            NSString *prefItemFile = prefItem[@"File"];
            
            // Recurs on the referenced page.
            [self loadDefaults:appDefaults fromSettingsPage:prefItemFile inSettingsBundleAtURL:settingsBundleURL];
        }
        else if (prefItemKey != nil && prefItemDefaultValue != nil)
			// Some elements, such as 'Group' or 'Text Field' elements do not contain
			// a key and default value.  Skip those.
        {
            [appDefaults setObject:prefItemDefaultValue forKey:prefItemKey];
        }
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
