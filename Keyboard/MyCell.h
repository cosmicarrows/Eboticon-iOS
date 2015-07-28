//
//  MyCellCollectionViewCell.h
//  motivationalKeyboard
//
//  Created by Troy Nunnally on 5/10/15.
//  Copyright (c) 2015 Brain Rain Solutions. All rights reserved.
//


#import <DFImageManager/DFImageManagerKit.h>
#import <UIKit/UIKit.h>

@interface MyCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet DFImageView *imageView;
//@property (weak, nonatomic) IBOutlet UIImage *imageView;

@end
