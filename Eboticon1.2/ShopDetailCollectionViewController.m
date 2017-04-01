//
//  ShopDetailCollectionViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 8/23/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "ShopDetailCollectionViewController.h"
#import "EboticonGif.h"
#import "ShopDetailCell.h"
#import "CHCSVParser.h"
#import "DDLog.h"
#import "OLImage.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <DFImageManager/DFImageManagerKit.h>
#import "ImageDownloader.h"
#import "ImageCache.h"
#import "Reachability.h"
#import "Eboticon-Swift.h"
//static const int ddLogLevel = LOG_LEVEL_ERROR;
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#define CURRENTSCREEN @"Shop Detail Screen"
#define BASEURL @"http://www.inclingconsulting.com/eboticon/purchased/"


@interface ShopDetailCollectionViewController (){
    NSMutableArray *_eboticonGifs;
    NSMutableArray *_packGifs;
}

@end

@implementation ShopDetailCollectionViewController

static NSString * const reuseIdentifier = @"ShopDetailCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load Gif csv file
    DDLogDebug(@"Eboticon Gif size %lu",(unsigned long)[_eboticonGifs count]);
    _eboticonGifs = [[NSMutableArray alloc] init];
    _packGifs     = [[NSMutableArray alloc] init];
    [self loadPurchaseEboticon];
    DDLogDebug(@"Gif Array count %lu",(unsigned long)[_eboticonGifs count]);
    
    //Sets the navigation bar title
    [self.navigationItem setTitle:[self.product.localizedTitle uppercaseString]];
    
    //Change Title Size
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    NSDictionary *size = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                          shadow, NSShadowAttributeName,
                          [UIFont fontWithName:@"Avenir-Black" size:14.0], NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = size;
    

    //Create Pack Gifs object
    
    
    
    //Add Buy or Free Button
    NSNumberFormatter * priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    [priceFormatter setLocale:self.product.priceLocale];
    NSDecimalNumber *freeCost = [NSDecimalNumber decimalNumberWithDecimal:
                                 [[NSNumber numberWithFloat:0.0f] decimalValue]];
    
    
    if ([[EboticonIAPHelper sharedInstance] productPurchased:self.product.productIdentifier]) {
        DDLogDebug(@"Purchased");
        
    } else if([self.product.price compare:freeCost] == NSOrderedSame){
        //Add Share Button
        UIBarButtonItem *buyButton = [[UIBarButtonItem alloc] initWithTitle:@"Free" style:UIBarButtonItemStylePlain target:self action:@selector(buyButtonTapped:)];
        self.navigationItem.rightBarButtonItem = buyButton;
    }
    else
    {
        //Add Share Button
        UIBarButtonItem *buyButton = [[UIBarButtonItem alloc] initWithTitle:@"Buy" style:UIBarButtonItemStylePlain target:self action:@selector(buyButtonTapped:)];
        self.navigationItem.rightBarButtonItem = buyButton;
    }
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"ShopDetailCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:CURRENTSCREEN forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)loadPurchaseEboticon
{
    if (![self checkConnnectivity]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Couldn't connect to the network. Please check your connection settings" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        [self presentViewController:controller animated:YES completion:nil];
    }else {
        [Webservice loadEboticonsWithEndpoint:@"purchased/published" completion:^(NSArray<EboticonGif *> *eboticons) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_eboticonGifs addObjectsFromArray:eboticons];
                [self createPackGifs];
                [self.collectionView reloadData];
            });
        }];
    }
    
}


-(void) createPackGifs
{
    if([_eboticonGifs count] > 0){
        EboticonGif *currentGif = [EboticonGif alloc];
        
        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];
            
            NSString * purchaseCategory = [currentGif purchaseCategory]; //Category
            
            DDLogDebug(@"gifCategory: %@", purchaseCategory);
            
            if([self.product.productIdentifier isEqual:purchaseCategory]) {
                [_packGifs addObject:[_eboticonGifs objectAtIndex:i]];
            }
            
        }
        
    } else {
        DDLogWarn(@"Eboticon Gif array count is less than zero.");
    }
}


#pragma mark IAP Purchases commands

- (void)buyButtonTapped:(id)sender {
    
    NSLog(@"Buying %@...", self.product.productIdentifier);
    [[EboticonIAPHelper sharedInstance] buyProduct:self.product];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    
    if ([self.product.productIdentifier isEqualToString:productIdentifier]) {
        NSLog(@"Purchased %@", self.product.productIdentifier);
        
        //Remove Buy Button
        self.navigationItem.rightBarButtonItem = nil;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pack purchased."
                                                        message:[NSString stringWithFormat:@"Thank you for purchasing %@. To use the %@ Eboticons, go to main library filter and select \"Purchased\" or click on \"Purchased\" icon in the keyboard. Enjoy!",self.product.localizedTitle,self.product.localizedTitle ]
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];

    }
}


#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_packGifs count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (ShopDetailCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.gifImageView.animatedImage = nil;
    
    EboticonGif *currentGif = [_packGifs objectAtIndex:indexPath.row];
    
    
    if ([[ImageCache sharedImageCache] DoesExist:currentGif.gifUrl] == true) {
        NSData *imageData = [[ImageCache sharedImageCache] GetData:currentGif.gifUrl];
        FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:imageData];
        cell.gifImageView.animatedImage = image;
    }else {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
        activityIndicator.center = cell.contentView.center;
        activityIndicator.tag = 505;
        [cell.contentView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        if ([self checkConnnectivity]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *imageURL = [NSURL URLWithString:currentGif.gifUrl];
                NSError *downloadError = nil;
                // Create an NSData object from the contents of the given URL.
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL
                                                          options:kNilOptions
                                                            error:&downloadError];
                if (downloadError) {
                    NSLog(@"error %@", downloadError.localizedDescription);
                    NSLog(@"url %@", currentGif.gifUrl);
                    
                }else {
                    [[ImageCache sharedImageCache] AddData:currentGif.gifUrl :imageData];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                    FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:imageData];
                    cell.gifImageView.animatedImage = image;
                });
                
            });
            
        }else {
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Select %ld",(long)indexPath.row);
}

- (BOOL) checkConnnectivity {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
