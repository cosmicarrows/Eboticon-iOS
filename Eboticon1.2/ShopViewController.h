//
//  ShopViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
#import "GlobalScope.h"
#import <ImageSlideshow/ImageSlideshow-Swift.h>

@interface ShopViewController : UIViewController{
    NSTimer *myTimer;
}
@property (strong, nonatomic) IBOutlet ImageSlideshow *imageSlideShow;

@property (retain, nonatomic) IBOutlet UITableView *inAppPurchaseTable;
@property (strong, nonatomic) NSArray *packImages;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
