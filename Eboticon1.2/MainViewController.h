//
//  MainViewController.h
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

    @property (strong, nonatomic) NSMutableArray *allImages;
    @property (strong, nonatomic) NSMutableArray *recentImages;
    @property (strong, nonatomic) NSMutableArray *captionImages;
    @property (strong, nonatomic) NSMutableArray *noCaptionImages;

    @property (strong, nonatomic) id gifCategory;
    @property (nonatomic, assign) NSNumber* captionState;

@end
