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

    - (id)initWithCategory:(id )identifier;

@end
