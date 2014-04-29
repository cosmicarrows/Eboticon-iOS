//
//  EboticonGifCell.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/10/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EboticonGif.h"
#import "OLImageView.h"

@interface EboticonGifCell : UICollectionViewCell

@property (strong, nonatomic) EboticonGif *cellGif;
@property (strong, nonatomic) IBOutlet OLImageView *gifImageView;
#warning TODO: input alert messages


-(void) setCellGif:(EboticonGif *) eboticonGif;
-(BOOL) isCellAnimating;

@end
