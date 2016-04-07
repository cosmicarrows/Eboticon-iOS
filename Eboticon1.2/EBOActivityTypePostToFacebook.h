//
//  EBOActivityTypePostToFacebook.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 7/26/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


SLComposeViewController *mySLComposerSheet;


@interface EBOActivityTypePostToFacebook : UIActivity

- (id)initWithAttributes:(NSString *)movName;

@end
