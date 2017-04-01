//
//  EboticonGif.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/5/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface EboticonGif : NSObject

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *stillName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *movFileName;
@property (strong, nonatomic) NSString *emotionCategory;
@property (strong, nonatomic) NSString *purchaseCategory;
@property (strong, nonatomic) NSString *stillUrl;
@property (strong, nonatomic) NSString *gifUrl;
@property (strong, nonatomic) NSString *movUrl;
@property (strong, nonatomic) NSString *displayType;
@property (strong, nonatomic) NSNumber *eboticonID;
@property (strong, nonatomic) NSString *skinTone;
@property (nonatomic, strong) UIImage *thumbImage;

- (id)initWithAttributes:(NSString *)name gifURL:(NSString *)gifURL captionCategory:(NSString *)captionCategory category:(NSString *)category eboticonID:(NSNumber *)eboticonID movieURL:(NSString *)movieURL stillURL:(NSString *)stillURL skinTone:(NSString *)skinTone displayType:(NSString *)displayType purchaseCategory:(NSString *)purchaseCategory;

-(NSString *) getFileName;
-(NSString *) getStillName;
-(NSString *) getDisplayName;
-(NSString *) getCategory;
-(NSString *) getMovFileName;
-(NSString *) getDisplayType;
-(NSString *) getEmotionCategory;
-(NSString *) getPurchaseCategory;

@end
