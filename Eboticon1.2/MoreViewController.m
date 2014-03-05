//
//  MoreViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/8/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "MoreViewController.h"

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

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)eboticonLogo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eboticon.com"]];
    
}

- (IBAction)contactUsEmail:(id)sender {
    
    //Email Subject
    NSString *emailTitle = @"Contact Eboticon";
    
    //Email Content
    NSString *messageBody = @"We want to hear what you think!";
    
    //To Address
    NSArray *toRecipients = [NSArray arrayWithObject:@"contactus@inclingconsulting.com"];
    
    //MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipients];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (IBAction)aboutURL:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.eboticon.com"]];
}

- (IBAction)rateEboticon:(id)sender {
    
     [[iTellAFriend sharedInstance] rateThisAppWithAlertView:YES];
}

- (IBAction)tellAFriend:(id)sender {
    
    if ([[iTellAFriend sharedInstance] canTellAFriend]) {
        UINavigationController* tellAFriendController = [[iTellAFriend sharedInstance] tellAFriendController];
        [self presentViewController:tellAFriendController animated:YES completion:nil];
    }
}

#pragma mark - mail compose delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    #warning TODO: input alert messages
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
