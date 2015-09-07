//
//  KeyboardUICollectionViewFlowLayout.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 5/5/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "KeyboardCollectionViewFlowLayout.h"

@implementation KeyboardCollectionViewFlowLayout

-(id)init
{
    if (!(self = [super init])) return nil;
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake(63, 63);
    self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    self.minimumInteritemSpacing = 1.0f;
    self.minimumLineSpacing = 1.0f;
    
    return self;
}

- (CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = ceil(itemCount / 10.0);
    
    return CGSizeMake(self.collectionView.frame.size.width * pages, self.collectionView.frame.size.height);
}


@end
