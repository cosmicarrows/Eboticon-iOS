//
//  MainVC.m
//  LazyLoadingCollectionView
//
//  Created by Cian on 11/09/14.
//  Copyright (c) 2014 Cian. All rights reserved.
//

////////////////////////
// This class is utilised to download an image using its url and store it in the model object ImageRecord. We can start and even cancel a
// particular download in the middle of the process using this class.


#import "ImageDownloader.h"
#import "ImageCache.h"
#import "UIImage+Decode.h"
#import "EboticonGif.h"

@interface ImageDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, assign) BOOL doesPngExists;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@end


@implementation ImageDownloader

#pragma mark

- (void)startDownload
{
    self.doesPngExists = YES;
    self.activeDownload = [NSMutableData data];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageRecord.stillUrl] ];     //still file name
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.imageConnection = conn;
}

- (void)cancelDownload
{
     NSLog(@"cancelDownload for %@", self.imageRecord.stillUrl);
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   // NSLog(@"didReceiveData for %@", self.imageRecord.stillUrl);
    [self.activeDownload appendData:data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
    NSString *contentType = nil;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
        //if text/html; charset=UTF-8
        if (![contentType isEqualToString:@"image/png"]){
             self.doesPngExists = NO;
            NSLog(@"Missing Data for %@", self.imageRecord.stillUrl);
            self.imageRecord.thumbImage = [UIImage imageNamed:@"placeholder.png"];
        }
    }

  
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   // NSLog(@"didFailWithError for %@", self.imageRecord.stillUrl);
    
    self.imageRecord.thumbImage = [UIImage imageNamed:@"placeholder.png"];
    
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"connectionDidFinishLoading for %@", self.imageRecord.stillUrl);
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    // Resize the downloaded image if its large. This is optional. If u fetching a thumbnail itself, ignore this step.
    image = [self imageWithImage:image
                scaledToMaxWidth:150
                       maxHeight:150];
    
    // Decode the image before caching
    image = [image decodedImage];
    
    // Add the image to the shared cache
    [[ImageCache sharedImageCache] AddImage:self.imageRecord.stillUrl :image];
    
    //NSLog(@"does png exists %hhd", self.doesPngExists);
    if(self.doesPngExists){
        self.imageRecord.thumbImage = image;
    }
    else{
        self.imageRecord.thumbImage = [UIImage imageNamed:@"placeholder.png"];
    }
    
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
        self.completionHandler();
}

#pragma mark - Image Resizers

- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end