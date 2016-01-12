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
@synthesize displayType = _displayType;
@synthesize emotionCategory = _emotionCategory;
@synthesize purchaseCategory = _purchaseCategory;

- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString*)category movFileName:(NSString *)movFileName displayType:(NSString *)displayType emotionCategory:(NSString *)emotionCategory
{
    if((self = [super init])){
        self.fileName = fileName;
        self.displayName = displayName;
        self.stillName = stillName;
        self.category = category;
        self.movFileName = movFileName;
        self.displayType = displayType;
        self.emotionCategory = emotionCategory;
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

-(NSString *) getDisplayType
{
    return _displayType;
}

-(NSString *) getEmotionCategory
{
    return _emotionCategory;
}

-(NSString *) getPurchaseCategory
{
    return _purchaseCategory;
}


@end
