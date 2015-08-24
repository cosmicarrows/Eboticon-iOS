//
//  MyCell.h
//  TestCollectionViewWithXIB
//
//  Created by Quy Sang Le on 2/3/13.
//  Copyright (c) 2013 Quy Sang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EboticonGif.h"
#import "OLImageView.h"
#import "FLAnimatedImage.h"

@interface ShopDetailCell : UICollectionViewCell
@property (strong, nonatomic) EboticonGif *cellGif;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *gifImageView;
//TODO: input alert messages


-(void) setCellGif:(EboticonGif *) eboticonGif;
-(BOOL) isCellAnimating;

@end
