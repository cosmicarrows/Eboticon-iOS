//
//  ShopViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"

@interface ShopViewController : UIViewController{
    
}

@property (retain, nonatomic) IBOutlet UITableView *inAppPurchaseTable;

@property (strong, nonatomic) NSArray *packTitles;
@property (strong, nonatomic) NSArray *packImages;
@property (strong, nonatomic) NSArray *packCosts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end