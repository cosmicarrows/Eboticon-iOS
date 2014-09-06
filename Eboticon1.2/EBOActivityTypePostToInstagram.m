//
//  EBOActivityTypePostToInstagram.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 8/26/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EBOActivityTypePostToInstagram.h"

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
    // The icon that appears in the "share sheet". NB: it's a mask, like UITabBar button images.
    
    /**
    CGRect rect = CGRectMake(0.0f, 0.0f, 85.0f, 85.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    rect = CGRectInset(rect, 15.0f, 15.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0f];
    [path stroke];
    
    rect = CGRectInset(rect, 0.0f, 10.0f);
    [@"IG" drawInRect:rect withFont:[UIFont fontWithName:@"Futura" size:13.0f] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    **/
    return [UIImage imageNamed:@"Icon_Instagram"];

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
    
    NSString * gifName = [self.movItems objectAtIndex:0];
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"mov"];
    //NSData *movData = [NSData dataWithContentsOfFile:filepath];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filepath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(filepath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    } else {
        NSLog(@"Video is Not Compatible");
    }
    
    [self activityDidFinish:YES];
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Eboticon Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    } else {
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Instagram Video" message:@"This Eboticon has been saved to your camera roll.  You will need to load it from your camera roll inside Instagram. Make sure to hashtag #eboticons!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [successAlert show];
    }
}

-(BOOL)isGifString:(NSString *)gifFileName {
    if([gifFileName length] >= 4 && [[gifFileName substringFromIndex: [gifFileName length] - 4] isEqualToString:@".gif"]) {
        return YES;
    }
    return NO;
}

@end
