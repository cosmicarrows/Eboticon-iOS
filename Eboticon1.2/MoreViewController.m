//
//  MoreViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/8/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "MoreViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DDLog.h"
#import "WhatsNewMainViewController.h"

//Definitions
#define TWITTER @"twitter"
#define FACEBOOK @"facebook"
#define INSTAGRAM @"instagram"
#define YOUTUBE @"youtube"
#define EBOLOGO @"eboticonLogo"

#define ABOUT @"about_link"
#define FAQS @"faqs_link"
#define CONTACTUS @"contactUs_link"
#define RATE @"rate_link"
#define TELLAFRIEND @"tellFriend_link"


static const int ddLogLevel = LOG_LEVEL_WARN;

@interface MoreViewController ()

@end

@implementation MoreViewController

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
    [_eboticonLogo setImage:[UIImage imageNamed:@"Eboticon_Final.png"] forState:UIControlStateNormal];
    [_facebookLogo setImage:[UIImage imageNamed:@"facebook-social.png"] forState:UIControlStateNormal];
    [_instagramLogo setImage:[UIImage imageNamed:@"instagram-social.png"] forState:UIControlStateNormal];
    [_twitterLogo setImage:[UIImage imageNamed:@"twitter-social.png"] forState:UIControlStateNormal];
    [_youtubeLogo setImage:[UIImage imageNamed:@"youtube-social.png"] forState:UIControlStateNormal];
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"More Screen" forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
    
#ifdef FREE
    UIBarButtonItem *upgradeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upgrade" style: UIBarButtonItemStylePlain target:self action:@selector(upgradeToPaidApp)];
    self.navigationItem.rightBarButtonItem = upgradeButtonItem;
#else
    DDLogInfo(@"Paid Version. Not Showing Upgrade Button");
#endif

}

- (void)upgradeToPaidApp {
    [self sendUpgradeButtonClickToGoogleAnalytics];
    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id899011953?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

-(void) sendUpgradeButtonClickToGoogleAnalytics
{
    @try {
        DDLogInfo(@"%@: Attempting to send share analytics to google", NSStringFromClass(self.class));
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Upgrade"     // Event category (required)
                                                              action:@"More Screen Button"  // Event action (required)
                                                               label:nil         // Event label
                                                               value:nil] build]];    // Event value
    }
    @catch (NSException *exception) {
        DDLogError(@"%@:[ERROR] in Automatic screen tracking: %@", NSStringFromClass(self.class), exception.description);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)eboticonLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eboticon.com"]];
    [self sendAlertToGoogleAnalytics:EBOLOGO];
}

- (IBAction)contactUsEmail:(id)sender {
    
    //Email Subject
    NSString *emailTitle = @"Contact Eboticon";
    
    //Email Content
    NSString *messageBody = @"We want to hear what you think!";
    
    //To Address
    NSArray *toRecipients = [NSArray arrayWithObject:@"contactus@eboticon.com"];
    
    //MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipients];
    
    [self presentViewController:mc animated:YES completion:NULL];
    [self sendAlertToGoogleAnalytics:CONTACTUS];
}

- (IBAction)aboutURL:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eboticon.com"]];
    [self sendAlertToGoogleAnalytics:ABOUT];
}

- (IBAction)faqURL:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eboticon.com/#!faq/cne9"]];
    [self sendAlertToGoogleAnalytics:FAQS];
}

- (IBAction)rateEboticon:(id)sender {
    
     //[[iTellAFriend sharedInstance] rateThisAppWithAlertView:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=899011953&onlyLatestVersion=false&type=Purple+Software"]];
    [self sendAlertToGoogleAnalytics:RATE];

}

- (IBAction)tellAFriend:(id)sender {
    
    if ([[iTellAFriend sharedInstance] canTellAFriend]) {
        UINavigationController* tellAFriendController = [[iTellAFriend sharedInstance] tellAFriendController];
        [self presentViewController:tellAFriendController animated:YES completion:nil];
    }
    [self sendAlertToGoogleAnalytics:RATE];
}


- (IBAction)whatsNew:(id)sender {
    
    NSLog(@"whatsNew");

    WhatsNewMainViewController *whatsNewMainViewController = [[WhatsNewMainViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:whatsNewMainViewController animated:YES];
    
}


- (IBAction)facebookLogo:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1416004045306313"];
    NSURL *facebookWebURL = [NSURL URLWithString:@"http://www.facebook.com/1416004045306313"];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:facebookWebURL];
    }
    
    [self sendAlertToGoogleAnalytics:FACEBOOK];
}

- (IBAction)instagramLogo:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=eboticons"];
    NSURL *instagramkWebURL = [NSURL URLWithString:@"http://www.instagram.com/eboticons"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        [[UIApplication sharedApplication] openURL:instagramkWebURL];
    }
    
    [self sendAlertToGoogleAnalytics:INSTAGRAM];
}

- (IBAction)twitterLogo:(id)sender {
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=eboticons"];
    NSURL *twitterWebURL = [NSURL URLWithString:@"http://www.twitter.com/eboticons"];
    
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        [[UIApplication sharedApplication] openURL:twitterWebURL];
    }
    
    [self sendAlertToGoogleAnalytics:TWITTER];
}

- (IBAction)youtubeLogo:(id)sender {
    NSURL *youtubeURL = [NSURL URLWithString:@"youtube://www.youtube.com/user/eboticon"];
    NSURL *youtubeWebURL = [NSURL URLWithString:@"http://www.youtube.com/user/eboticon"];
    
    if ([[UIApplication sharedApplication] canOpenURL:youtubeURL]) {
        [[UIApplication sharedApplication] openURL:youtubeURL];
    } else {
        [[UIApplication sharedApplication] openURL:youtubeWebURL];
    }
    
    [self sendAlertToGoogleAnalytics:YOUTUBE];
}

-(void) sendAlertToGoogleAnalytics:(NSString*) eventLabel
{
    NSString *actionType =  @"non_social";
    if (!eventLabel.length) {
        DDLogError(@"socialMediaType null! Not sending analytics!");
        return;
    } else if ([eventLabel isEqualToString:FACEBOOK]||[eventLabel isEqualToString:INSTAGRAM]||[eventLabel isEqualToString:TWITTER]||[eventLabel isEqualToString:YOUTUBE]) {
        actionType = @"social";
    }
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"More Screen Event"     // Event category (required)
                                                          action:actionType  // Event action (required)
                                                           label:eventLabel         // Event label
                                                           value:nil] build]];    // Event value
}

#pragma mark - mail compose delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //#warning TODO: input alert messages
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
