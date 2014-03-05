//
//  MoreViewController.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/8/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "iTellAFriend.h"

@interface MoreViewController : UIViewController<MFMailComposeViewControllerDelegate>
{
    MFMailComposeViewController *mc;
}
@property (strong, nonatomic) IBOutlet UIButton *eboticonLogo;

- (IBAction)eboticonLogo:(id)sender;
- (IBAction)contactUsEmail:(id)sender;
- (IBAction)aboutURL:(id)sender;
- (IBAction)rateEboticon:(id)sender;
- (IBAction)tellAFriend:(id)sender;

@end
