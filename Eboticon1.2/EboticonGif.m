//
//  EboticonGif.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/5/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "EboticonGif.h"
#define kBASEURL @"http://www.inclingconsulting.com/eboticon/"
@implementation EboticonGif

@synthesize fileName = _fileName;
@synthesize displayName = _displayName;
@synthesize stillName = _stillName;
@synthesize category = _category;
@synthesize movFileName = _movFileName;
@synthesize emotionCategory = _emotionCategory;
@synthesize purchaseCategory = _purchaseCategory;
@synthesize displayType = _displayType;
@synthesize skinTone = _skinTone;
@synthesize eboticonID = _eboticonID;

//- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString*)category movFileName:(NSString *)movFileName displayType:(NSString *)displayType skinTone:(NSString *)skinTone emotionCategory:(NSString *)emotionCategory
//{
//    if((self = [super init])){
//        self.fileName = displayName;
//        self.gifUrl = fileName;
//        self.displayName = displayName;
//        self.stillName = displayName;
//        self.stillUrl = stillName;
//        self.category = category;
//        self.movFileName = displayName;
//        self.movUrl = movFileName;
//        self.displayType = displayType;
//        self.emotionCategory = emotionCategory;
//        self.skinTone = skinTone;
//    }
//    return self;
//}


- (id)initWithAttributes:(NSString *)name gifURL:(NSString *)gifURL captionCategory:(NSString *)captionCategory category:(NSString *)category eboticonID:(NSNumber *)eboticonID movieURL:(NSString *)movieURL stillURL:(NSString *)stillURL skinTone:(NSString *)skinTone displayType:(NSString *)displayType purchaseCategory:(NSString *)purchaseCategory
{
    if ((self = [super init])) {
        self.fileName = name;
        self.displayName = name;
        self.movFileName = name;
        self.gifUrl = gifURL;
        self.category = captionCategory;
        self.eboticonID = eboticonID;
        self.stillUrl = stillURL;
        self.movUrl = movieURL;
        self.emotionCategory = category;
        self.skinTone = skinTone;
        self.purchaseCategory = purchaseCategory;
        
    }
    return  self;
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
