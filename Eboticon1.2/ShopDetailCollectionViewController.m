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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface ShopDetailCollectionViewController (){
    NSMutableArray *_eboticonGifs;
    NSMutableArray *_packGifs;
}

@property (nonatomic, assign) BOOL isEboticonsLoaded;


@end

@implementation ShopDetailCollectionViewController

static NSString * const reuseIdentifier = @"ShopDetailCell";

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");

    [super viewDidLoad];
    
    //Load Gif csv file
    DDLogDebug(@"Eboticon Gif size %lu",(unsigned long)[_eboticonGifs count]);
    _eboticonGifs = [[NSMutableArray alloc] init];
    _packGifs     = [[NSMutableArray alloc] init];
    [self loadPurchaseEboticon];
    DDLogDebug(@"Gif Array count %lu",(unsigned long)[_eboticonGifs count]);
    
    //Sets the navigation bar title
    [self makeNavBarNonTransparent];
    [self.navigationItem setTitle:[self.product.localizedTitle uppercaseString]];
    
    
    //Create Pack Gifs object
    self.savedSkinTone = [[NSUserDefaults standardUserDefaults] stringForKey:@"skin_tone"];
    
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
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0f, [[UIScreen mainScreen] bounds].size.height/2.0f-100);
        spinner.hidesWhenStopped = YES;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        
        NSLog(@"loadPurchaseEboticon");
        [Helper getEboticons:@"purchased/published" completion:^(NSArray<EboticonGif *> *eboticons) {
            NSLog(@"purchased/published");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (eboticons != nil) {
                    
                    [_eboticonGifs removeAllObjects];
                    [_eboticonGifs addObjectsFromArray:eboticons];
                    [self createPackGifs];
                    [spinner stopAnimating];
                    [self.collectionView reloadData];
                }
            });
        }];
    }
    
}


-(void) createPackGifs
{
    NSLog(@"createPackGifs");

    if([_eboticonGifs count] > 0){
        EboticonGif *currentGif = [EboticonGif alloc];
        [_packGifs removeAllObjects];
        
        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];

            
            NSString * purchaseCategory = [currentGif purchaseCategory];
            NSString * skinTone = [currentGif skinTone];
            
            if([skinTone isEqual:self.savedSkinTone] && [self.product.productIdentifier isEqual:purchaseCategory]){
                [_packGifs addObject:[_eboticonGifs objectAtIndex:i]];
                
            }
            
        }
        
        NSLog(@"Pack Gifs Count: %lu", (unsigned long)[_packGifs count] );
        NSLog(@"Eboticon Gifs Count: %lu", (unsigned long)[_eboticonGifs count] );
        
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.activateBuy == true) {
        [self buyButtonTapped:nil];
    }
    
   // [self makeNavBarNonTransparent];
    
    
}


- (void) makeNavBarNonTransparent {
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat statusBarHeight = app.statusBarFrame.size.height;
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusBarHeight, [UIScreen mainScreen].bounds.size.width, 40)];
    statusBarView.backgroundColor = UIColorFromRGB(0x2C1D41);
    [self.view addSubview:statusBarView];
    
//    UINavigationBar *bar = [self.navigationController navigationBar];
//    [bar setBarTintColor:UIColorFromRGB(0x2C1D41)];
//    [bar setTranslucent:NO];
    
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
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Pack purchased."
                                     message:[NSString stringWithFormat:@"Thank you for purchasing %@. To use the %@ Eboticons, go to main library filter and select \"Purchased\" or click on \"Purchased\" icon in the keyboard. Enjoy!",self.product.localizedTitle,self.product.localizedTitle ]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}


- (void)showUnlockView {
    UnlockView *unlockView = [[UnlockView alloc]initWithFrame:self.view.frame];
    CGRect frame = unlockView.frame;
    frame.origin.y = frame.origin.y + 64;
    unlockView.frame = frame;
    CGFloat boldTextFontSize = 17.0f;
    unlockView.descLabel.text = [NSString stringWithFormat:@"Unlock %@ to get these new emojis and stickers. It’s only %@%@. Get it NOW!",[_product.localizedTitle capitalizedString], [_product.priceLocale objectForKey:NSLocaleCurrencySymbol], _product.price];
    NSRange range1 = [unlockView.descLabel.text rangeOfString:[_product.localizedTitle capitalizedString]];
    NSRange range2 = [unlockView.descLabel.text rangeOfString:[NSString stringWithFormat:@"%@%@",[_product.priceLocale objectForKey:NSLocaleCurrencySymbol], _product.priceLocale]];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:unlockView.descLabel.text];
    
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:boldTextFontSize]}
                            range:range1];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:boldTextFontSize]}
                            range:range2];
    
    unlockView.descLabel.attributedText = attributedText;
    __weak UnlockView *weakUnlockView = unlockView;
    [unlockView setCloseButtonBlock:^{
        [UIView animateWithDuration:0.3 animations:^{
            [weakUnlockView setAlpha:0];
        } completion:^(BOOL finished) {
            [weakUnlockView removeFromSuperview];
        }];
        
    }];
    __weak ShopDetailCollectionViewController *weakSelf = self;
    [unlockView setUnlockButtonBlock:^{
        [weakSelf buyButtonTapped:weakUnlockView.unlockButton];
        [weakUnlockView removeFromSuperview];
    }];
    
    //Set Image
    if([_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"GreekPack"];
    }
    else if([_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"BaePack"];
    }
    else if([_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"GreetingPack"];
    }
    else if([_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"ChurchPack"];
    }
    else if([_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [_product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"RatchetPack"];
    }
    else {
        unlockView.packImageView.image = [UIImage imageNamed:@"EboticonBundle"];
    }

    
    [self.view addSubview:unlockView];
}

#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (_packGifs.count > 0) {
        self.collectionView.backgroundView = nil;
        return _packGifs.count;
        
    }
    else if (self.isEboticonsLoaded == YES && _packGifs.count == 0) {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.collectionView.backgroundView = messageLabel;
        return 0;
    }
    else {
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (ShopDetailCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //FLAnimatedImage  *temporaryImage = myAnimatedImageView.animatedImage;
    //myAnimatedImageView.animatedImage = nil;
    cell.gifImageView.animatedImage = nil;
    
    cell.gifImageView.image = [UIImage imageNamed:@"placeholder"];
    
    EboticonGif *currentGif = [_packGifs objectAtIndex:indexPath.row];
    
    if (![[EboticonIAPHelper sharedInstance] productPurchased:_product.productIdentifier]) {
        
        [[cell gifImageView] setAlpha:0.5];
    }

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
                    self.isEboticonsLoaded = YES;
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
    if (![[EboticonIAPHelper sharedInstance] productPurchased:_product.productIdentifier]) {
        
        [self showUnlockView];
    }
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(self.view.bounds.size.width/3 - 8, self.view.bounds.size.width/3 - 8);
    
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
