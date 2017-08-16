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

#import "Eboticon-Swift.h"

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
    
    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openPostFacebook:)
                                                 name:@"postToFacebook" object:nil];
    
    
    NSLog(@"GifDetailViewController viewDidLoad");
    // Do any additional setup after loading the view.
    _currentDisplayIndex = self.index;
    
    //Add Share Button
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    //Create The View that shows the Eboticon Content
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    EboticonViewController *initialViewController = [self viewControllerAtIndex:self.index];
    EboticonGif *currGif = self.imageNames[self.index];
    initialViewController.index = self.index;
    initialViewController.eboticonGif = currGif;
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    NSLog(@"View Load. Index is %lu",(unsigned long)initialViewController.index);
    NSLog(@"View Load. Self Index is %lu",(unsigned long)self.index);
    NSLog(@"View Load. Eboticon Gif is %@",initialViewController.eboticonGif.getFileName);
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //If ioS, set navigationBar
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y, self.navigationBar.frame.size.width, 64);
    }
    
    //Adds extra color block on top of view to fix overlap
    /*
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
     UIView *fixbar = [[UIView alloc] init];
     fixbar.frame = CGRectMake(0, 0, 320, 20);
     //fixbar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; // the default color of iOS7 bacground or any color suits your design
     //fixbar.backgroundColor = UIColorFromRGB(0xFf6c00); //Eboticon Orange
     fixbar.backgroundColor = UIColorFromRGB(0x7e00c0); //Eboticon Purple
     //fixbar.backgroundColor = [UIColor whiteColor];
     [self.view addSubview:fixbar];
     }
     */
    
    
    // Create page view controller
    // Change the size of page view controller
    //[[self.pageViewController view] setFrame:[[self view] bounds]];
    NSLog(@"width: %f",self.view.frame.size.width);
    NSLog(@"%f",self.view.frame.size.width);
    
    [self.imvBlurredBackground setImage:self.imgBackground];
    
    [self addBlurEffect];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44);
    
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:[self.pageViewController view]];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reverseMenu:)]];
    
    //[self showSwipeAlert];
}

- (void)addBlurEffect{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.frame;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView];
    }
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)reverseMenu:(UITapGestureRecognizer *)sender{
    [self.revealViewController rightRevealToggleForTapGesture];
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
    if ([self.revealViewController wasAnimated]){
        [self reverseMenu:nil];
        return;
    }
    
    NSLog(@"Share button Current Index:%ld", (long)self.index);
    //EboticonGif *currGif = self.imageNames[self.index];
    EboticonGif *currGif = self.imageNames[self.currentDisplayIndex];
    NSLog(@"Shared Gif is %@",currGif.getFileName);
    //Send to Firebase
    
    [[FirebaseConfigurator sharedInstance] logEvent:currGif.getFileName];
    
    [self loadShareView:currGif];
    
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

- (NSString *) createLocalFilename: (NSString *)filename
{
    //Creates a list of path strings for the specified directories in the specified domains. The list is in the order in which you should search the directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    //NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", movName]];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
    
    NSLog(@"createLocalFilename: %@", file);
    
    return file;
}


- (void)createPathForMovName:(NSString *)movName fileName:(NSString *)fileName completion:(CompletionHandler)finishBlock {
    
    NSString *filePath = [self createLocalFilename:fileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        
        NSLog(@"file path exists: %@", filePath);
        finishBlock(filePath, nil);
        
        
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            NSLog(@"mov url: %@", movName);

            NSURL  *url = [NSURL URLWithString:movName];
            
            NSError *downloadError = nil;
            // Create an NSData object from the contents of the given URL.
            NSData *urlData = [NSData dataWithContentsOfURL:url
                                                    options:kNilOptions
                                                      error:&downloadError];
            if (downloadError) {
                finishBlock(nil, downloadError);
            }
            
            if ( urlData )
            {
                
        
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    NSLog(@"File Saved ! %@", filePath);
                    finishBlock(filePath, nil);
                });
            }
            
        });
    }
    
}

-(void) loadShareView: (EboticonGif*)currGif
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;
    //activityIndicator.color = [UIColor blueColor];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    //Save gifs to recents
    [self saveRecentGif:currGif];
    
    //Send gif share to Google Analytics
    //[self sendShareToGoogleAnalytics:[currGif getFileName]];
    [self showEmailAlert];
    
    NSString *movName = [currGif movUrl];
    NSLog(@"loadShareView for %@", movName);
    NSString *filename = [NSString stringWithFormat:@"%@.mov",[currGif fileName]];
    
    
    // NSURL *gifFileURL = [self fileToURL:[currGif getFileName]];
    // NSString *textObject = @"Check this out #eboticon";
    // NSString *gifUrlName = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/%@", [currGif getFileName]];
    
    [self createPathForMovName:movName fileName:filename completion:^(NSString *filepath, NSError *error) {
        if (error != nil) {
            NSLog(@"error creating path for mov: %@", error);
            //           dispatch_async(dispatch_get_main_queue(), ^{
            //               [activityIndicator stopAnimating];
            //               [activityIndicator removeFromSuperview];
            //               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            //               UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            //               [alertController addAction:cancel];
            //               [self presentViewController:alertController animated:YES completion:nil];
            //               return;
            //           });
        }
        
        
        NSString *gifUrl = [currGif gifUrl];
        NSLog(@"movname %@", movName);
        NSLog(@"get file gif: %@", [currGif gifUrl]);
        NSLog(@"gifname %@", gifUrl);
        NSLog(@"get file name: %@", [currGif fileName]);
        NSLog(@"stored file path: %@", filepath);

        //UIImage *gifFilename = [UIImage imageNamed:[currGif getFileName]];
        //Form the URI by adding it to your host:
        //And put it on the .string property of the generalPasteboard:
        [UIPasteboard generalPasteboard].string = gifUrl;
        
        
        NSURL *imagePath = [NSURL URLWithString:gifUrl];
        
        NSData *animatedGif = [NSData dataWithContentsOfURL:imagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSURL *gifFileURL    =  [NSURL URLWithString:gifUrlName];
            // UIImage *gifFileImage    =  [UIImage imageNamed:[currGif getFileName]];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            NSLog(@"%@",gifUrl);
            
            
            // NSArray *objectsToShare = [NSArray arrayWithObjects: animatedGif, textObject, imagePath, nil];
            
            NSArray *objectsToShare = @[animatedGif];
            
            // NSArray *applicationActivities = @[[[EBOActivityTypePostToFacebook alloc] initWithAttributes:movName],[[EBOActivityTypePostToInstagram alloc] initWithAttributes:movName]]; //uncomment to add in facebook instagram capability
            
            NSArray *applicationActivities = @[[[EBOActivityTypePostToFacebook alloc] initWithAttributes:filepath],[[EBOActivityTypePostToInstagram alloc] initWithAttributes:filepath]]; //uncomment to add in facebook instagram capability
            
            //NSArray *applicationActivities = [[NSArray alloc] init]; //uncomment to add normal activities
            
            NSLog(@"activities %@", applicationActivities);
            
            //UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:applicationActivities];
            
            
            //UIActivityTypePostToFacebook
            NSArray *excludedActivities = @[ UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, UIActivityTypePostToFacebook];
            
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
        });
    }];
    
    
}


-(void)openPostFacebook:(NSNotification *)notification {
    
    
    NSDictionary* userInfo = notification.userInfo;
    NSString* filepath = (NSString*)userInfo[@"filepath"];
    NSLog (@"Successfully received test notification! %@", filepath);
    
    
    NSLog(@"test");
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPost = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        // [fbPost setInitialText:@"Text You want to Share"];
        // [fbPost addImage:[UIImage imageNamed:@"Icon_Facebook.png"]];
        
        [self presentViewController:fbPost animated:YES completion:nil];
        
        [fbPost setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
    }
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
    
    NSLog(@"%@",filePath);
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
    NSLog(@"didFinishAnimating(), Current index: %lu", (unsigned long)self.currentDisplayIndex);
}

- (EboticonViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    NSLog(@"viewControllerAtIndex: %lu", (unsigned long)index);
    
    if ((index == NSNotFound) || (index >= self.imageNames.count)) {
        return nil;
    }
    
    self.index = index;
    
    // Create a new view controller and pass suitable data.
    EboticonViewController *pageContentViewController = [[EboticonViewController alloc] initWithNibName:@"EboticonView" bundle:nil];
    
    pageContentViewController.eboticonGif = self.imageNames[index];
    pageContentViewController.index = index;
    
    NSLog(@"ViewControllerAtIndex(), Current Gif: %@",pageContentViewController.eboticonGif.fileName);
    
    return pageContentViewController;
}

@end
