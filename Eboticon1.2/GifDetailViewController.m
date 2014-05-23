//
//  GifDetailViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/13/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "GifDetailViewController.h"
#import "EboticonGif.h"
#import "EboticonViewController.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define MAX_RECENT_GIFS 10
#define FIRST_RUN @"firstAppRun"


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
    
    EboticonGif *currGif = self.imageNames[self.index];
    
    eboticonViewController.index = self.index;
    //eboticonViewController.imageName = self.imageNames[self.index];
    eboticonViewController.eboticonGif = currGif;
    //eboticonViewController.imageName = [currGif getDisplayName];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x7e00c0)];
    
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
        //fixbar.backgroundColor = UIColorFromRGB(0xFf6c00); //Eboticon Orange
        fixbar.backgroundColor = UIColorFromRGB(0x7e00c0); //Eboticon Purple
        //fixbar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:fixbar];
    }
    
    [self showSwipeAlert];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"embedPageViewController"]){
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
    }
}

-(void) showSwipeAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[defaults setBool:NO forKey:FIRST_RUN];//Uncomment to test alert
    
    if(![defaults boolForKey:FIRST_RUN]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Swipe left or right to view more Eboticons!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        [defaults setBool:YES forKey:FIRST_RUN];
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
    
    EboticonGif *currGif = self.imageNames[self.index];
   
    //Save gifs to recents
    [self saveRecentGif:currGif];
    
    //Send gif share to Google Analytics
    [self sendShareToGoogleAnalytics:[currGif getFileName]];
    
    NSURL *url = [self fileToURL:[currGif getFileName]];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[ UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr];
    controller.excludedActivityTypes = excludedActivities;
    
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void) sendShareToGoogleAnalytics:(NSString*) gifName
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Share"     // Event category (required)
                                                         action:@"button_press"  // Event action (required)
                                                          label:gifName         // Event label
                                                          value:nil] build]];    // Event value
}

/**
 *  Saves current gif to RECENT_GIFS_KEY
 *
 *  @param currGif Gif to save
 */
-(void) saveRecentGif:(EboticonGif*) currGif
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *recentGifs = [[defaults objectForKey:RECENT_GIFS_KEY] mutableCopy];
    
    if(!recentGifs){
        recentGifs = [@[[currGif fileName]] mutableCopy];
    } else if ([recentGifs count] >= MAX_RECENT_GIFS) {
        NSLog(@"Max Recent Gifs Met");
        [recentGifs removeLastObject];
        [recentGifs insertObject:[currGif fileName] atIndex:0];
        
    } else if (![recentGifs containsObject:[currGif fileName]]){
        [recentGifs insertObject:[currGif fileName] atIndex:0];
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
    eboticonViewController.eboticonGif = self.imageNames[previousViewController.index+1];

    return eboticonViewController;
}

-(UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    EboticonViewController *previousViewController = (EboticonViewController *)viewController;
    
    if(previousViewController.index ==0) {
        return nil;
    }
    
    EboticonViewController *eboticonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EboticonViewController"];
    
    eboticonViewController.index = previousViewController.index - 1;
    eboticonViewController.eboticonGif = self.imageNames[previousViewController.index-1];
    
    return eboticonViewController;
    
}

@end
