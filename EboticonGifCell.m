//
//  EboticonGifCell.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/10/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonGifCell.h"
#import "GPUImage.h"


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
        
        NSString *gifName = [_cellGif getStillName];
        
        gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
        NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"png"];
        NSData *GIFDATA = [NSData dataWithContentsOfFile:filepath];
#ifdef FREE
        //If eboji is free(f), display normally. Else, grayscale
        if ([eboticonGif.getDisplayType isEqualToString: @"f"]) {
            _gifImageView.image = [UIImage imageWithData:GIFDATA];
        } else {
            GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
            _gifImageView.image = [grayscaleFilter imageByFilteringImage:[UIImage imageWithData:GIFDATA]];
        }
#else
        _gifImageView.image = [UIImage imageWithData:GIFDATA];
#endif
        
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
