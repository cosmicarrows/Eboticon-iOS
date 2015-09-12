//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by Troy Nunnally on 9/6/15.
//  Copyright (c) 2015 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"
#import "PersistencyManager.h"
#import "HTTPClient.h"

@interface LibraryAPI () {
    PersistencyManager *persistencyManager;
    HTTPClient *httpClient;
    BOOL isOnline;          //if the server should be updated with any changes made to the albums list
}

@end

@implementation LibraryAPI

- (id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
        httpClient = [[HTTPClient alloc] init];
        isOnline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
        
    }
    return self;
}


+ (LibraryAPI*)sharedInstance
{
    // 1: instance of your class
    static LibraryAPI *_sharedInstance = nil;
    
    // 2: the initialization code executes only once.
    static dispatch_once_t oncePredicate;
    
    // 3: Grand Central Dispatch (GCD) to execute a block which initializes an instance of LibraryAPI.
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    return _sharedInstance;
}

- (NSMutableArray*)getImages
{
    return [persistencyManager getAlbums];
}


- (void)downloadImage:(NSNotification*)notification
{
    // 1: downloadImage is executed via notifications and so the method receives the notification object as a parameter. The UIImageView and image URL are retrieved from the notification.
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    
    // 2: Retrieve the image from the PersistencyManager if it’s been downloaded previously.
    //imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    
    if (imageView.image == nil)
    {
        // 3: If the image hasn’t already been downloaded, then retrieve it using HTTPClient.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            // 4: When the download is complete, display the image in the image view and use the PersistencyManager to save it locally.
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
        });
    }    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
