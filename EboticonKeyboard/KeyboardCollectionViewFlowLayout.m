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
    NSLog(@"KeyboardCollectionViewFlowLayout init");
    
    if (!(self = [super init])) return nil;
//    
//    NSLog(@"UICollectionViewScrollDirectionVertical");
//
//    self.scrollDirection = UICollectionViewScrollDirectionVertical;
//    self.itemSize = CGSizeMake(100, 94);
//    self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
//    self.minimumInteritemSpacing = 1.0f;
//    self.minimumLineSpacing = 1.0f;
//    
    return self;
}


//
//- (CGSize)collectionViewContentSize
//{
//    
//    NSLog(@"KeyboardCollectionViewFlowLayout collectionViewContentSize");
//
//    
//    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
//    NSInteger pages = ceil(itemCount / 8.0);
//    NSInteger numberInRow = ceil(itemCount / 2.0);
//    
//    return CGSizeMake((self.collectionView.frame.size.width +36) * pages, self.collectionView.frame.size.height);
//    
//    return CGSizeMake(numberInRow * 90 + 30.0, self.collectionView.frame.size.height);
//    
//}


@end
