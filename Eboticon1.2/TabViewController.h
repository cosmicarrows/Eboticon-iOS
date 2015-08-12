//
//  TabViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabViewController : UITabBarController

    @property (strong, nonatomic) id gifCategory;
    @property (assign, nonatomic) NSNumber *caption;



    - (id)initWithCategory:(id )identifier;
    - (id)initWithCategory:(id )identifier caption:(NSNumber*)caption;
    - (id)initWithCaption:(NSNumber*)caption;

@end
