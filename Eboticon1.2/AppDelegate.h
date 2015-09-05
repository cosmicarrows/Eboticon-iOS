//
//  AppDelegate.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/23/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabViewController.h"
#import "SWRevealViewController.h"
#import "XOSplashVideoController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, XOSplashVideoDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TabViewController *tabBarController;
@property (strong, nonatomic) SWRevealViewController *viewController;


@end

