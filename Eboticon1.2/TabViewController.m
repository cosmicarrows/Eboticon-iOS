//
//  TabViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "TabViewController.h"
#import "WhatsNewMainViewController.h"
#import "GifCollectionViewController.h"
#import "MainViewController.h"
#import "ShopViewController.h"
#import "KeyboardTutorialViewController.h"
#import "MoreViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (id)initWithCategory:(id )identifier {
     self.gifCategory = identifier;
    
    if ( self = [super init] ) {

        if (identifier) {
            return self;
        } else {
            return nil;
        }
    } else
        return nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MainViewController *homeViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    
 
    
    homeViewController.gifCategory = _gifCategory;
    UINavigationController* homeNavController = [[UINavigationController alloc]
                                                     initWithRootViewController:homeViewController];
                        
    
    WhatsNewMainViewController *whatsNewMainViewController = [[WhatsNewMainViewController alloc] initWithStyle:UITableViewStylePlain];
     UINavigationController* whatsNewNavController = [[UINavigationController alloc]
     initWithRootViewController:whatsNewMainViewController];
    
    
    ShopViewController *shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopView" bundle:nil];
    UINavigationController* shopNavController = [[UINavigationController alloc]
                                                     initWithRootViewController:shopViewController];
    
    KeyboardTutorialViewController *keyboardTutorialViewController = [[KeyboardTutorialViewController alloc] init];
    MoreViewController *moreViewController= [[MoreViewController alloc] initWithNibName:@"MoreView" bundle:nil];

    
    //
    //[self.navigationController pushViewController:whatsNewMainViewController animated:YES];
    
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:homeNavController];
    [tabViewControllers addObject:shopNavController];
    [tabViewControllers addObject:whatsNewNavController];
    [tabViewControllers addObject:keyboardTutorialViewController];
    [tabViewControllers addObject:moreViewController];
    
    [self setViewControllers:tabViewControllers];
    //can't set this until after its added to the tab bar
    homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                     image:[[UIImage imageNamed:@"tabbar-home-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                             selectedImage:[[UIImage imageNamed:@"tabbar-home-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    
    shopNavController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-cart-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-cart-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    shopNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    whatsNewNavController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-star-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-star-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    whatsNewNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    
    keyboardTutorialViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-keyboard-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-keyboard-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    keyboardTutorialViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    moreViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-gear-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-gear-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    moreViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    
    [self.tabBar setBarTintColor:[UIColor colorWithRed:37.0f/255.0f green:21.0f/255.0f blue:48.0f/255.0f alpha:0.5f]]; //
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
