//
//  EboticonGif.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/5/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EboticonGif : NSObject

enum gifCategory
{
    caption=0,
    noCaption=1
};

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *stillName;
@property (strong, nonatomic) NSString *displayName;
//@property (nonatomic) enum gifCategory *category;
@property (strong, nonatomic) NSString *category;


//- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(enum gifCategory *)category;
- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString *)category;



@end
