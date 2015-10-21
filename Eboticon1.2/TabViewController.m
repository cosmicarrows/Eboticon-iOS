//
//  TabViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "TabViewController.h"
//#import "WhatsNewMainViewController.h"
#import "WhatsNewWebViewController.h"
#import "GifCollectionViewController.h"
#import "MainViewController.h"
#import "ShopViewController.h"
#import "KeyboardTutorialViewController.h"
#import "MoreViewController.h"
#import "CustomNavigationController.h"

@interface TabViewController ()<UITabBarDelegate>{
        NSInteger currentIndex;
}

@property(nonatomic,strong)NSMutableDictionary * itemsStatus;
@property(nonatomic,weak)UIView * moveView;
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

- (id)initWithCaption:(NSNumber*)caption{
    self.caption = caption;
    
    if ( self = [super init] ) {
        
        if (caption) {
            return self;
        } else {
            return nil;
        }
    } else
        return nil;
}


- (id)initWithCategory:(id )identifier caption:(NSNumber*)caption{
    self.gifCategory = identifier;
    self.caption = caption;
    
    if ( self = [super init] ) {
        
        if (identifier && caption) {
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
    
    //
    NSLog(@"caption state %ld",(long)self.caption);
    homeViewController.gifCategory = self.gifCategory;
    homeViewController.captionState = self.caption;
    
    UINavigationController* homeNavController = [[CustomNavigationController alloc]
                                                     initWithRootViewController:homeViewController];
                        
    
//    WhatsNewMainViewController *whatsNewMainViewController = [[WhatsNewMainViewController alloc] initWithStyle:UITableViewStylePlain];
//     UINavigationController* whatsNewNavController = [[UINavigationController alloc] initWithRootViewController:whatsNewMainViewController];
    WhatsNewWebViewController *whatsNewWebViewController = [[WhatsNewWebViewController alloc] initWithURL:@"http://inclingconsulting.com/eboticon/" title:@"WHAT'S NEW"];
    UINavigationController* whatsNewNavController = [[UINavigationController alloc] initWithRootViewController:whatsNewWebViewController];
    
    
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
    homeViewController.tabBarItem.tag=0;

    
    shopNavController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-cart-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-cart-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    shopNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    shopNavController.tabBarItem.tag=1;
    
    whatsNewNavController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-star-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-star-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    whatsNewNavController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    whatsNewNavController.tabBarItem.tag=2;
    
    
    keyboardTutorialViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-keyboard-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-keyboard-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    keyboardTutorialViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    keyboardTutorialViewController.tabBarItem.tag=3;
    
    moreViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@""
                                  image:[[UIImage imageNamed:@"tabbar-gear-white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          selectedImage:[[UIImage imageNamed:@"tabbar-gear-orange"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    moreViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    moreViewController.tabBarItem.tag=4;
    
    
    [self.tabBar setBarTintColor:[UIColor colorWithRed:37.0f/255.0f green:21.0f/255.0f blue:48.0f/255.0f alpha:0.5f]]; //
    
    


    
    NSLog(@"%f", self.tabBar.frame.size.height);
    UIView * moveView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBar.frame.size.height-5, self.view.frame.size.width/5, 5)];
    moveView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:108.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.moveView = moveView;
    [self.tabBar addSubview:moveView];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self.revealViewController rightRevealToggleForTapGesture];
    
    NSLog(@"Did select item: %ld", (long)item.tag);
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width/self.viewControllers.count;
    static NSInteger lastIndex=0;
    currentIndex = item.tag;
    NSLog(@"currentIndex: %ld", (long)currentIndex);
    
    if (currentIndex != lastIndex) {
        CGFloat lastPosX = width * lastIndex + width/2;
        CGFloat nextPosX = width * currentIndex + width/2;
        CAKeyframeAnimation * keyAnimation = [CAKeyframeAnimation animation];
        keyAnimation.keyPath = @"position.x";
        if (currentIndex > lastIndex) {
            keyAnimation.values = @[@(lastPosX),@(nextPosX + 10),@(nextPosX)];
        }else{
            keyAnimation.values = @[@(lastPosX),@(nextPosX - 10),@(nextPosX)];
        }
        keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
    
        
        //CGFloat red = arc4random()/(CGFloat)INT_MAX;
        //CGFloat green = arc4random()/(CGFloat)INT_MAX;
        //CGFloat blue = arc4random()/(CGFloat)INT_MAX;
        
        //UIColor * color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        CABasicAnimation * basicAnimation = [CABasicAnimation animation];
        basicAnimation.keyPath = @"backgroundColor";
        //basicAnimation.toValue = (__bridge_transfer id)color.CGColor;
        
        CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[keyAnimation,basicAnimation];
        animationGroup.duration = 0.5;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        [self.moveView.layer addAnimation:animationGroup forKey:nil];
        lastIndex = currentIndex;
    }
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
