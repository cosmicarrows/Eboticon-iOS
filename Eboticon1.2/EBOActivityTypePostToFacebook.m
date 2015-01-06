//
//  EBOActivityTypePostToFacebook.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 7/26/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EBOActivityTypePostToFacebook.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DDLog.h"
#import "SIAlertView.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

@interface EBOActivityTypePostToFacebook()

@property (nonatomic, copy) NSArray *movItems;

@end

@implementation EBOActivityTypePostToFacebook

- (NSString *)activityType {
    // Unique string that identifies this activity to the OS
    return @"com.Eboticon.EBOActivityTypePostToFacebook";
}

- (NSString *)activityTitle {
    // The label that appears under the activity icon in the "share sheet"
    return @"Facebook";
}

- (UIImage *)activityImage {
    
    return [UIImage imageNamed:@"Icon_Facebook"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    // Given an array of NSObjects, returns YES if at least one of them can be handled by this activity
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *filePath = (NSURL *)obj;
            NSString *gifName = [filePath lastPathComponent];
            return [self isGifString:gifName];
        }
    }
    return NO;
    
}


- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Iterate through the activity items, filtering out the MKMapItem objects
    NSMutableArray *movItems = [NSMutableArray array];
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *filePath = (NSURL *)obj;
            NSString *gifName = [filePath lastPathComponent];
            if([self isGifString:gifName]){
                gifName = [[gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)] stringByAppendingString:@".mov"];
            }
            [movItems addObject:gifName];
        }
    }
    self.movItems = movItems;
}

- (void)performActivity {
    
    NSString * gifName = [self.movItems objectAtIndex:0];
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    //NSData *movData = [NSData dataWithContentsOfFile:filepath];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(filepath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    } else {
        DDLogError(@"Video is not Compatible");
    }
    
    [self activityDidFinish:YES];
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Eboticon Saving Failed"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else {
        SIAlertView *successAlertView = [[SIAlertView alloc] initWithTitle:@"Facebook Video" andMessage:@"This Eboticon has been saved to your camera roll.  You will need to load it from your camera roll inside Facebook. Make sure to hashtag #eboticons!"];
        [successAlertView addButtonWithTitle:@"OK"
                                        type:SIAlertViewButtonTypeDestructive
                                     handler:^(SIAlertView *alert) {
                                         [self openFacebook];
                                     }];
        successAlertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [successAlertView show];
        
    }
}

-(BOOL)isGifString:(NSString *)gifFileName {
    if([gifFileName length] >= 4 && [[gifFileName substringFromIndex: [gifFileName length] - 4] isEqualToString:@".gif"]) {
        return YES;
    }
    return NO;
}

-(void)openFacebook
{
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1416004045306313"];
    NSURL *facebookWebURL = [NSURL URLWithString:@"fb://profile/1416004045306313"];


    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        DDLogDebug(@"Facebook not installed on device");
        SIAlertView *fbNotInstalledAlert = [[SIAlertView alloc] initWithTitle:@"Facebook Error" andMessage:@"Facebook is not installed on your device.  We'll open facebook via your web browser."];
        [fbNotInstalledAlert addButtonWithTitle:@"OK"
                                           type:SIAlertViewButtonTypeDestructive
                                        handler:^(SIAlertView *alert) {
                                            if ([[UIApplication sharedApplication] canOpenURL:facebookWebURL]) {
                                                [[UIApplication sharedApplication] openURL:facebookWebURL];
                                            } else {
                                                DDLogError(@"Cannot open FB in browser");
                                            };
                                        }];
        fbNotInstalledAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
        [fbNotInstalledAlert show];
    }
    
}



@end
