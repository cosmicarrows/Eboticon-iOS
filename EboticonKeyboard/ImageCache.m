//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

////////////////////////
// This class is a singleton that is used to cache the images using NSCache. We can add a new image to cache, retrieve a cached image and check
// if the image exists in cache or not using this class. Just drag and drop this class in your project, import it wherever you want to use it.
//

#import "ImageCache.h"


@implementation ImageCache

@synthesize imgCache;

#pragma mark - Methods

static ImageCache* sharedImageCache = nil;

+(ImageCache*)sharedImageCache
{
    @synchronized([ImageCache class])
    {
        if (!sharedImageCache)
            sharedImageCache= [[self alloc] init];
        
        return sharedImageCache;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([ImageCache class])
    {
        NSAssert(sharedImageCache == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedImageCache = [super alloc];
        
        return sharedImageCache;
    }
    
    return nil;
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        imgCache = [[NSCache alloc] init];
    }
    
    return self;
}

- (void) AddImage:(NSString *)imageURL :(UIImage *)image
{
    if (image!=nil)
        [imgCache setObject:image forKey:imageURL];
}

- (void) AddFLImage:(NSString *)imageURL :(FLAnimatedImage *)image
{
    if (image!=nil)
        [imgCache setObject:image forKey:imageURL];
}

- (void) AddData:(NSString *)dataURL :(NSData *)data {
    if (data != nil) {
        [imgCache setObject:data forKey:dataURL];
    }
}

- (NSData *) GetData:(NSString *)dataURL {
    return [imgCache objectForKey:dataURL];
}

- (NSString*) GetImage:(NSString *)imageURL
{
    return [imgCache objectForKey:imageURL];
}

- (FLAnimatedImage *)GetFLAnimatedImage:(NSString *)FLAnimatedImageURL {
    return [imgCache objectForKey:FLAnimatedImageURL];
}

- (BOOL) DoesExist:(NSString *)imageURL
{
    if ([imgCache objectForKey:imageURL] == nil)
    {
        return false;
    }
    
    return true;
}


@end
