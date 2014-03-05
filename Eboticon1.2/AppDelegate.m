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
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /**
    JMCategoriesData *allRow = [[JMCategoriesData alloc] initWithTitle:@"All" thumbImage:[UIImage imageNamed:@"ladybugThumb.png"] ];
    JMCategoriesData *recentsRow = [[JMCategoriesData alloc] initWithTitle:@"Recent"  thumbImage:[UIImage imageNamed:@"ladybugThumb.png"] ];
    JMCategoriesData *captionsRow = [[JMCategoriesData alloc] initWithTitle:@"Caption" thumbImage:[UIImage imageNamed:@"ladybugThumb.png"] ];
    JMCategoriesData *noCaptionsRow = [[JMCategoriesData alloc] initWithTitle:@"NoCaption" thumbImage:[UIImage imageNamed:@"ladybugThumb.png"] ];
    JMCategoriesData *moreRow = [[JMCategoriesData alloc] initWithTitle:@"More" thumbImage:[UIImage imageNamed:@"centipedeThumb.png"] ];
     **/
    
    JMCategoriesData *allRow = [[JMCategoriesData alloc] initWithTitle:@"All" thumbImage:[UIImage imageNamed:@"blank"] ];
    JMCategoriesData *recentsRow = [[JMCategoriesData alloc] initWithTitle:@"Recent"  thumbImage:[UIImage imageNamed:@"blank"] ];
    JMCategoriesData *captionsRow = [[JMCategoriesData alloc] initWithTitle:@"Caption" thumbImage:[UIImage imageNamed:@"blank"] ];
    JMCategoriesData *noCaptionsRow = [[JMCategoriesData alloc] initWithTitle:@"NoCaption" thumbImage:[UIImage imageNamed:@"blank"] ];
    JMCategoriesData *moreRow = [[JMCategoriesData alloc] initWithTitle:@"More" thumbImage:[UIImage imageNamed:@"blank"] ];

    
    //Setting up homepage rows
    NSMutableArray *homepageRows = [NSMutableArray arrayWithObjects:allRow,recentsRow,captionsRow,noCaptionsRow,moreRow,nil];
    
    //Setting up Navigation Bar
    UINavigationController * navController = (UINavigationController *) self.window.rootViewController;
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xFf6c00)];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"LinkinPark-ExtraBold" size:21.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    

    MasterViewController * masterController = [navController.viewControllers objectAtIndex:0];
    masterController.categories = homepageRows;
    // Override point for customization after application launch.
    return YES;
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
