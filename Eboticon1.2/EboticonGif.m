//
//  EboticonGif.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/5/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonGif.h"

@implementation EboticonGif

@synthesize fileName = _fileName;
@synthesize displayName = _displayName;
@synthesize stillName = _stillName;
@synthesize category = _category;
@synthesize movFileName = _movFileName;

- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString*)category movFileName:(NSString *)movFileName
{
    if((self = [super init])){
        self.fileName = fileName;
        self.displayName = displayName;
        self.stillName = stillName;
        self.category = category;
        self.movFileName = movFileName;
    }
    return self;
}

-(NSString *)getFileName
{
    return _fileName;
}

-(NSString *) getStillName
{
    return _stillName;
}

-(NSString *) getDisplayName
{
    return _displayName;
}

-(NSString *) getCategory
{
    return _category;
}

-(NSString *) getMovFileName
{
    return _movFileName;
}


@end
