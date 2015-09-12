//
//  LibraryAPI.h
//  BlueLibrary
//
//  Created by Troy Nunnally on 9/6/15.
//  Copyright (c) 2015 Eli Ganem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EboticonGif.h"


@interface LibraryAPI : NSObject

+ (LibraryAPI*)sharedInstance;

- (NSMutableArray*)getImages;

- (void)addAlbum:(EboticonGif*)album atIndex:(int)index;
- (void)deleteAlbumAtIndex:(int)index;
- (void)saveAlbums;



@end
