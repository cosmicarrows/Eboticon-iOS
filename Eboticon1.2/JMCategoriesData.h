//
//  JMEboticonDoc.h
//  Eboticon
//
//  Created by Jarryd McCree on 9/16/13.
//  Copyright (c) 2013 com.incling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMCategoryData;

@interface JMCategoriesData : NSObject

@property (strong) JMCategoryData *data;
@property (strong) UIImage *thumbImage;

- (id)initWithTitle:(NSString*)title thumbImage:(UIImage *)thumbImage;

@end
