//
//  EboticonViewController.h
//  Eboticon1.2
//
//  Created by Jarryd McCree on 2/13/14.
//  Copyright (c) 2014 Incling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EboticonGif.h"

@interface EboticonViewController : UIViewController

@property (assign, nonatomic) NSUInteger index;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) EboticonGif *eboticonGif;


@end
