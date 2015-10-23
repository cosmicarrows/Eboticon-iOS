//
//  FilterData.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 10/23/15.
//  Copyright © 2015 Incling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterData : NSObject{
    NSNumber *captionState;
    
}

@property (nonatomic, retain) NSNumber *captionState;
+ (id)sharedInstance;



@end
