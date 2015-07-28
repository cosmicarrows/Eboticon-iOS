//
//  AppDelegate.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/23/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import "AppDelegate.h"
#import "JMCategoriesData.h"
#import "MasterViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "iRate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Harpy.h"
#import "Constants.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    JMCategoriesData *allRow = [[JMCategoriesData alloc] initWithTitle:@"All" thumbImage:[UIImage imageNamed:@"AllIcon.png"] ];
    JMCategoriesData *recentsRow = [[JMCategoriesData alloc] initWithTitle:@"Recent"  thumbImage:[UIImage imageNamed:@"RecentIcon"] ];
    JMCategoriesData *captionsRow = [[JMCategoriesData alloc] initWithTitle:@"Caption" thumbImage:[UIImage imageNamed:@"CaptionIcon.png"] ];
    JMCategoriesData *noCaptionsRow = [[JMCategoriesData alloc] initWithTitle:@"No Caption" thumbImage:[UIImage imageNamed:@"NoCaptionIcon.png"] ];
    JMCategoriesData *moreRow = [[JMCategoriesData alloc] initWithTitle:@"More" thumbImage:[UIImage imageNamed:@"MoreIcon.png"] ];

    
    //Setting up homepage rows
    NSMutableArray *homepageRows = [NSMutableArray arrayWithObjects:allRow,recentsRow,captionsRow,noCaptionsRow,moreRow,nil];
    
    //Setting up Navigation Bar
    UINavigationController * navController = (UINavigationController *) self.window.rootViewController;
    //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xFf6c00)];
    //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x7e00c0)];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
   // [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:YES];


    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"LinkinPark-ExtraBold" size:21.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0xFf6c00)]; //Color of back button
    

    MasterViewController * masterController = [navController.viewControllers objectAtIndex:0];
    masterController.categories = homepageRows;
    
    //GOOGLE ANALYTICS INITIALIZER
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

    
    // Initialize tracker. Replace with your tracking ID.
#ifdef FREE
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-48552713-3"];
    DDLogInfo(@"Google Analytics Enabled for Lite Version");
#else
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-48552713-2"];
    DDLogInfo(@"Google Analytics Enabled for Paid Version");
#endif
    
    //Set dry run to yes for testing purposes
    [[GAI sharedInstance] setDryRun:NO];
    
    //Set version for app tracking
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:version];
    [[GAI sharedInstance].defaultTracker set:kGAISampleRate value:@"50.0"];
    
    //Cocoalumberjack init files
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    //configure iRate
    [self configureiRate];
    
    //Harpy
    //TODO: turn on Harpy
    [self configureHarpy];
    
    //FABRIC
    [Fabric with:@[CrashlyticsKit]];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    //PARSE
    [Parse setApplicationId:@"gBcNi8fexXd1Uiggm6e2hRFuOPkoEefsbxLDNzO7"
                  clientKey:@"dKZXWc9CXdksCA7HPVSCp0Yz0tTBQuqnQEvXKwL6"];
    
    // Override point for customization after application launch.
    return YES;
}

/**
 *  Setup Harpy update reminder
 */
- (void) configureHarpy
{
    @try {
        // Present Window before calling Harpy
        [self.window makeKeyAndVisible];
        
        // Set the App ID for your app
#ifdef FREE
        [[Harpy sharedInstance] setAppID:@"977505283"];
#else
        [[Harpy sharedInstance] setAppID:@"899011953"];
#endif
        
        // Set the UIViewController that will present an instance of UIAlertController
        [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
        
        // (Optional) The tintColor for the alertController
        //[[Harpy sharedInstance] setAlertControllerTintColor:@"<#alert_controller_tint_color#>"];
        
        // (Optional) Set the App Name for your app
#ifdef FREE
        [[Harpy sharedInstance] setAppName:@"Eboticon Lite"];
#else
        [[Harpy sharedInstance] setAppName:@"Eboticon"];
#endif
        
        // Perform check for new version of your app 
        [[Harpy sharedInstance] checkVersion];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in enabling Harpy: %@", exception.description);
    }
    
}

/**
 *  Setup iRate rating scheme
 */
- (void) configureiRate
{
    @try {
#ifdef FREE
        [iRate sharedInstance].appStoreID = appStoreID_lite;
#else
        [iRate sharedInstance].appStoreID = appStoreID;
#endif
        
        [iRate sharedInstance].daysUntilPrompt = 7;
        //[iRate sharedInstance].usesUntilPrompt = 5;
        //[iRate sharedInstance].verboseLogging = YES;
        [iRate sharedInstance].promptAtLaunch = NO;
        [iRate sharedInstance].eventsUntilPrompt = 5;
        [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
        [iRate sharedInstance].remindPeriod = 7;
        //TODO: Set below to no before deploying!
        [iRate sharedInstance].previewMode = NO;
        
        DDLogInfo(@"%@: Number of events until iRate launch %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].eventCount);
        DDLogInfo(@"%@: Prompt for rating criteria met: %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].shouldPromptForRating);
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in enabling iRate: %@", exception.description);
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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
