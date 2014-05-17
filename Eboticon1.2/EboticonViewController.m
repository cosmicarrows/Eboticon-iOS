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
	// Do any additional setup after loading the view.
    
    self.imageView.image = [OLImage imageNamed:self.eboticonGif.getFileName];
    
    NSString *titleString = self.eboticonGif.getDisplayName;
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    NSRange titleRange = [titleString rangeOfString:self.eboticonGif.getDisplayName];
    
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFf6c00) range:titleRange];
    
    self.imageLabel.attributedText = attributedTitle;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
