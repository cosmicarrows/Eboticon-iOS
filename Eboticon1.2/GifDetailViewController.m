//
//  GifDetailViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/13/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "GifDetailViewController.h"
#import "EboticonViewController.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define MAX_RECENT_GIFS 10

@interface GifDetailViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation GifDetailViewController

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
    
    EboticonViewController *eboticonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EboticonViewController"];
    
    eboticonViewController.index = self.index;
    eboticonViewController.imageName = self.imageNames[self.index];
    
    [self.pageViewController setViewControllers:@[eboticonViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    
    float currentVersion = 7.0;
    /**
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y, self.navigationBar.frame.size.width, 64);
    }
     **/
    
    
    //Adds extra color block on top of view to fix overlap
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        UIView *fixbar = [[UIView alloc] init];
        fixbar.frame = CGRectMake(0, 0, 320, 20);
        //fixbar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; // the default color of iOS7 bacground or any color suits your design
        fixbar.backgroundColor = UIColorFromRGB(0xFf6c00);
        [self.view addSubview:fixbar];
    }    
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"embedPageViewController"]){
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([self.actionSheet isVisible]) {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
    }
}

- (IBAction)shareButtonTapped:(id)sender {
    
    NSString *gifName = self.imageNames[self.index];
   
    //Save gifs to recents
    [self saveRecentGif:gifName];
    
    NSURL *url = [self fileToURL:gifName];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[ UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void) saveRecentGif:(NSString*) gifName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *recentGifs = [[defaults objectForKey:RECENT_GIFS_KEY] mutableCopy];
    
    if(!recentGifs){
        recentGifs = [@[gifName] mutableCopy];
    } else if ([recentGifs count] >= MAX_RECENT_GIFS) {
        NSLog(@"Max Recent Gifs Met");
        [recentGifs removeLastObject];
        [recentGifs insertObject:gifName atIndex:0];
        
    } else {
        [recentGifs insertObject:gifName atIndex:0];
    }

    [defaults setObject:recentGifs forKey:RECENT_GIFS_KEY];
    [defaults synchronize];
    
    NSLog(@"Recent Gifs Array: %@",recentGifs);
    
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - UIPageViewControllerDataSource / Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    EboticonViewController *previousViewController = (EboticonViewController *)viewController;
    
    if(previousViewController.index >= self.imageNames.count - 1) {
        return nil;
    }
    
    EboticonViewController *eboticonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EboticonViewController"];
    
    eboticonViewController.index = previousViewController.index + 1;
    eboticonViewController.imageName = self.imageNames[previousViewController.index+1];
    
    return eboticonViewController;
}

-(UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    EboticonViewController *previousViewController = (EboticonViewController *)viewController;
    
    if(previousViewController.index ==0) {
        return nil;
    }
    
    EboticonViewController *eboticonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EboticonViewController"];
    
    eboticonViewController.index = previousViewController.index + 1;
    eboticonViewController.imageName = self.imageNames[previousViewController.index+1];
    
    return eboticonViewController;
    
}

@end
