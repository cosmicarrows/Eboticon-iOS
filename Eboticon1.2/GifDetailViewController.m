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
#import "EBOActivityTypePostToInstagram.h"
#import "EBOActivityTypePostToFacebook.h"
#import "DDLog.h"
#import "iRate.h"
#import "Constants.h"
#import "SIAlertView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define FIRST_RUN_SWIPE @"firstAppRunSwipe"
#define FIRST_RUN_EMAIL @"firstAppRunEmail"


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
    
    EboticonViewController *eboticonViewController =  [[EboticonViewController alloc] initWithNibName:@"EboticonView" bundle:nil];
    
   // GifDetailViewController *gifDetailViewController =  [[GifDetailViewController alloc] initWithNibName:@"GifDetailView" bundle:nil];
    
    EboticonGif *currGif = self.imageNames[self.index];
    
    eboticonViewController.index = self.index;
    eboticonViewController.eboticonGif = currGif;
    
    _currentDisplayIndex = self.index;

    
    DDLogDebug(@"View Load. Index is %lu",(unsigned long)eboticonViewController.index);
    DDLogDebug(@"View Load. Self Index is %lu",(unsigned long)self.index);
    DDLogDebug(@"View Load. Eboticon Gif is %@",eboticonViewController.eboticonGif.getFileName);
    
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
    
    if(![defaults boolForKey:FIRST_RUN_SWIPE]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Swipe left or right to view more Eboticons!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        [defaults setBool:YES forKey:FIRST_RUN_SWIPE];
    }
}

-(void) showEmailAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[defaults setBool:NO forKey:FIRST_RUN_EMAIL];//Uncomment to test alert
    
    if(![defaults boolForKey:FIRST_RUN_EMAIL]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Make sure to select 'Actual Size' when emailing Eboticons!" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        [defaults setBool:YES forKey:FIRST_RUN_EMAIL];
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
    
    DDLogDebug(@"Share button Current Index:%ld", (long)self.index);
    //EboticonGif *currGif = self.imageNames[self.index];
    EboticonGif *currGif = self.imageNames[self.currentDisplayIndex];
    DDLogDebug(@"Shared Gif is %@",currGif.getFileName);
    
#ifdef FREE
    if([currGif.getDisplayType isEqualToString:@"f"]) {
        [self loadShareView:currGif];
    } else {
        [self loadUpgradeView];
    }
#else
    [self loadShareView:currGif];
#endif
    
}

-(void) loadUpgradeView
{
    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id899011953?mt=8";
    NSString *cancelledResponse = @"cancelled";
    NSString *upgradeResponse = @"upgrade";

    SIAlertView *upgradeView = [[SIAlertView alloc] initWithTitle:@"Thank you!" andMessage:@"Thanks so much for using Eboticon Lite! Upgrade now to access this Eboji!"];
    [upgradeView addButtonWithTitle:@"Maybe Later"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              DDLogDebug(@"Cancel Clicked");
                              [self sendUpgradeButtonClickToGoogleAnalytics:cancelledResponse];
                          }];
    [upgradeView addButtonWithTitle:@"OK"
                               type:SIAlertViewButtonTypeDestructive
                            handler:^(SIAlertView *alert) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                [self sendUpgradeButtonClickToGoogleAnalytics:upgradeResponse];
                            }];
    upgradeView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [upgradeView show];
    
}

-(void) loadShareView: (EboticonGif*)currGif
{
    //Save gifs to recents
    [self saveRecentGif:currGif];
    
    //Send gif share to Google Analytics
    //[self sendShareToGoogleAnalytics:[currGif getFileName]];
    
    [self showEmailAlert];
    
    NSURL *gifFileURL = [self fileToURL:[currGif getFileName]];
    
    NSArray *objectsToShare = @[gifFileURL];
    
    NSArray *applicationActivities = @[[[EBOActivityTypePostToFacebook alloc] init],[[EBOActivityTypePostToInstagram alloc] init]]; //uncomment to add in facebook instagram capability
    //NSArray *applicationActivities = [[NSArray alloc] init]; //uncomment to add normal activities
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:applicationActivities];
    
    NSArray *excludedActivities = @[ UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr];
    controller.excludedActivityTypes = excludedActivities;
    
    
    //[self presentViewController:controller animated:YES completion: ^{[self logShareEvent];}];
    [self presentViewController:controller animated:YES completion: nil];
    [controller setCompletionWithItemsHandler:
     ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
         DDLogInfo(@"%@: Logging Successful share completion: Activity type is: %@", NSStringFromClass(self.class), activityType);
         [self sendShareToGoogleAnalytics:[currGif getFileName] withShareMethod:activityType];
         [[iRate sharedInstance] logEvent:TRUE];
         [self promptForRating];
     }];
}

-(void) promptForRating
{
    //DDLogInfo(@"%@: Number of events until iRate launch %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].eventCount);
    //DDLogInfo(@"%@: Prompt for rating criteria met: %lu", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].shouldPromptForRating);
    if ([iRate sharedInstance].shouldPromptForRating) {
        DDLogDebug(@"%@: Prompt for rating criteria met. Launching iRate", NSStringFromClass(self.class));
        [[iRate sharedInstance] promptIfNetworkAvailable];
    } else {
        DDLogDebug(@"%@: Prompt for rating criteria NOT met. Currently at %lu. %lu more needed", NSStringFromClass(self.class), (unsigned long)[iRate sharedInstance].eventCount, (unsigned long)[iRate sharedInstance].eventsUntilPrompt);
    }
}

-(void) sendShareToGoogleAnalytics:(NSString*) gifName withShareMethod:(NSString*)shareMethod
{
    @try {
        DDLogInfo(@"%@: Attempting to send share analytics to google", NSStringFromClass(self.class));
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        if ([gifName length]!=0) {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Share"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:gifName         // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            DDLogWarn(@"%@: gifName is null or empty.  Unable to send analytics", NSStringFromClass(self.class));
        }
        
        if ([shareMethod length] != 0) {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Share Method"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:shareMethod         // Event label
                                                                   value:nil] build]];    // Event value
        } else {
            DDLogWarn(@"%@: sharedMethod is null or empty.  Unable to send analytics", NSStringFromClass(self.class));
        }
        
    }
    @catch (NSException *exception) {
        DDLogError(@"%@:[ERROR] in Automatic screen tracking: %@", NSStringFromClass(self.class), exception.description);
    }
}

-(void) sendUpgradeButtonClickToGoogleAnalytics:(NSString*) upgradeResponse
{
    @try {
        DDLogInfo(@"%@: Attempting to send share analytics to google", NSStringFromClass(self.class));
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Upgrade"     // Event category (required)
                                                              action:@"AttemptedShare"  // Event action (required)
                                                               label:upgradeResponse         // Event label
                                                               value:nil] build]];    // Event value
    }
    @catch (NSException *exception) {
        DDLogError(@"%@:[ERROR] in Automatic screen tracking: %@", NSStringFromClass(self.class), exception.description);
    }
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
    
    DDLogDebug(@"Recent Gifs Array: %@",recentGifs);
    
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
    NSUInteger index = ((EboticonViewController*) viewController).index;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index >= self.imageNames.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{ 
    NSUInteger index = ((EboticonViewController*) viewController).index;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

-(void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed) {
        return;
    }
    //NSUInteger currentIndex = [[self.pageViewController.viewControllers lastObject] index];
    self.currentDisplayIndex = [[self.pageViewController.viewControllers lastObject] index];
    DDLogDebug(@"didFinishAnimating(), Current index: %lu", (unsigned long)self.currentDisplayIndex);
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((index == NSNotFound) || (index >= self.imageNames.count)) {
        return nil;
    }
    
    self.index = index;
    EboticonViewController *eboticonViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EboticonViewController"];
    eboticonViewController.index = index;
    eboticonViewController.eboticonGif = self.imageNames[index];
    
    DDLogDebug(@"ViewControllerAtIndex(), Current Gif: %@",eboticonViewController.eboticonGif.fileName);
    
    return eboticonViewController;
}

@end
