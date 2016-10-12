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
#import "SWRevealViewController.h"
#import "RightViewController.h"
#import "XOSplashVideoController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface AppDelegate()<SWRevealViewControllerDelegate>
@end

@implementation AppDelegate


#pragma mark -
#pragma mark AppDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    //[self showSplashVideo];
    
    //PARSE
    //[Parse setApplicationId:@"gBcNi8fexXd1Uiggm6e2hRFuOPkoEefsbxLDNzO7"
                  //clientKey:@"dKZXWc9CXdksCA7HPVSCp0Yz0tTBQuqnQEvXKwL6"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
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

        
        [iRate sharedInstance].daysUntilPrompt = 10;
        [iRate sharedInstance].usesUntilPrompt = 5;
        //[iRate sharedInstance].verboseLogging = YES;
        [iRate sharedInstance].promptAtLaunch = YES;
        [iRate sharedInstance].eventsUntilPrompt = 5;
        [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
        [iRate sharedInstance].remindPeriod = 7;
        //TODO: Set below to no before deploying!
        [iRate sharedInstance].previewMode = NO;
        
        DDLogInfo(@"%@: Number of events until iRate launch %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].eventCount);
        
        DDLogInfo(@"%@: Number of iRate uses %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].usesCount);
        
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
