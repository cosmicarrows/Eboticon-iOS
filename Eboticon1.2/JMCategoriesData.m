//
//  JMEboticonDoc.m
//  Eboticon
//
//  Created by Jarryd McCree on 9/16/13.
//  Copyright (c) 2013 com.incling. All rights reserved.
//

#import "JMCategoriesData.h"
#import "JMCategoryData.h"

@implementation JMCategoriesData
@synthesize data = _data;
@synthesize thumbImage = _thumbImage;

- (id)initWithTitle:(NSString *)title thumbImage:(UIImage *)thumbImage{
    if((self = [super init])){
        self.data = [[JMCategoryData alloc] initWithTitle:title];
        self.thumbImage = thumbImage;
    }
    return self;
}

@end
