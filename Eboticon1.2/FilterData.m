//
//  FilterData.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 10/23/15.
//  Copyright © 2015 Incling. All rights reserved.
//

#import "FilterData.h"

@implementation FilterData

@synthesize captionState;


+ (id)sharedInstance {
    static FilterData *sharedFilterData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFilterData = [[self alloc] init];
    });
    return sharedFilterData;
}

- (id)init {
    if (self = [super init]) {
        self.captionState = @(1);
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
