//
//  EboticonGif.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 4/5/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EboticonGif : NSObject

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *stillName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *movFileName;
@property (strong, nonatomic) NSString *displayType;


- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString *)category movFileName:(NSString *)movFileName displayType:(NSString *)displayType;
-(NSString *) getFileName;
-(NSString *) getStillName;
-(NSString *) getDisplayName;
-(NSString *) getCategory;
-(NSString *) getMovFileName;
-(NSString *) getDisplayType;

@end
