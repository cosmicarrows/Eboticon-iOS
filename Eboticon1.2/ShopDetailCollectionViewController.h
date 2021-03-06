//
//  ShopDetailCollectionViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 8/23/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

//In-app purchases (IAP) libraries
#import "EboticonIAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface ShopDetailCollectionViewController : UICollectionViewController

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *savedSkinTone;
@property (assign) BOOL activateBuy;

@end
