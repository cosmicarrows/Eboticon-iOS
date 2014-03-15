//
//  GifViewController.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/27/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifCollectionViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) NSMutableArray *allImages;
@property (strong, nonatomic) NSMutableArray *recentImages;
@property (strong, nonatomic) NSMutableArray *captionImages;
@property (strong, nonatomic) NSMutableArray *noCaptionImages;

@property (strong, nonatomic) id gifCategory;


@end
