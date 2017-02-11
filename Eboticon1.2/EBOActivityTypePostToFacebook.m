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
#import "DDLog.h"
#import "SIAlertView.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

@interface EBOActivityTypePostToFacebook()

@property (nonatomic, copy) NSArray *movItems;
@property (nonatomic, copy) NSString *movName;

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
    
    return [UIImage imageNamed:@"Icon_Facebook.png"];
}

-(id)initWithAttributes: (NSString *)movName {
    if ( self = [super init] ) {
        self.movName = movName;
    }
    return self;
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if ([self doesMovieExist:self.movName])
        return YES;
    else
        return NO;
    
}


//- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
//    // Given an array of NSObjects, returns YES if at least one of them can be handled by this activity
//    for (id obj in activityItems) {
//        if ([obj isKindOfClass:[NSURL class]]) {
//            NSURL *filePath = (NSURL *)obj;
//            NSString *gifName = [filePath lastPathComponent];
//            return [self isGifString:gifName];
//        }
//    }
//    return NO;
//}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Iterate through the activity items, filtering out the MKMapItem objects
    NSMutableArray *movItems = [NSMutableArray array];
    [movItems addObject:self.movName];
    self.movItems = movItems;
}


//- (void)prepareWithActivityItems:(NSArray *)activityItems {
//
//    NSMutableArray *movItems = [NSMutableArray array];
//    for (id obj in activityItems) {
//        if ([obj isKindOfClass:[NSURL class]]) {
//            NSURL *filePath = (NSURL *)obj;
//            NSString *gifName = [filePath lastPathComponent];
//            if([self isGifString:gifName]){
//                gifName = [[gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)] stringByAppendingString:@".mov"];
//            }
//            [movItems addObject:gifName];
//        }
//    }
//    self.movItems = movItems;
//}



- (void)performActivity {
    
    NSString * movName = [self.movItems objectAtIndex:0];
    //    NSString *filepath  = [[NSBundle mainBundle] pathForResource:movName ofType:nil];
    //NSData *movData = [NSData dataWithContentsOfFile:filepath];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", movName]];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(filepath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    } else {
        DDLogError(@"Video is Not Compatible");
    }
    
    [self activityDidFinish:YES];
}

//- (void)performActivity {
//
//    NSString * gifName = [self.movItems objectAtIndex:0];
//    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
//    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
//    //NSData *movData = [NSData dataWithContentsOfFile:filepath];
//
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum(filepath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        }
//    } else {
//        DDLogError(@"Video is Not Compatible");
//    }
//
//    [self activityDidFinish:YES];
//}


-(BOOL)doesMovieExist:(NSString *)movFileName {
    //
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", self.movName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
    
    if(fileExists)
        return YES;
    else
        return NO;
    
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Eboticon Saving Failed"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else {
        SIAlertView *successAlertView = [[SIAlertView alloc] initWithTitle:@"Facebook Video" andMessage:@"This Eboticon has been copied and saved to your camera roll.  You can load it from your camera roll or paste to comments inside Facebook. Make sure to hashtag #eboticons!"];
        [successAlertView addButtonWithTitle:@"OK"
                                        type:SIAlertViewButtonTypeDestructive
                                     handler:^(SIAlertView *alert) {
                                         [self openFacebook];
                                         //[self openPostFacebook];
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


-(void)openPostFacebook
{
    
    NSString * gifName = [self.movItems objectAtIndex:0];
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    
    NSDictionary* userInfo = @{@"filepath": filepath};
    
    // Post a notification to loginComplete
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postToFacebook" object:nil userInfo:userInfo];
    
}

-(void)openFacebook
{
    
    NSURL *facebookURL = [NSURL URLWithString:@"fb://publish"];
    //NSURL *facebookURL = [NSURL URLWithString:@"fb://publish/profile/me"];
    NSURL *facebookWebURL = [NSURL URLWithString:@"http://www.facebook.com"];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [self sendShareToGoogleAnalytics:@"nativeApp"];
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        DDLogDebug(@"Facebook not installed on device");
        [self sendShareToGoogleAnalytics:@"viaWeb"];
        SIAlertView *fbNotInstalledAlert = [[SIAlertView alloc] initWithTitle:@"Whoops!" andMessage:@"The Facebook app is not installed on your device.  We'll open Facebook via your web browser."];
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



-(void) sendShareToGoogleAnalytics:(NSString*) redirectType
{
    if (!redirectType.length) {
        DDLogError(@"redirectType null or empty! Not sending analytics!");
        return;
    }
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Eboticon Social Media Share"     // Event category (required)
                                                          action:@"facebook"  // Event action (required)
                                                           label:redirectType         // Event label
                                                           value:nil] build]];    // Event value
}



@end
