//
//  EBOActivityTypePostToInstagram.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 8/26/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EBOActivityTypePostToInstagram.h"
#import "SIAlertView.h"
#import "DDLog.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

@interface EBOActivityTypePostToInstagram()

@property (nonatomic, copy) NSArray *movItems;

@end

@implementation EBOActivityTypePostToInstagram

- (NSString *)activityType {
    // Unique string that identifies this activity to the OS
    return @"com.Eboticon.EBOActivityTypePostToInstagram";
}

- (NSString *)activityTitle {
    // The label that appears under the activity icon in the "share sheet"
    return @"Instagram";
}

- (UIImage *)activityImage {

    return [UIImage imageNamed:@"Icon_Instagram"];
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
        DDLogError(@"Video is Not Compatible");
    }
    
    [self activityDidFinish:YES];
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Eboticon Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else {
        SIAlertView *successAlertView = [[SIAlertView alloc] initWithTitle:@"Instagram Video" andMessage:@"This Eboticon has been saved to your camera roll.  You will need to load it from your camera roll inside Instagram. Make sure to hashtag #eboticons!"];
        [successAlertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  [self openInstagram];
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

-(void)openInstagram {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [self sendShareToGoogleAnalytics:@"nativeApp"];
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        DDLogDebug(@"Instagram not installed on device");
        [self sendShareToGoogleAnalytics:@"viaWeb"];
        SIAlertView *igNotInstalledAlert = [[SIAlertView alloc] initWithTitle:@"Instagram Error" andMessage:@"Instagram is not installed on your device.  Please install Instagram and try again."];
        [igNotInstalledAlert addButtonWithTitle:@"OK"
                                        type:SIAlertViewButtonTypeDestructive
                                     handler:^(SIAlertView *alert) {
                                         [self openInstagram];
                                     }];
        igNotInstalledAlert.transitionStyle = SIAlertViewTransitionStyleBounce;
        [igNotInstalledAlert show];
    }
}

-(void) sendShareToGoogleAnalytics:(NSString*) redirectType
{
    if (!redirectType.length) {
        DDLogError(@"redirectType null or empty! Not sending analytics!");
        return;
    }
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Social Media Share"     // Event category (required)
                                                          action:@"instagram"  // Event action (required)
                                                           label:redirectType         // Event label
                                                           value:nil] build]];    // Event value
}


@end
