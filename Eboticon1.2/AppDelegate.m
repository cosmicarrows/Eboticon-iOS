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
//#import <Parse/Parse.h>
#import "SWRevealViewController.h"
#import "RightViewController.h"
#import "XOSplashVideoController.h"
#import "UIView+Toast.h"

#import "Eboticon-Swift.h"


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate, SWRevealViewControllerDelegate>
@end
#else
@interface AppDelegate()<SWRevealViewControllerDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

#pragma mark -
#pragma mark AppDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    //[self showSplashVideo];
    
    //Configure PushNotifications
    [self configurePushNotifications];
   
    
    [self initialize];
    // Override point for customization after application launch.
    return YES;
    
}

/**
 *  Setup iRate rating scheme
 */
- (void) configureiRate
{
    @try {

        [iRate sharedInstance].appStoreID = appStoreID;

        
        [iRate sharedInstance].daysUntilPrompt = 2;
        [iRate sharedInstance].usesUntilPrompt = 1;
        //[iRate sharedInstance].verboseLogging = YES;
        [iRate sharedInstance].promptAtLaunch = YES;
        [iRate sharedInstance].eventsUntilPrompt = 5;
        [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
        [iRate sharedInstance].remindPeriod = 7;
        [iRate sharedInstance].previewMode = NO;
        
        //DDLogInfo(@"%@: Number of events until iRate launch %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].eventCount);
        
        DDLogInfo(@"%@: Number of iRate uses %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].usesCount);
        
        DDLogInfo(@"%@: Prompt for rating criteria met: %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].shouldPromptForRating);
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in enabling iRate: %@", exception.description);
    }

}



#pragma mark -
#pragma mark Push Notification Methods


/**
 *  Configure Push Notifications
 */
- (void) configurePushNotifications
{
    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
            
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            // For iOS 10 data message (sent via FCM)
            [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
    
    // [START configure_firebase];
    [FirebaseConfigurator sharedInstance];

    // [END configure_firebase]
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
}




// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", userInfo);
    
    // Show Notification Toast
    NSLog(@"Show Toast...");
    [self.window.rootViewController.view makeToast:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                          duration:5.0
                                          position:CSToastPositionTop];

    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    
    // Show Notification Toast
    NSLog(@"Show Toast...");
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.window.rootViewController.view makeToast:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                          duration:5.0
                                          position:CSToastPositionTop];    
    completionHandler();
}
#endif
// [END ios_10_message_handling]

// [START ios_10_data_message_handling]
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Print full message
    NSLog(@"%@", remoteMessage.appData);
}
#endif
// [END ios_10_data_message_handling]

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm {
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
            
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}


//Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
// the InstanceID token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs token here.
    // [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}

// [START connect_on_active]
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connectToFcm];
    
    //Clear Badges
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}
// [END connect_on_active]

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]



// Tells the app that a remote notification arrived that indicates there is data to be fetched.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print full message.
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", userInfo);
    
    // Show Notification Toast
    NSLog(@"Show Toast...");
    [self.window.rootViewController.view makeToast:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                          duration:5.0
                                          position:CSToastPositionTop];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print full message.
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", userInfo);
    
    // Show Notification Toast
    NSLog(@"Show Toast...");
    [self.window.rootViewController.view makeToast:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                duration:5.0
                position:CSToastPositionTop];
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark Initialize

- (void) showSplashVideo {
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    
    NSLog(@"Screen Height %f", self.window.frame.size.height);
    
    NSString *portraitVideoName = @"EboticonIntroNEW640x960";
    NSString *portraitImageName = @"iphone640x960.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.window.frame.size.height > 480) {
        portraitImageName = @"iphone640x1136.png";
        portraitVideoName = @"EboticonIntroNEW640x1136";
    }
    
    NSString *landscapeVideoName = nil; // n/a
    NSString *landscapeImageName = nil; // n/a
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        portraitVideoName = @"EboticonIntroNEW768x1024";
        portraitImageName = @"ipad768x1024.png";
        landscapeVideoName = @"EboticonIntroNEW768x1024.mp4";
        landscapeImageName = @"ipad768x1024.png";
    }
    
    // our video
    NSURL *portraitUrl = [[NSBundle mainBundle] URLForResource:portraitVideoName withExtension:@"mp4"];
    NSURL *landscapeUrl = [[NSBundle mainBundle] URLForResource:landscapeVideoName withExtension:@"mp4"];
    
    // our splash controller
    XOSplashVideoController *splashVideoController =
    [[XOSplashVideoController alloc] initWithVideoPortraitUrl:portraitUrl
                                            portraitImageName:portraitImageName
                                                 landscapeUrl:landscapeUrl
                                           landscapeImageName:landscapeImageName
                                                     delegate:self];
    // we'll start out with the spash view controller in the window
    self.window.rootViewController = splashVideoController;
    
    [self.window makeKeyAndVisible];
    
}

- (void) initialize {
    _products = nil;
    
    [[EboticonIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            NSLog(@"--------DONE-------");
        }
    }];
    
    arrImagePagerImages = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 1 ; i <= 4 ; i ++){
        NSString *sUrl = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/store/banner%i.png", (int)i];
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: sUrl]];
        //The code below was added on 10/10/2016 because the app was crashing when trying to load store banners
        //new code added ends on line 201.  The lines 202 and 203 were commented out which was the original code.
        UIImage *image = [UIImage imageWithData:data];
        if (image != nil) {
            [arrImagePagerImages addObject:image];
        } else {
            NSLog(@"Unable to convert data to image");
        }
        //if (data == nil)continue;
        //[arrImagePagerImages addObject:[UIImage imageWithData:data]];
    }
    
    //Setting up Navigation Bar
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x380063)];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"Avenir-Black" size:21.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0xFf6c00)]; //Color of back button
    
    //Tabbar With sidebar Items
    NSNumber *caption = @(1); //initialize caption to on
    self.tabBarController = [[TabViewController alloc] initWithCaption:caption];
    RightViewController *rightViewController = [[RightViewController alloc] init];
    SWRevealViewController *mainRevealController = [[SWRevealViewController alloc]
                                                    initWithRearViewController:rightViewController frontViewController:self.tabBarController];
    mainRevealController.rightViewController = rightViewController;
    mainRevealController.delegate = self;
    self.viewController = mainRevealController;
    
    //Add Tab Bar
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window.rootViewController = self.tabBarController;
    self.window.rootViewController = self.viewController;
    
 
    
    UIImageView *splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    [self.window addSubview:splashScreen];
    [self.window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.3 animations:^{splashScreen.alpha = 0.0;}
                     completion:(void (^)(BOOL)) ^{
                         [splashScreen removeFromSuperview];
                     }
     ];
    
    // Present Window before calling Harpy
    //[self.window makeKeyAndVisible];
    
    
    //GOOGLE ANALYTICS INITIALIZER
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    
    // Initialize tracker. Replace with your tracking ID.
#ifdef FREE
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-48552713-3"];
    DDLogInfo(@"Google Analytics Enabled for Lite Version");
#else
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-48552713-4"];
    DDLogInfo(@"Google Analytics Enabled for Paid Version");
#endif
    
    //Set dry run to yes for testing purposes
    [[GAI sharedInstance] setDryRun:NO];
    
    //Set version for app tracking
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:version];
    [[GAI sharedInstance].defaultTracker set:kGAISampleRate value:@"50.0"];
    
    //Cocoalumberjack init files
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    //configure iRate
    [self configureiRate];
    
    //Harpy
    //TODO: turn on Harpy
    [self configureHarpy];
    
    //FABRIC
    [Fabric with:@[CrashlyticsKit]];
}

/**
 *  Setup Harpy update reminder
 */
- (void) configureHarpy
{
    @try {
        
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


#pragma mark -
#pragma mark Reveal Controller Delegate

- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController willRevealRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willHideRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willShowFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didShowFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController willHideFrontViewController:(UIViewController *)rearViewController
{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SWRevealViewController *)revealController didHideFrontViewController:(UIViewController *)rearViewController

{
    NSLog( @"%@", NSStringFromSelector(_cmd));
}


#pragma mark Splash Video

- (void)splashVideoLoaded:(XOSplashVideoController *)splashVideo
{
    // load up our real view controller, but don't put it in to the window until the video is done
    // if there's anything expensive to do it should happen in the background now
    
   //
    
   // self.viewController = [[XOViewController alloc] initWithNibName:@"XOViewController" bundle:nil];
}

- (void)splashVideoComplete:(XOSplashVideoController *)splashVideo
{
    // swap out the splash controller for our app's
    //self.window.rootViewController = self.viewController;
    [self initialize];
}
@end
