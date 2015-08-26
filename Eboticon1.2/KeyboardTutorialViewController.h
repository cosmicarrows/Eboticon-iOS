//
//  APPViewController.h
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface KeyboardTutorialViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>{
    UIButton *btnGoPreviousPage;
    UIButton *btnGoNextPage;
    NSInteger currentPageIndex;
    UIPageControl *pageControl;
}

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end
