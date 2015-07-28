//
//  JMEboticonData.m
//  Eboticon
//
//  Created by Jarryd McCree on 9/16/13.
//  Copyright (c) 2013 com.incling. All rights reserved.
//

#import "JMCategoryData.h"

@implementation JMCategoryData

@synthesize title = _title;

- (id)initWithTitle:(NSString *)title  {
    if((self = [super init])) {
        self.title = title;
    }
    return self;
}

@end
