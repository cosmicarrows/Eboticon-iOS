//
//  EboticonGifCell.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/10/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonGifCell.h"

@implementation EboticonGifCell

@synthesize cellGif = _cellGif;
@synthesize gifImageView = _gifImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setCellGif:(EboticonGif *) eboticonGif
{
    if (nil != eboticonGif){
        _cellGif = eboticonGif;
        
        //NSString *gifName = [_cellGif getFileName];
        NSString *gifName = [_cellGif getStillName];
        
        gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
        NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
        NSData *GIFDATA = [NSData dataWithContentsOfFile:filepath];
        _gifImageView.image = [UIImage imageWithData:GIFDATA];
        
    }
}

-(BOOL)isCellAnimating
{
    return _gifImageView.isAnimating;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
