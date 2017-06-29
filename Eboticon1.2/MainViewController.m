//
//  MainViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "MainViewController.h"
#import "GAITrackedViewController.h"
#import "JMCategoryData.h"
#import "JMCategoriesData.h"
//#import "GifCollectionViewController.h"
//#import "GifCollectionViewFlowLayout.h"
#import "GifDetailViewController.h"
#import "OLImage.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
//#import "CHCSVParser.h"
#import "EboticonGif.h"
#import "EboticonGifCell.h"
#import "DDLog.h"
#import <QuartzCore/QuartzCore.h>
#import "SWRevealViewController.h"
#import "FilterData.h"
#import "Reachability.h"
#import "Eboticon-Swift.h"
//In-app purchases (IAP) libraries
#import "EboticonIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "GlobalScope.h"



#import "ShopDetailCollectionViewController.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;
//static const int ddLogLevel = LOG_LEVEL_DEBUG;

#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define CATEGORY_RECENT @"Recent"
#define CATEGORY_PURCHASED @"Purchased"
#define CATEGORY_CAPTION @"Caption"
#define CATEGORY_NO_CAPTION @"No Caption"
#define CSV_CATEGORY_NO_CAPTION @"NoCaption"

//Name of Categories in the CSV File
#define CATEGORY_ALL @"all"
#define CATEGORY_SMILE @"happy"
#define CATEGORY_NOSMILE @"not_happy"
#define CATEGORY_HEART @"love"
#define CATEGORY_GIFT @"greeting"
#define CATEGORY_HOLIDAY @"holiday"
#define CATEGORY_EXCLAMATION @"exclamation"

#define BASEURL @"http://www.inclingconsulting.com/eboticon/"

#define kPublishedEboticonsURL = "published"
#define kPublishedPurchasedPackURL = "purchased/published"

@interface MainViewController (){
    UIToolbar *_toolbar;
    NSMutableArray *_toolbarButtons;
    NSMutableArray *_eboticonGifs;
    
    NSMutableArray *_allImages;
    NSMutableArray *_purchasedImages;
    NSMutableArray *_allImagesCaption;
    NSMutableArray *_allImagesNoCaption;
    NSMutableArray *_exclamationImagesCaption;
    NSMutableArray *_exclamationImagesNoCaption;
    NSMutableArray *_smileImagesCaption;
    NSMutableArray *_smileImagesNoCaption;
    NSMutableArray *_nosmileImagesCaption;
    NSMutableArray *_nosmileImagesNoCaption;
    NSMutableArray *_giftImagesCaption;
    NSMutableArray *_giftImagesNoCaption;
    NSMutableArray *_heartImagesCaption;
    NSMutableArray *_heartImagesNoCaption;
    
    NSMutableArray *_currentEboticonGifs;
    
//    NSArray *_products;
}

// Collection View
@property (nonatomic, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) UIImageView *noConnectionImageView;

//Reachability
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic, assign) BOOL isEboticonsLoaded;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Add Background without repeating
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_keyboard.png"].CGImage;

    //Get Saved Skin Tone
    self.savedSkinTone = [[NSUserDefaults standardUserDefaults] stringForKey:@"skin_tone"];
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:_gifCategory forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
    
    
    // Do any additional setup after loading the view.
    DDLogDebug(@"Gif Category is %@",_gifCategory);
    if([_gifCategory isEqualToString:CATEGORY_RECENT])
    {
        UIBarButtonItem *clearbutton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Clear"
                                        style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(clearRecentGifs)];
        self.navigationItem.leftBarButtonItem = clearbutton;
    }
    
    //Create Mutable Arrays of Eboticons
    [self initializeEboticons];
    
    //Load current products
    //[self getProducts];
    
    [self initNoConnection];
    
    self.isEboticonsLoaded = NO;
    [self loadEboticon];
    
    //[self populateGifArrays];
    
    // Configure Collection View
    [self configureCollectionView];
    
    //GOOGLE ANALYTICS
    [self sendToGoogleAnalytics];
    
    //Add sidebar menu button
    [self setSidebarItems];
    
    //Make nav bar transparent
    [self makeNavBarTransparent];
    
    //Create Nav Bar Logo
    [self makeNavBarLogo];
    
    //  [self getPurchaseGifs];
    
    //Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadEboticons:)
                                                 name:@"reloadEboticons"
                                               object:nil];
    
    [self initializeReachability];
    
}


#pragma mark - Reachability



- (void) initializeReachability {
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"api.eboticons.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}


/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NSLog(@"updateInterfaceWithReachability");
    
    if (reachability == self.hostReachability || reachability == self.internetReachability)
    {
        [self configureConnectionView:reachability];
    }
}


- (void)configureConnectionView:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            self.noConnectionImageView.hidden = NO;
            self.collectionView.hidden = YES;
            [self showNoConnectionImage];
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
           
            self.noConnectionImageView.alpha = 0.0;
            self.noConnectionImageView.hidden = YES;
             [self loadEboticon];
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            self.noConnectionImageView.alpha = 0.0;
            self.noConnectionImageView.hidden = YES;
            [self loadEboticon];
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    NSLog(@"status string: %@", statusString);
}

- (BOOL) doesInternetExist {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void) initNoConnection{
    self.noConnectionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noconnection"]];
    self.noConnectionImageView.alpha = 0;
    self.noConnectionImageView.center = self.view.center;
    self.noConnectionImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:self.noConnectionImageView];
    
}

-(void) showNoConnectionImage{
    
    self.noConnectionImageView.image = [UIImage imageNamed:@"noconnection"];

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.noConnectionImageView.alpha = 1; }
                     completion:^(BOOL finished){}
     ];
    
    self.isEboticonsLoaded = NO;
}

-(void) showServerDownImage{
    
    self.noConnectionImageView.image = [UIImage imageNamed:@"serverdown"];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ self.noConnectionImageView.alpha = 1; }
                     completion:^(BOOL finished){}
     ];
    
    self.isEboticonsLoaded = NO;
}



-(void) showNoConnectionAlert{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Couldn't connect to the network. Please check your connection settings" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Initialization


- (void)makeNavBarLogo{
    UIImageView *imageView = [[UIImageView alloc]
                              initWithFrame:CGRectMake(0,0,3,20)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = NO;
    imageView.image = [UIImage imageNamed:@"NavigationBarLogo"];
    self.navigationItem.titleView = imageView;
}

- (void)reverseMenu:(UITapGestureRecognizer *)sender{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.revealViewController rightRevealToggleForTapGesture];
}

- (void) initializeEboticons {
    
    //Initialize Gifs
    _currentEboticonGifs         = [[NSMutableArray alloc] init];
    _allImages                   = [[NSMutableArray alloc] init];
    _purchasedImages             = [[NSMutableArray alloc] init];
    _allImagesCaption            = [[NSMutableArray alloc] init];
    _allImagesNoCaption          = [[NSMutableArray alloc] init];
    _exclamationImagesCaption    = [[NSMutableArray alloc] init];
    _exclamationImagesNoCaption  = [[NSMutableArray alloc] init];
    _smileImagesCaption          = [[NSMutableArray alloc] init];
    _smileImagesNoCaption        = [[NSMutableArray alloc] init];
    _nosmileImagesCaption        = [[NSMutableArray alloc] init];
    _nosmileImagesNoCaption      = [[NSMutableArray alloc] init];
    _giftImagesCaption           = [[NSMutableArray alloc] init];
    _giftImagesNoCaption         = [[NSMutableArray alloc] init];
    _heartImagesCaption          = [[NSMutableArray alloc] init];
    _heartImagesNoCaption        = [[NSMutableArray alloc] init];
    _eboticonGifs = [[NSMutableArray alloc] init];
    
};
- (void) sendToGoogleAnalytics {
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:_gifCategory forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
}

- (void) setSidebarItems{
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(rightRevealToggle:)];
    
    self.navigationItem.rightBarButtonItem = revealButtonItem;
}

- (void) configureCollectionView {
    
    //Register the Gif Cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"EboticonGifCell" bundle:nil] forCellWithReuseIdentifier:@"AnimatedGifCell"];
    
    //Add background image
    //self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Ebo_Background.png"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //Add Layout Control
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
    
}


- (void) makeNavBarTransparent {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

-(void) addToolbar
{
    //Create toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //Create buttons
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *enlarge = [[UIBarButtonItem alloc] initWithTitle:@"Enlarge" style:UIBarButtonItemStylePlain target:self action:nil];
    _toolbarButtons = [NSMutableArray arrayWithObjects:shareButton, enlarge, nil];
    
    
    [self.view addSubview:_toolbar];
    [self.view bringSubviewToFront:_toolbar];
    [_toolbar setItems:_toolbarButtons];
}


#pragma mark -
#pragma mark Eboticon Helper Functions

- (void)loadEboticon
{
    if(self.isEboticonsLoaded == NO){
        if (![self doesInternetExist]) {
            [self showNoConnectionImage];
        }else {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            spinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0f, [[UIScreen mainScreen] bounds].size.height/2.0f-100);
            spinner.hidesWhenStopped = YES;
            [self.view addSubview:spinner];
            [spinner startAnimating];
            [Webservice loadEboticonsWithEndpoint:@"eboticons/published" completion:^(NSArray<EboticonGif *> *eboticons) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_eboticonGifs removeAllObjects];
                    [_eboticonGifs addObjectsFromArray:eboticons];
                    
                    DDLogDebug(@"loadEboticon _eboticonCount: %lu", (unsigned long)_eboticonGifs.count);
                    
                    [self populateGifArrays];
                    [spinner stopAnimating];
                    
                     [self.collectionView reloadData];
                    
                  

                });
            }];
        }
        
        self.isEboticonsLoaded = YES;
    }
    
}

- (void)reloadEboticons:(NSNotification *) notification{
    NSLog(@"***reloadEboticons");
    self.isEboticonsLoaded = NO;
    self.savedSkinTone = [[NSUserDefaults standardUserDefaults] stringForKey:@"skin_tone"];
    [self loadEboticon];
};

-(void) populateGifArrays
{
    if([_eboticonGifs count] > 0){
        EboticonGif *currentGif = [EboticonGif alloc];
        _captionImages          = [[NSMutableArray alloc]init];
        _noCaptionImages        = [[NSMutableArray alloc]init];
        _allImages              = [[NSMutableArray alloc]init];
        _recentImages           = [[NSMutableArray alloc]init];
        _exclamationImagesCaption   = [[NSMutableArray alloc]init];
        _exclamationImagesNoCaption = [[NSMutableArray alloc]init];
        _smileImagesCaption         = [[NSMutableArray alloc]init];
        _smileImagesNoCaption       = [[NSMutableArray alloc]init];
        _nosmileImagesCaption       = [[NSMutableArray alloc]init];
        _nosmileImagesNoCaption     = [[NSMutableArray alloc]init];
        _giftImagesCaption          = [[NSMutableArray alloc]init];
        _giftImagesNoCaption        = [[NSMutableArray alloc]init];
        _heartImagesCaption         = [[NSMutableArray alloc]init];
        _heartImagesNoCaption       = [[NSMutableArray alloc]init];
        
        
        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];
            
            NSString * gifCategory = [currentGif emotionCategory]; //Category
            NSString * gifCaption = [currentGif category];         //Caption
            NSString * skinTone = [currentGif skinTone];           //Skin
            
            
            // NSLog(@"Current Gif filename:%@ stillname:%@ displayname:%@ category:%@ movie:%@ displayType:%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category], [currentGif movFileName], [currentGif displayType]);
            
            if([skinTone isEqual:self.savedSkinTone]){
                if([gifCategory isEqual:CATEGORY_SMILE]) {
                    //  NSLog(@"Adding eboticon to category CATEGORY_SMILE:%@",[currentGif fileName]);
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_smileImagesCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_smileImagesNoCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                } else if([gifCategory isEqual:CATEGORY_NOSMILE]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_nosmileImagesCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_nosmileImagesNoCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                }
                else if([gifCategory isEqual:CATEGORY_HEART]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_heartImagesCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_heartImagesNoCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                    // NSLog(@"Adding eboticon to category CATEGORY_HEART:%@",[currentGif objectAtIndex:0]);
                    
                }
                else if([gifCategory isEqual:CATEGORY_GIFT]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_giftImagesCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_giftImagesNoCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                    // NSLog(@"Adding eboticon to category CATEGORY_GIFT:%@",[currentGif fileName]);
                }
                else if([gifCategory isEqual:CATEGORY_EXCLAMATION]) {
                    
                    
                    if ([gifCaption isEqual:@"Caption"])
                        [_exclamationImagesCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_exclamationImagesNoCaption addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                    // NSLog(@"Adding eboticon to category CATEGORY_EXCLAMATION:%@",[currentGif fileName]);
                }
                
                else if([gifCategory isEqual:CATEGORY_ALL]) {
                    
                    
                    if ([gifCaption isEqual:@"Caption"])
                        [_captionImages addObject:[_eboticonGifs objectAtIndex:i]];
                    else{
                        [_noCaptionImages addObject:[_eboticonGifs objectAtIndex:i]];
                    }
                    
                    // NSLog(@"Adding eboticon to category CATEGORY_EXCLAMATION:%@",[currentGif fileName]);
                }
                
                else {
                    //  NSLog(@"Eboticon category not recognized for eboticon: %@ with category:%@",[currentGif fileName],[currentGif category]);
                }
                
                if ([gifCaption isEqual:@"Caption"])
                    [_captionImages addObject:[_eboticonGifs objectAtIndex:i]];
                else{
                    [_noCaptionImages addObject:[_eboticonGifs objectAtIndex:i]];
                }
            }
            
            
        }//End for
        
        
        _allImages = [_eboticonGifs mutableCopy];
        _recentImages = [self getRecentGifs];
        
    } else {
        DDLogWarn(@"Eboticon Gif array count is less than zero.");
    }
    
    NSLog(@"populateGifArrays savedSkinTone: %@", self.savedSkinTone);
}

-(NSMutableArray*) getRecentGifs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentGifs = [[defaults objectForKey:RECENT_GIFS_KEY] mutableCopy];
    DDLogDebug(@"getRecentGifs: %@",recentGifs);
    recentGifs = [self populateEboticonGifArrayFromFileNames:recentGifs];
    
    return recentGifs;
}

-(NSMutableArray*) populateEboticonGifArrayFromFileNames:(NSMutableArray *) filenames
{
    NSMutableArray* arrayEboticonGifs = [[NSMutableArray alloc]init];
    
    if([filenames count]>0){
        for (int i =0; i<[filenames count]; i++){
            for (int j=0; j<[_eboticonGifs count]; j++){
                if ([[filenames objectAtIndex:i] isEqualToString:[[_eboticonGifs objectAtIndex:j] fileName]]){
                    if(!arrayEboticonGifs){
                        arrayEboticonGifs = [@[[_eboticonGifs objectAtIndex:j]] mutableCopy];
                    } else {
                        [arrayEboticonGifs insertObject:[_eboticonGifs objectAtIndex:j] atIndex:0];
                    }
                }
                
            }
        }
        
    }
    
    return arrayEboticonGifs;
}



-(void) clearRecentGifs
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:RECENT_GIFS_KEY];
    self.recentImages = nil;
    DDLogInfo(@"Clear Recents");
    [self.collectionView reloadData];
    
}

#pragma mark-
#pragma mark In App Products


/*
 
 - (void)getProducts {
 DDLogInfo(@"Reloading Products...");
 _products = nil;
 [[EboticonIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
 if (success) {
 _products = products;
 }
 }];
 }
 
 */

//- (void)loadPurchasedProducts {
//    NSLog(@"loadPurchasedProducts...");
//
//    NSMutableSet *purchasedProducts = [[EboticonIAPHelper sharedInstance] getPurchasedProducts];
//
//    NSLog(@"loading in sharedDefaults...");
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
//    [sharedDefaults setObject:[purchasedProducts allObjects] forKey:@"purchasedProducts"];
//    [sharedDefaults synchronize];   // (!!) This is crucial.
//
//    for(NSString* productIdentifiers in purchasedProducts) {
//        NSLog(@"loadPurchasedGifsFromCSV: %@", productIdentifiers);
//    //    [self loadPurchasedGifsFromCSV:productIdentifiers];
//    }
//
//}


- (void) getPurchaseGifs
{
    [Webservice loadEboticonsWithEndpoint:@"purchased/published" completion:^(NSArray<EboticonGif *> *eboticons) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *purchaseEboticons = [[NSArray alloc]initWithArray:eboticons];
            NSMutableSet *purchasedProducts = [[EboticonIAPHelper sharedInstance] getPurchasedProducts];
            
            NSLog(@"getPurchaseGifs: loading in sharedDefaults...");
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
            [sharedDefaults setObject:[purchasedProducts allObjects] forKey:@"purchasedProducts"];
            [sharedDefaults synchronize];   // (!!) This is crucial.
            
            //Get Purchased Images
            for(NSString* productIdentifiers in purchasedProducts) {
                for (EboticonGif *eboticon in purchaseEboticons) {
                    
                    NSString * skinTone = [eboticon skinTone];           //Skin
                    
                    if([skinTone isEqual:self.savedSkinTone]){
                        if ([productIdentifiers isEqualToString:eboticon.purchaseCategory]) {
                            [_purchasedImages addObject:eboticon];
                           // [_eboticonGifs addObject:eboticon];
                        }
                    }
                    
                   
                }
            }
            
            // Get
            for (EboticonGif *eboticon in purchaseEboticons) {
                
                NSString * skinTone = [eboticon skinTone];           //Skin
                
                
                if([skinTone isEqual:self.savedSkinTone]){
                    //[_purchasedImages addObject:eboticon];
                    [_eboticonGifs addObject:eboticon];
                }
            }
            
            [self.collectionView reloadData];
            
        });
    }];
}



#pragma mark -

-(UIImage *) getCellImage: (long)row
{
    UIImage *image;
    //Load Gifs depending on caption
    if ([_captionState integerValue]) {
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            image = [UIImage imageNamed:_captionImages[row]];
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            image = [UIImage imageNamed:_noCaptionImages[row]];
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            image = [UIImage imageNamed:_recentImages[row]];
        }else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            image = [UIImage imageNamed:_purchasedImages[row]];
        }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            image = [UIImage imageNamed:_smileImagesCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            image = [UIImage imageNamed:_nosmileImagesCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            image = [UIImage imageNamed:_heartImagesCaption[row]];
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            DDLogDebug(@"Returning Gift");
            image = [UIImage imageNamed:_giftImagesCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            image = [UIImage imageNamed:_exclamationImagesCaption[row]];
        }
        else {
            image = [UIImage imageNamed:_captionImages[row]];
        }
    }
    else{
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            image = [UIImage imageNamed:_captionImages[row]];
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            image = [UIImage imageNamed:_noCaptionImages[row]];
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            image = [UIImage imageNamed:_recentImages[row]];
        }else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            image = [UIImage imageNamed:_purchasedImages[row]];
        }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            image = [UIImage imageNamed:_smileImagesNoCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            image = [UIImage imageNamed:_nosmileImagesNoCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            image = [UIImage imageNamed:_heartImagesNoCaption[row]];
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            DDLogDebug(@"Returning Gift");
            image = [UIImage imageNamed:_giftImagesNoCaption[row]];
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            image = [UIImage imageNamed:_exclamationImagesNoCaption[row]];
        }
        else {
            image = [UIImage imageNamed:_noCaptionImages[row]];
        }
        
    }
    return image;
}

-(NSString *) getImageName: (long)row
{
    NSString *gifName;
    
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        gifName = _captionImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        gifName = _noCaptionImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        gifName = _recentImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
        gifName = _purchasedImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    } else {
        gifName = _allImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    }
    
    return gifName;
}

-(EboticonGif *) getCurrentEboticonGif: (long)row
{
    EboticonGif *currentGifObject = [[EboticonGif alloc]init];
    
    
    //Load Gifs depending on caption
    if ([_captionState integerValue]) {
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            currentGifObject = _captionImages[row];
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            currentGifObject = _noCaptionImages[row];
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            currentGifObject = _recentImages[row];
        }else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            currentGifObject = _purchasedImages[row];
        }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            //  NSLog(@"smile images");
            currentGifObject = _smileImagesCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            currentGifObject = _nosmileImagesCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            currentGifObject = _heartImagesCaption[row];
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            currentGifObject = _giftImagesCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            currentGifObject = _exclamationImagesCaption[row];
        }
        else {
            // NSLog(@"all images");
            currentGifObject = _captionImages[row];
        }
    }
    else{
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            currentGifObject = _captionImages[row];
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            currentGifObject = _noCaptionImages[row];
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            currentGifObject = _recentImages[row];
        }else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            //NSLog(@"%@",_gifCategory);
            currentGifObject = _purchasedImages[row];
        }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            //  NSLog(@"smile images");
            currentGifObject = _smileImagesNoCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            currentGifObject = _nosmileImagesNoCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            currentGifObject = _heartImagesNoCaption[row];
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            currentGifObject = _giftImagesNoCaption[row];
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            currentGifObject = _exclamationImagesNoCaption[row];
        }
        else {
            // NSLog(@"all images");
            currentGifObject = _noCaptionImages[row];
        }
    }
    
    
    return currentGifObject;
}

-(long) findFilenameIndex: (EboticonGif*) filename
{
    long index = -1;
    EboticonGif *test = [[EboticonGif alloc]init];
    
    for(int i = 0; i<[_eboticonGifs count]; i++){
        test = [_eboticonGifs objectAtIndex:i];
        if(nil != test && [test isEqual:filename]){
            DDLogDebug(@"Filename found: %@ Index is %d",[filename getFileName], i);
            index = i;
            break;
        }
    }
    return index;
}

- (NSString *)packName:(NSString *)purchaseCategory
{
    if([purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        return @"Greek Pack";
    }
    else if([purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        return @"Bae Pack";
    }
    else if([purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        return @"Greeting Pack";
    }
    else if([purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        return @"Church Pack";
    }
    else if([purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]){
        return @"Ratchet Pack";
    }
    else {
        return @"";
    }
}

- (SKProduct *)getProduct:(EboticonGif *)eboticon
{
    
    for (SKProduct *product in _products) {
        /*
         remove last letter of purhaseCategory and productIdentifier so both match as church1 != church2
         */
        NSString *productIdentifier = [product.productIdentifier substringToIndex:[product.productIdentifier length]-1];
        NSString *purchaseCategory = [eboticon.purchaseCategory substringToIndex:[eboticon.purchaseCategory length]-1];
        if ([productIdentifier isEqualToString:purchaseCategory]) {
            return product;
        }
    }
    return nil;
}

- (void)showUnlockView:(SKProduct *)product {
    UnlockView *unlockView = [[UnlockView alloc]initWithFrame:self.collectionView.frame];
    CGFloat boldTextFontSize = 17.0f;
    unlockView.descLabel.text = [NSString stringWithFormat:@"Unlock %@ to get these new emojis and stickers. It’s only $%.02f. Get it NOW!",product.localizedTitle, product.price.floatValue];
    NSRange range1 = [unlockView.descLabel.text rangeOfString:product.localizedTitle];
    NSRange range2 = [unlockView.descLabel.text rangeOfString:[NSString stringWithFormat:@"$%.02f", product.price.floatValue]];
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
    __weak MainViewController *weakSelf = self;
    [unlockView setUnlockButtonBlock:^{
        [weakUnlockView removeFromSuperview];
        ShopDetailCollectionViewController *shopDetailCollectionViewController =  [[ShopDetailCollectionViewController alloc] initWithNibName:@"ShopDetailView" bundle:nil];
        shopDetailCollectionViewController.product = product;
        shopDetailCollectionViewController.activateBuy = true;
        [[weakSelf navigationController] pushViewController:shopDetailCollectionViewController animated:YES];
    }];
    
    //Set Image
    if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"GreekPack"];
    }
    else if([product.productIdentifier   isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [product.productIdentifier   isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"BaePack"];
    }
    else if([product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"GreetingPack"];
    }
    else if([product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"ChurchPack"];
    }
    else if([product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [product.productIdentifier  isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]){
        unlockView.packImageView.image = [UIImage imageNamed:@"RatchetPack"];
    }
    else {
        unlockView.packImageView.image = [UIImage imageNamed:@"EboticonBundle"];
    }
    
    
    [self.view addSubview:unlockView];
}


#pragma mark -
#pragma mark ViewControllerDelegate




- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat imageHeight = self.view.bounds.size.height * 0.3;
    CGFloat halfway = self.view.bounds.size.height/2 - imageHeight;
    self.noConnectionImageView.frame = CGRectMake(0, halfway, self.view.bounds.size.width, imageHeight);
}


+ (MainViewController *)sharedInstance
{
    static dispatch_once_t once;
    static MainViewController *mainViewController;
    dispatch_once(&once, ^{
        mainViewController = [[MainViewController alloc] init];
    });
    return mainViewController;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    // [self loadEboticon];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    NSLog(@"In NumberofItemsinSection. gifCategory is %@",_gifCategory);
    NSLog(@"In Caption State:  %ld",(long)[_captionState integerValue]);
    if ([_captionState integerValue]) {
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            DDLogDebug(@"Returning Caption");
            return _captionImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            DDLogDebug(@"Returning No Caption");
            return _noCaptionImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            DDLogDebug(@"Returning No Caption");
            return _recentImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            return _purchasedImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            DDLogDebug(@"Returning Smile");
            return _smileImagesCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            DDLogDebug(@"Returning No Smile");
            return _nosmileImagesCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            DDLogDebug(@"Returning Heart");
            return _heartImagesCaption.count;
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            DDLogDebug(@"Returning Gift");
            return _giftImagesCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            DDLogDebug(@"Returning Exclamation");
            return _exclamationImagesCaption.count;
        }
        
    }
    else{
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            DDLogDebug(@"Returning Caption");
            return _captionImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            DDLogDebug(@"Returning No Caption");
            return _noCaptionImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            DDLogDebug(@"Returning No Caption");
            return _recentImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            DDLogDebug(@"Returning No Caption");
            return _purchasedImages.count;
        } else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            DDLogDebug(@"Returning Smile");
            return _smileImagesNoCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            DDLogDebug(@"Returning No Smile");
            return _nosmileImagesNoCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            DDLogDebug(@"Returning Heart");
            return _heartImagesNoCaption.count;
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            DDLogDebug(@"Returning Gift");
            return _giftImagesNoCaption.count;
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            DDLogDebug(@"Returning Exclamation");
            return _exclamationImagesNoCaption.count;
        }
        
        
        
    }
    
    if ([_captionState integerValue]) {
        NSLog(@"Caption Images:  %ld",(unsigned long)_captionImages.count);
        return _captionImages.count;
    }
    else{
        //        for(int i = 0; i < [_noCaptionImages count]; i++){
        //            NSLog(@"Gif %d: stillname:%@  category:%@", i, [[_noCaptionImages objectAtIndex:i] stillName],  [[_noCaptionImages objectAtIndex:i] category]);
        //        };
        
        NSLog(@"NoCaption Images:  %ld",(unsigned long)_noCaptionImages.count);
        return _noCaptionImages.count;
        
    }
    
    DDLogDebug(@"Returning All");
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    EboticonGifCell *gifCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    
    //rounded corners
    gifCell.layer.masksToBounds = YES;
    gifCell.layer.cornerRadius = 6;
    
    // TODO: Fix bug to from the cloud
    EboticonGif *eboticonGifName = [self getCurrentEboticonGif:[indexPath row]];
    [gifCell.gifImageView setAlpha:1];
    [gifCell setCellGif:eboticonGifName];
    
    if (![eboticonGifName.purchaseCategory isEqualToString:@""]) {
        if (![[EboticonIAPHelper sharedInstance] productPurchased:eboticonGifName.purchaseCategory]) {
            
            [[gifCell gifImageView] setAlpha:0.5];
        }
    }
    
    return gifCell;
}



#pragma mark -
#pragma mark UICollectionViewDelegate

-(void) collectionView:(UICollectionView *) collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.revealViewController wasAnimated]){
        FilterData *sharedFilterData = [FilterData sharedInstance];
        _captionState = sharedFilterData.captionState;
        [self.collectionView reloadData];
        [self reverseMenu:nil];
        return;
    }
    EboticonGif *eboticon = [self getCurrentEboticonGif:[indexPath row]];
    if (![eboticon.purchaseCategory isEqualToString:@""]) {
        if (![[EboticonIAPHelper sharedInstance] productPurchased:eboticon.purchaseCategory]) {
            SKProduct *product = [self getProduct:eboticon];
            if (product == nil) {
                return;
            }
            [self showUnlockView:product];
            return;
        }
    }
    
    NSMutableArray *imageNames;
    
    if ([_captionState integerValue]) {
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            imageNames = _captionImages;
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            imageNames = _noCaptionImages;
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            imageNames = _recentImages;
        } else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            imageNames = _purchasedImages;
        } else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            //  NSLog(@"smile images");
            imageNames = _smileImagesCaption;
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            imageNames = _nosmileImagesCaption;
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            imageNames = _heartImagesCaption;
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            imageNames = _giftImagesCaption;
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            imageNames = _exclamationImagesCaption;
        }else {
            _gifCategory = CATEGORY_CAPTION;
            imageNames = _captionImages;
        }
    }
    else{
        if([_gifCategory isEqual: CATEGORY_CAPTION]){
            imageNames = _captionImages;
        } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
            imageNames = _noCaptionImages;
        } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
            imageNames = _recentImages;
        }else if ([_gifCategory isEqual: CATEGORY_PURCHASED]){
            imageNames = _purchasedImages;
        }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
            //  NSLog(@"smile images");
            imageNames = _smileImagesNoCaption;
        } else if ([_gifCategory isEqual: CATEGORY_NOSMILE]){
            imageNames = _nosmileImagesNoCaption;
        } else if ([_gifCategory isEqual: CATEGORY_HEART]){
            imageNames = _heartImagesNoCaption;
        }else if ([_gifCategory isEqual: CATEGORY_GIFT]){
            imageNames = _giftImagesNoCaption;
        } else if ([_gifCategory isEqual: CATEGORY_EXCLAMATION]){
            imageNames = _exclamationImagesNoCaption;
        }else {
            _gifCategory = CATEGORY_NO_CAPTION;
            imageNames = _noCaptionImages;
        }
        
    }
    
    GifDetailViewController *gifDetailViewController =  [[GifDetailViewController alloc] initWithNibName:@"GifDetailView" bundle:nil];
    
    DDLogDebug(@"Row: %ld", (long)indexPath.row);
    DDLogDebug(@"Passing images count: %ld", (long)[imageNames count]);
    DDLogDebug(@"Category: %@", _gifCategory);
    
    
    gifDetailViewController.gifCategory = _gifCategory;
    gifDetailViewController.index = indexPath.row;
    gifDetailViewController.imageNames = imageNames;
    
    gifDetailViewController.imgBackground = [self captureView:self.view];
    [[self navigationController] pushViewController:gifDetailViewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(self.view.bounds.size.width/3 - 8, self.view.bounds.size.width/3 - 8);
    
}

- (UIImage*)captureView:(UIView *)view
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

@end
