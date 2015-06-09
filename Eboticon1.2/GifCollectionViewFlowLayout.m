//
//  GifCollectionViewFlowLayout.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 3/7/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import "GifCollectionViewFlowLayout.h"

@implementation GifCollectionViewFlowLayout

-(id)init
{
    if (!(self = [super init])) return nil;
    
    //self.itemSize = CGSizeMake(155, 155);    
    self.itemSize = CGSizeMake(100, 100);
    //self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    //self.minimumInteritemSpacing = 1.0f;
    //self.minimumLineSpacing = 10.0f;

    return self;
}


@end
