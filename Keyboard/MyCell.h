//
//  MyCellCollectionViewCell.h
//  motivationalKeyboard
//
//  Created by Troy Nunnally on 5/10/15.
//  Copyright (c) 2015 Brain Rain Solutions. All rights reserved.
//

//#import "FLAnimatedImage.h"
#import "OLImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImage+GIF.h>


#import <UIKit/UIKit.h>

@interface MyCell : UICollectionViewCell

//@property (weak, nonatomic) IBOutlet OLImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
