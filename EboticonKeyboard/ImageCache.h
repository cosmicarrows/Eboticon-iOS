//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <DFImageManager/DFImageManagerKit.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;

#pragma mark - Methods
+ (ImageCache*)sharedImageCache;
- (void) AddImage:(NSString *)imageURL :(UIImage *)image;
- (UIImage*) GetImage:(NSString *)imageURL;
- (FLAnimatedImage *) GetFLAnimatedImage:(NSString *)FLAnimatedImageURL;
- (BOOL) DoesExist:(NSString *)imageURL;
- (void) AddFLImage:(NSString *)imageURL :(FLAnimatedImage *)image;
- (void) AddData:(NSString *)dataURL :(NSData *)data;
- (NSData *) GetData:(NSString *)dataURL;
@end
