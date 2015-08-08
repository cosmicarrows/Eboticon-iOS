//
//  EboticonViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/13/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonViewController.h"
#import "OLImageView.h"
#import "OLImage.h"
#import "GPUImage.h"
#import "DDLog.h"
#import "Constants.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EboticonViewController ()

@property (strong, nonatomic) IBOutlet OLImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *imageLabel;

@end

@implementation EboticonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"EboticonViewController viewDidLoad");
    
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"MasterBackground2.0.png"].CGImage;     //Add Background without repeating
    
	// Do any additional setup after loading the view.
    
    //self.imageView.image = [OLImage imageNamed:self.eboticonGif.getFileName];
    
#ifdef FREE
    if([self.eboticonGif.getDisplayType isEqualToString:@"f"]) {
        self.imageView.image = [OLImage imageNamed:self.eboticonGif.getFileName];
    } else {
        self.imageView.image = [OLImage imageNamed:self.eboticonGif.getFileName];
                
        DDLogDebug(@"ImageView position x:%f y:%f", self.imageView.frame.origin.x, self.imageView.frame.origin.x);
        DDLogDebug(@"ImageView height: %f, width: %f", self.imageView.image.size.height, self.imageView.image.size.width);
        CGRect overlayFrame = self.imageView.frame;
        UIView *overlayView = [[UIView alloc] initWithFrame:overlayFrame];
        [overlayView setFrame:CGRectMake(0, 0, overlayView.frame.size.width, overlayView.frame.size.height)];
        
        DDLogDebug(@"Overlay position x:%f y:%f", self.imageView.frame.origin.x, self.imageView.frame.origin.x);
        DDLogDebug(@"Overlay height: %f, width: %f", self.imageView.image.size.height, self.imageView.image.size.width);
        
        overlayView.alpha = 0.5f;
        overlayView.backgroundColor = [UIColor blackColor];
        
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
        [self.imageView addSubview:overlayView];       

    }
#else
    self.imageView.image = [OLImage imageNamed:self.eboticonGif.getFileName];
#endif
    
    NSString *titleString = self.eboticonGif.getDisplayName;
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    NSRange titleRange = [titleString rangeOfString:self.eboticonGif.getDisplayName];
    
    //[attributedTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFf6c00) range:titleRange];
    
#ifdef FREE
    if([self.eboticonGif.getDisplayType isEqualToString:@"f"]) {
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFf6c00) range:titleRange];
    } else {
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:titleRange];
    }
#else
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFf6c00) range:titleRange];
#endif
    
    self.imageLabel.attributedText = attributedTitle;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
