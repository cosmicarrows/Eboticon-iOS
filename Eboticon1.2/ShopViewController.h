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

@interface ShopViewController : UIViewController{
    NSTimer *myTimer;
}

@property (retain, nonatomic) IBOutlet UITableView *inAppPurchaseTable;
@property (strong, nonatomic) NSString *deeplinkProductIdentifier;
@property (strong, nonatomic) NSArray *packImages;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
