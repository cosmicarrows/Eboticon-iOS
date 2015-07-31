//
//  KeyboardTutorialViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardTutorialViewController : UIViewController <UIScrollViewDelegate>{
    UIScrollView* scrollView;
    UIPageControl* pageControl;
    
    BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;

- (IBAction)changePage;


@end