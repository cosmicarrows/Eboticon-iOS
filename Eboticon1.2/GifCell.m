//
//  GifCell.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/27/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import "GifCell.h"
#import "OLImage.h"

@implementation GifCell

@synthesize gifImageView = _gifImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/**
-(void) animateGif
{
    if(_gifImage.isAnimating){
        NSLog(@"Already Animating");
        return;
    } else {
        [_gifImage startAnimating];
        NSLog(@"Is animating: %d", _gifImage.isAnimating);
    }
}
 **/

-(void) setCellGif:(NSData *) gifData
{
    //_gifImageView.image = [OLImage imageWithData:gifData];
    _gifImageView.image = [UIImage imageWithData:gifData];

    NSLog(@"setCellGif. Is animating: %d",[self isCellAnimating]);
}

-(void) setCellImage:(NSString *)gifName
{
    _gifImageView = [[OLImageView alloc] initWithImage:[OLImage imageNamed:gifName]];
    NSLog(@"setGifImageView. Is animating: %d",[self isCellAnimating]);

}

-(void)setGifImageView:(OLImageView *)gifImageViewInput
{
    _gifImageView = gifImageViewInput;
}

-(BOOL)isCellAnimating
{
    return _gifImageView.isAnimating;
}

@end
