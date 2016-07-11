//
//  EboticonGifCell.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/10/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonGifCell.h"
#import "GPUImage.h"
#import <DFImageManager/DFImageManagerKit.h>
#import "ImageDownloader.h"
#import "ImageCache.h"
#import "Reachability.h"



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
        UIImage *image = [[UIImage alloc]init];
        if ([[ImageCache sharedImageCache] DoesExist:eboticonGif.stillUrl] == true) {
            image = [[ImageCache sharedImageCache] GetImage:eboticonGif.stillUrl];
#ifdef FREE
            //If eboji is free(f), display normally. Else, grayscale
            if ([eboticonGif.getDisplayType isEqualToString: @"f"]) {
                _gifImageView.image = image;
            } else {
                GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
                _gifImageView.image = [grayscaleFilter imageByFilteringImage:image];
            }
#else
            _gifImageView.image = image;
#endif
        }else {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.hidesWhenStopped = YES;
            activityIndicator.hidden = NO;
            [activityIndicator startAnimating];
            activityIndicator.center = self.contentView.center;
            activityIndicator.tag = 505;
            [self.contentView addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            if ([self checkConnnectivity]) {
                ImageDownloader *imgDownloader = [[ImageDownloader alloc] init];
                imgDownloader.imageRecord = eboticonGif;
                [imgDownloader setCompletionHandler:^{
                    
#ifdef FREE
                    //If eboji is free(f), display normally. Else, grayscale
                    if ([eboticonGif.getDisplayType isEqualToString: @"f"]) {
                        _gifImageView.image = eboticonGif.thumbImage;
                    } else {
                        GPUImageGrayscaleFilter *grayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
                        _gifImageView.image = [grayscaleFilter imageByFilteringImage:eboticonGif.thumbImage];
                    }
#else
                    _gifImageView.image = eboticonGif.thumbImage;
#endif
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                }];
                [imgDownloader startDownload];
                
            }else {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                _gifImageView.image = [UIImage imageNamed:@"placeholder.png"];
            }
            
            
        }
    }
}

- (BOOL) checkConnnectivity {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
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
