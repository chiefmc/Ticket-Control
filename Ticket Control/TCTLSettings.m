//
//  TCTLSettings.m
//  Ticket Control
//
//  Created by Евгений Лысенко on 10.04.15.
//  Copyright (c) 2015 v-Ticket system. All rights reserved.
//

#import "TCTLSettings.h"
#import "TCTLConstants.h"
#import "VTKScannerManager.h"

@implementation TCTLSettings

+(instancetype)storage
{
    static TCTLSettings *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[self alloc] privateInit];
    });
    return storage;
}

/**
 *  This method must not be called as this is a Singleton-type object
 *  Will throw exception on compile.
 *
 *  @return None
 */
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Wrong usage of singleton object"
                                   reason:@"You're trying to init the signleton object. Please use the +storage instead."
                                 userInfo:nil];
}

- (instancetype)privateInit
{
    return [super init];
}

#pragma mark

- (void)load
{
    // The registration domain is volatile.  It does not persist across launches.
    // You must register your defaults at each launch; otherwise you will get
    // (system) default values when accessing the values of preferences the
    // user (via the Settings app) or your app (via set*:forKey:) has not
    // modified.  Registering a set of default values ensures that your app always
    // has a known good set of values to operate on.
    [self populateRegistrationDomain];
    
    // Load our preferences.  Preloading the relevant preferences here will
    // prevent possible diskIO latency from stalling our code in more time
    // critical areas, such as tableView:cellForRowAtIndexPath:, where the
    // values associated with these preferences are actually needed.
    [self performSelector:@selector(onDefaultsChanged:)
               withObject:self
               afterDelay:1.0];
    // [self onDefaultsChanged:nil];
    
    // Begin listening for changes to our preferences when the Settings app does
    // so, when we are resumed from the backround, this will give us a chance to
    // update our UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDefaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

-(void)close
{
    // Stop listening for the NSUserDefaultsDidChangeNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
}


#pragma mark - Preferences

/**
 *  Handler for the NSUserDefaultsDidChangeNotification. Loads the preferences from the defaults database into the holding properies, then asks the tableView to reload itself.
 *
 *  @param aNotification The notification object that caused the mathod call
 */
- (void)onDefaultsChanged:(NSNotification*)aNotification
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    self.vibroStrength		= (NSInteger)[standardDefaults integerForKey: VIBRO_STRENGTH_S];
    self.scannerBeep		= [standardDefaults boolForKey: SCANNER_BEEP_S];
    self.disableAutolock	= [standardDefaults boolForKey: DISABLE_AUTOLOCK_S];
    self.userGUID			= [standardDefaults objectForKey: USER_GUID_S];
    self.resultDisplayTime	= (NSTimeInterval)[standardDefaults integerForKey:RESULT_DISPLAY_TIME_S];
    self.serverURL			= [NSURL URLWithString:[standardDefaults objectForKey: SERVER_URL_S]];

//TODO:Нужно отрефакторить этот кусок
    
//    if ([self isScannerConnected]) {
//        [self setScannerPreferences];
//    }
//    
//    if (self.disableAutolock) {
//        [UIApplication sharedApplication].idleTimerDisabled = YES;
//    } else {
//        [UIApplication sharedApplication].idleTimerDisabled = NO;
//    }
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

/**
 *  Sets the hardware scanner settings
 */
- (void)setScannerPreferences
{
    //TODO: Незакончено
    // Устанавливаем настройки сканера из Settings Bundle
//    [[VTKScannerManager sharedInstance] beepSwitch: self.scannerBeep];
//    [[VTKScannerManager sharedInstance] vibraMotorStrength: (enum vibraMotorStrengthDef)self.vibroStrength];
}

@end
