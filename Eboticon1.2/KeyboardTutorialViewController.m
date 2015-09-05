//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "KeyboardTutorialViewController.h"
#import "TutorialContentViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KeyboardTutorialViewController () 

@end

@implementation KeyboardTutorialViewController

- (TutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count]))return nil;
    
    // Create a new view controller and pass suitable data.
    TutorialContentViewController *pageContentViewController = [[TutorialContentViewController alloc] initWithNibName:@"TutorialContentViewController" bundle:nil];
    
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = [self.pageTitles[index] uppercaseString];
    pageContentViewController.pageIndex = index;
    pageContentViewController.index = index;
    
    return pageContentViewController;
}

- (void)setContentPages{
    // Override point for customization after application launch.
    pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = UIColorFromRGB(0x7e00c0);
    pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xFf6c00);
    pageControl.backgroundColor = [UIColor clearColor];
    
    // Create the data model
    _pageTitles = @[@"Keyboard Instructions", @"Go to Settings", @"Click \"General\"", @"Click \"Keyboard\"", @"Click \"Add New Keyboard\"", @"Select \"Eboticon\"", @"Reselect \"Eboticon\"", @"Switch on \"Allow Full Access\"", @"Click \"Allow\" button", @"Then you are done!"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png", @"page5.png", @"page6.png", @"page7.png", @"page8.png", @"page9.png", @"page10.png"];
    
    // Create page view controller
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    //[[self.pageController view] setFrame:[[self view] bounds]];
    
    TutorialContentViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageController.view.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    self.pageController.delegate = self;
    currentPageIndex = 0;
    
    //[[self view] bringSubviewToFront:pageControl];
}

#pragma mark - page navigater methods

- (void)updateControllButtons{
    [btnGoPreviousPage setHidden:NO];
    [btnGoNextPage setHidden:NO];
    
    if (currentPageIndex == 0){
        [btnGoPreviousPage setHidden:YES];
    } else if (currentPageIndex == _pageTitles.count - 1){
        [btnGoNextPage setHidden:YES];
    }
}

- (void)loadNthPage:(NSInteger)targetPageIndex{
    TutorialContentViewController *firstViewController = [self viewControllerAtIndex:currentPageIndex];
    TutorialContentViewController *secondViewController = [self viewControllerAtIndex:targetPageIndex];
    
    NSArray *arrViewControllers = [NSArray arrayWithObjects:secondViewController, nil];
    
    if (currentPageIndex > targetPageIndex){
        [self.pageController setViewControllers:arrViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    } else if (currentPageIndex < targetPageIndex) {
        [self.pageController setViewControllers:arrViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    } else {
        [self.pageController setViewControllers:arrViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    currentPageIndex = targetPageIndex;
    [self updateControllButtons];
}

- (void)goNextPage{
    if (currentPageIndex == _pageTitles.count - 1)return;
    [self loadNthPage:currentPageIndex + 1];
}

- (void)goPreviousPage{
    if (currentPageIndex == 0)return;
    [self loadNthPage:currentPageIndex - 1];
}

- (void)addControlButtons{
    CGFloat fWidth = 20;
    CGFloat fHeight = 40;
    
    CGRect frame1 = CGRectMake(5, self.view.frame.size.height / 2.0 - fHeight / 2.0, fWidth, fHeight);
    CGRect frame2 = CGRectMake(self.view.frame.size.width - 5 - fWidth, self.view.frame.size.height / 2.0 - fHeight / 2.0, fWidth, fHeight);
    
    btnGoPreviousPage = [[UIButton alloc]initWithFrame:frame1];
    [btnGoPreviousPage setBackgroundImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
    [btnGoPreviousPage addTarget:self action:@selector(goPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGoPreviousPage];
    
    btnGoNextPage = [[UIButton alloc]initWithFrame:frame2];
    [btnGoNextPage setBackgroundImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
    [btnGoNextPage addTarget:self action:@selector(goNextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGoNextPage];
    
    [btnGoPreviousPage setHidden:YES];
}

#pragma mark - default methods of uiviewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentPages];
    [self addControlButtons];
}


- (IBAction)startWalkthrough:(id)sender {
    TutorialContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialContentViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TutorialContentViewController *)viewController index];
    
    index++;
    
    if (index == [self.pageTitles count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed){
        TutorialContentViewController *currentViewController = [self.pageController.viewControllers objectAtIndex:0];
        currentPageIndex = currentViewController.pageIndex;
        [self updateControllButtons];
    }
}


@end
