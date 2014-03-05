//
//  GifCell.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/27/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "OLImageView.h"

@interface GifCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet OLImageView *gifImageView;

//-(void) animateGif;

-(void) setCellGif:(NSData *) gifData;
-(void) setCellImage:(NSString *) gifName;
-(BOOL)isCellAnimating;

@end
