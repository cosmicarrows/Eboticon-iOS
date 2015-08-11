//
//  UIKit.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 8/11/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *packImage;
@property (strong, nonatomic) IBOutlet UILabel *packTitle;
@property (strong, nonatomic) IBOutlet UILabel *packCost;


@end
