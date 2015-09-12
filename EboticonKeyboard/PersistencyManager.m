//
//  PersistencyManager.m
//  BlueLibrary
//
//  Created by Troy Nunnally on 9/6/15.
//  Copyright (c) 2015 Eli Ganem. All rights reserved.
//

#import "PersistencyManager.h"
#import "CHCSVParser.h"

@interface PersistencyManager () {
    // an array of all albums
    NSMutableArray *albums;
}

@end


@implementation PersistencyManager

- (id)init
{
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"]];
        albums = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (albums == nil)
        {
            [self loadGifsFromCSV];
        }
    }
    return self;
}

- (NSMutableArray*)getAlbums
{
    return albums;
}

- (void) loadGifsFromCSV
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_gifs" ofType:@"csv"];
    NSError *error = nil;
    
    //Read All Gifs From CSV
    @try {
        NSArray * csvImages = [NSArray arrayWithContentsOfCSVFile:path];
        
        if (csvImages == nil) {
            NSLog(@"Error parsing file: %@", error);
            return;
        }
        else {
            [albums addObjectsFromArray:csvImages];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to load csv: %@",exception);
    }
}


@end
