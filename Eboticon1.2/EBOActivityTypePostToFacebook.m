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
    // The icon that appears in the "share sheet". NB: it's a mask, like UITabBar button images.
    
    /**
    CGRect rect = CGRectMake(0.0f, 0.0f, 85.0f, 85.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    rect = CGRectInset(rect, 15.0f, 15.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0f];
    [path stroke];
    
    rect = CGRectInset(rect, 0.0f, 10.0f);
    [@"FBook" drawInRect:rect withFont:[UIFont fontWithName:@"Futura" size:13.0f] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     **/
    
    return [UIImage imageNamed:@"Icon_Facebook"];
    //return image;

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
    // Open the map items in Maps
    //[MKMapItem openMapsWithItems:self.mapItems launchOptions:nil];
    
    [self shareOnFaceBook];
    return;
    
    NSString * gifName = [self.movItems objectAtIndex:0];
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    
    NSData *movData = [NSData dataWithContentsOfFile:filepath];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        NSLog(@"Permission Granted");
        
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        NSLog(@"Permission Denied");

    }
    
    /**
     //Save to Camera Roll
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
        UISaveVideoAtPathToSavedPhotosAlbum(filepath, nil, nil, nil);
    }
     **/
  
    
    [self activityDidFinish:YES];
}

-(BOOL)isGifString:(NSString *)gifFileName {
    if([gifFileName length] >= 4 && [[gifFileName substringFromIndex: [gifFileName length] - 4] isEqualToString:@".gif"]) {
        return YES;
    }
    return NO;
}

-(void)shareOnFaceBook
{
    NSString * gifName = [self.movItems objectAtIndex:0];
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    //NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    
    //sample_video.mov is the name of file
    NSString *filePathOfVideo = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    
    NSLog(@"Path  Of Video is %@", filePathOfVideo);
    NSData *videoData = [NSData dataWithContentsOfFile:filePathOfVideo];
    //you can use dataWithContentsOfURL if you have a Url of video file
    //NSData *videoData = [NSData dataWithContentsOfURL:shareURL];
    //NSLog(@"data is :%@",videoData);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"video/quicktime", @"contentType",
                                   @"Video name ", @"name",
                                   @"description of Video", @"description",
                                   nil];
    
    if (FBSession.activeSession.isOpen)
    {
        [FBRequestConnection startWithGraphPath:@"me/videos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if(!error)
                                  {
                                      NSLog(@"RESULT: %@", result);
                                      //[self throwAlertWithTitle:@"Success" message:@"Video uploaded"];
                                  }
                                  else
                                  {
                                      NSLog(@"ERROR: %@", error.localizedDescription);
                                      //[self throwAlertWithTitle:@"Denied" message:@"Try Again"];
                                  }
                              }];
    }
    else
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_actions",
                                nil];
        // OPEN Session!
        [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone  allowLoginUI:YES
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                                             if (error)
                                             {
                                                 NSLog(@"Login fail :%@",error);
                                             }
                                             else if (FB_ISSESSIONOPENWITHSTATE(status))
                                             {
                                                 [FBRequestConnection startWithGraphPath:@"me/videos"
                                                                              parameters:params
                                                                              HTTPMethod:@"POST"
                                                                       completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                           if(!error)
                                                                           {
                                                                               //[self throwAlertWithTitle:@"Success" message:@"Video uploaded"];
                                                                               
                                                                               NSLog(@"RESULT: %@", result);
                                                                           }
                                                                           else
                                                                           {
                                                                               //[self throwAlertWithTitle:@"Denied" message:@"Try Again"];
                                                                               
                                                                               NSLog(@"ERROR: %@", error.localizedDescription);
                                                                           }
                                                                           
                                                                       }];
                                             }
                                         }];
    }
}



@end
