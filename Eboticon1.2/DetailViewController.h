//
//  DetailViewController.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/23/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
