//
//  GifDetailViewController.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/13/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"


@interface GifDetailViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSMutableArray *imageNames;
@property (assign, nonatomic) NSInteger currentDisplayIndex;
@property (weak, nonatomic) IBOutlet UIImageView *imvBlurredBackground;
@property (strong, nonatomic) UIImage *imgBackground;

@property (strong, nonatomic) id gifCategory;

@end
