//
//  KeyboardViewController.m
//  iOSKeyboardTemplate
//
//  Copyright (c) 2014 BJH Studios. All rights reserved.
//  questions or comments contact jeff@bjhstudios.com

#import <QuartzCore/QuartzCore.h>

#import "KeyboardViewController.h"
#import "KeyboardCollectionViewFlowLayout.h"
#import "KeyboardCell.h"
#import "UIView+Toast.h"
#import "CHCSVParser.h"
#import "ImageCache.h"

//
#import "EboticonGif.h"
#import "ImageDownloader.h"
#import "ImageCache.h"

#import "TTSwitch.h"

#import <DFImageManager/DFImageManagerKit.h>
#import "Reachability.h"
#import "EboticonIAPHelper.h"
#import "PackSectionHeaderCollectionReusableView.h"

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

@import Firebase;

#import "EboticonKeyboard-Swift.h"

@interface KeyboardViewController () {
    
    NSInteger _currentCategory;
    NSInteger _tappedImageCount;
    NSInteger _currentImageSelected;
    NSInteger _lastImageSelected;
    NSInteger _captionState;
    NSInteger _scrollSwipeState;
    NSInteger _currentNumberGifs;
    
    NSArray *_csvImages;
    
    NSMutableArray *_currentEboticonGifs;
    
    NSArray *_purchasedProducts;
    
    NSMutableArray *_allImages;
    NSMutableArray *_purchasedImages;
    NSMutableArray *_purchasedImagesCaption;
    NSMutableArray *_purchasedImagesNoCaption;
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
    NSMutableArray *_baeImagesNoCaption;
    NSMutableArray *_baeImagesCaption;
    NSMutableArray *_churchImagesNoCaption;
    NSMutableArray *_churchImagesCaption;
    NSMutableArray *_greekImagesNoCaption;
    NSMutableArray *_greekImagesCaption;
    NSMutableArray *_greetingImagesNoCaption;
    NSMutableArray *_greetingImagesCaption;
    NSMutableArray *_ratchetImagesNoCaption;
    NSMutableArray *_ratchetImagesCaption;
    NSMutableArray *_freePack;
    
    int _shiftStatus; //0 = off, 1 = on, 2 = caps lock
    
    UICollectionView *_collectionView;
    
}

//Gesture Responders
- (void)respondToSwipeRightGesture:(UISwipeGestureRecognizer *)sender;
- (void)respondToSwipeLeftGesture:(UISwipeGestureRecognizer *)sender;

// Reachability
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;


// Categories
@property (weak, nonatomic) IBOutlet UIButton *globeKey;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIButton *smileButton;
@property (weak, nonatomic) IBOutlet UIButton *noSmileButton;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;
@property (weak, nonatomic) IBOutlet UIButton *exclamationButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *purchasedButton;
@property (weak, nonatomic) IBOutlet UIButton *keypadButton;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIImageView *packImageView;

//keyboard rows
@property (nonatomic, weak) IBOutlet UIView *numbersRow1View;
@property (nonatomic, weak) IBOutlet UIView *numbersRow2View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow1View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow2View;
@property (nonatomic, weak) IBOutlet UIView *numbersSymbolsRow3View;

//keys
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *letterButtonsArray;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow3Button;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow4Button;
@property (nonatomic, weak) IBOutlet UIButton *shiftButton;
@property (nonatomic, weak) IBOutlet UIButton *spaceButton;
@property (strong, nonatomic) IBOutlet UIButton *unlockButton;

// Collection View
@property (nonatomic, nonatomic) IBOutlet UICollectionView *keyboardCollectionView;
//@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

//keypad
@property (nonatomic, weak) IBOutlet UIView *keypadView;

// No connection
@property (nonatomic, nonatomic) UIImageView *noConnectionImageView;

//Bottom border
@property (nonatomic, nonatomic) UIView *bottomBorder;

//Caption Button
@property (weak, nonatomic) IBOutlet UIImageView *topBarView;

//Keyboard View
@property (weak, nonatomic) IBOutlet UIView *keyboardView;

//Caption Switch
@property (strong, nonatomic) IBOutlet TTSwitch *captionSwitch;
@property (strong, nonatomic) IBOutlet UIView *unlockViewContainer;

//Caption Switch
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

//Top Bar Buttons
@property (strong, nonatomic) UIButton *storeButton;
@property (strong, nonatomic) UIButton *facebookButton;

//Indicator
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

//States
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) BOOL isKeypadOn;
@property (nonatomic, assign) BOOL isFacebookButtonOn;
@property (nonatomic, assign) BOOL showSection;

@property (nonatomic, strong) EboticonGif *selectedEboticon;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _showSection == NO;
    NSLog(@"Keyboard Started 1");
    //Initialize Firebase Analytics
    [FirebaseConfigurator sharedInstance];
    //NSString *string = [[FirebaseConfigurator sharedInstance] test];
    //NSLog(@"%@", string);
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    //Initialize Extension
    [self initializeExtension];
    
    //Contifgure Top Bar
    [self createTopBar];
    
    //Create Connection Png
    [self createNoConnectionPng];
    
    //Activity Indicator
    [self createActivityIndicator];
    
    //Create Caption Switch
    [self createCaptionSwitch];
    
    //Initialize initialize Collection View
    [self createCollectionView];
    
    //Initialize Keypad
    [self initializeKeypad];
    [self createStoreAndFacebookButton];
    
    // UISwipeGestureRecognizerDirectionLeft
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeLeftGesture:)];
    leftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    leftRecognizer.numberOfTouchesRequired = 1;
    leftRecognizer.delegate = self;
    [self.view addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRightGesture:)];
    rightRecognizer.direction=UISwipeGestureRecognizerDirectionRight;
    rightRecognizer.numberOfTouchesRequired = 1;
    rightRecognizer.delegate = self;
    [self.view addGestureRecognizer:rightRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated{
    _unlockButton.layer.cornerRadius = 5;
}



- (void) createCollectionView {
    
    NSLog(@"createCollectionView width:%f, height:%f", self.view.frame.size.width,  self.view.frame.size.height);
    UICollectionViewFlowLayout *layout=[[KeyboardCollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    //Register the Gif Cell
    [_collectionView registerNib:[UINib nibWithNibName:@"KeyboardCell" bundle:nil] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"PackSectionHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PackSectionHeaderCollectionReusableView"];
    
    [self.view addSubview:_collectionView];
    
    //Register the Gif Cell
   // [_collectionView registerNib:[UINib nibWithNibName:@"EboticonGifCell" bundle:nil] forCellWithReuseIdentifier:@"AnimatedGifCell"];
    
    //Add background image
    //self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Ebo_Background.png"]];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = false;
    
    [_collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0.0f].active = YES;
    [_collectionView.topAnchor constraintEqualToAnchor: self.topBarView.bottomAnchor].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor: self.toolbar.topAnchor].active = YES;
    [_collectionView.heightAnchor constraintEqualToConstant:self.view.frame.size.height/2-self.toolbar.frame.size.height-self.toolbar.frame.size.height].active = YES;

  //  [_collectionView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
  //  [_collectionView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
  //  [_collectionView.widthAnchor constraintEqualToConstant:self.view.frame.size.width].active = YES;

}


- (void)createTopBar {
    
    //Add bottom border
    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self. self.topBarView.frame.size.height - 1.0f, self. self.topBarView.frame.size.width, 1)];
    self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.2f];
    [self.topBarView addSubview:self.bottomBorder];
    
}


- (void)createNoConnectionPng {
    
    //Show no connection png
    self.noConnectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    self.noConnectionImageView .image = [UIImage imageNamed:@"no_connection.png"];
    self.noConnectionImageView.hidden = YES;
    [self.view addSubview:self.noConnectionImageView ];
    
}


- (void)createActivityIndicator
{
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0);        //Change size
    [self.view addSubview: self.activityIndicator];
}

//- (id)initWithAttributes:(NSString *)fileName displayName:(NSString *)displayName stillName:(NSString *)stillName category:(NSString *)category movFileName:(NSString *)movFileName displayType:(NSString *)displayType emotionCategory:(NSString *)emotionCategory;
- (void)createCaptionSwitch
{
    //Caption Switch
    //The switch size should be the size of the overlay.
    self.captionSwitch = [[TTSwitch alloc] initWithFrame:(CGRect){ 5.0f, 2.0f, 100.0f, 20.0f }];
    //self.captionSwitch = [[TTSwitch alloc] initWithFrame:(CGRect){ _collectionView.frame.size.width/2.0f-50.0f, 2.0f, 100.0f, 20.0f }];
    [[TTSwitch appearance] setTrackImage:[UIImage imageNamed:@"round-switch-track"]];
    [[TTSwitch appearance] setOverlayImage:[UIImage imageNamed:@"round-switch-overlay"]];
    [[TTSwitch appearance] setTrackMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [[TTSwitch appearance] setThumbImage:[UIImage imageNamed:@"round-switch-thumb"]];
    [[TTSwitch appearance] setThumbHighlightImage:[UIImage imageNamed:@"round-switch-thumb-highlight"]];
    [[TTSwitch appearance] setThumbMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [[TTSwitch appearance] setThumbInsetX:-6.0f];
    [[TTSwitch appearance] setThumbOffsetY:-6.0f];
    [self.captionSwitch addTarget:self action:@selector(changeCaptionSwitch:) forControlEvents:UIControlEventValueChanged];
    self.captionSwitch.on = true;
    [self.view addSubview: self.captionSwitch];
}

- (void)createStoreAndFacebookButton
{
    self.storeButton = [[UIButton alloc]init];
    [self.storeButton setImage:[UIImage imageNamed:@"Cart-Icon-Highlighted"] forState:UIControlStateNormal];
    [self.storeButton addTarget:self action:@selector(openStore:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.storeButton];
    
    self.facebookButton = [[UIButton alloc] init];
    [self.facebookButton setImage:[UIImage imageNamed:@"FB-Icon-UnHighlighted"] forState:UIControlStateNormal];
    [self.facebookButton setImage:[UIImage imageNamed:@"FB-Icon-Highlighted"] forState:UIControlStateSelected];
    [self.facebookButton addTarget:self action:@selector(toggleFacebookUpdate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.facebookButton];
    
    self.storeButton.translatesAutoresizingMaskIntoConstraints = false;
    self.facebookButton.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.facebookButton.leadingAnchor constraintEqualToAnchor:self.captionSwitch.trailingAnchor constant:5.0f].active = YES;
    [self.facebookButton.centerYAnchor constraintEqualToAnchor:self.captionSwitch.centerYAnchor].active = YES;
    [self.facebookButton.heightAnchor constraintEqualToAnchor:self.captionSwitch.heightAnchor].active = YES;
    [self.facebookButton.widthAnchor constraintEqualToAnchor:self.captionSwitch.heightAnchor].active = YES;
    
    [self.storeButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10.0f].active = YES;
    [self.storeButton.centerYAnchor constraintEqualToAnchor:self.captionSwitch.centerYAnchor].active = YES;
    [self.storeButton.heightAnchor constraintEqualToAnchor:self.captionSwitch.heightAnchor].active = YES;
    [self.storeButton.widthAnchor constraintEqualToAnchor:self.captionSwitch.heightAnchor].active = YES;
}

- (void)toggleFacebookUpdate:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.isFacebookButtonOn = sender.selected;
}

- (void)openStore:(UIButton *)sender
{
    NSURL *google = [NSURL URLWithString:@"eboticon://cart_page"];
    [self openURL:google];
    
}

-(void)openURL:(NSURL*)url{
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        NSLog(@"responder = %@", responder);
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:)
                            withObject:url];
        }
    }
}


//When a view's bounds change, the view adjusts the position of its subviews. Your view controller can override this method to make changes before the view lays out its subviews. The default implementation of this method does nothing.

#pragma mark
#pragma mark - initialization method


- (void) initFirebaseAnalytics {
    
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    
}

- (void) initializeExtension {
    
    // Set the number of pages to the number of pages in the paged interface
    // and let the height flex so that it sits nicely in its frame
    //self.pageControl.numberOfPages = 1;
    
    //Initialize Gifs
    _currentEboticonGifs         = [[NSMutableArray alloc] init];
    _allImages                   = [[NSMutableArray alloc] init];
    _purchasedImages             = [[NSMutableArray alloc] init];
    _purchasedImagesCaption      = [[NSMutableArray alloc] init];
    _purchasedImagesNoCaption    = [[NSMutableArray alloc] init];
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
    _baeImagesCaption            = [[NSMutableArray alloc] init];
    _baeImagesNoCaption          = [[NSMutableArray alloc] init];
    _churchImagesCaption         = [[NSMutableArray alloc] init];
    _churchImagesNoCaption       = [[NSMutableArray alloc] init];
    _greekImagesCaption          = [[NSMutableArray alloc] init];
    _greekImagesNoCaption        = [[NSMutableArray alloc] init];
    _greetingImagesCaption       = [[NSMutableArray alloc] init];
    _greetingImagesNoCaption     = [[NSMutableArray alloc] init];
    _ratchetImagesCaption        = [[NSMutableArray alloc] init];
    _ratchetImagesNoCaption      = [[NSMutableArray alloc] init];
    
    //Intialize current tapped image
    _tappedImageCount       = 0;
    _currentImageSelected   = 0;
    _lastImageSelected      = 0;
    _captionState           = 1;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    
    
    
    
    //Load CSV into Array
    [self loadGifs];
    
    //Load CSV into Array
//    [self getPurchaseGifs];
    
    //Setup item size of keyboard layout to fit keyboard.
    //[self changeKeyboardFlowLayout];
    
    //    [self populateGifArrays];
    
    if([self doesInternetExists]){
        //Convert CSV to an array
        //        self. self.captionSwitch.hidden = NO;
        //        self.pageControl.hidden = NO;
        //        [self populateGifArrays];
        
    }
    else{
        //add Internet connection view and remove caption button
        //        self.noConnectionImageView.hidden = NO;
        //        self.captionSwitch.hidden = YES;
        //        self.pageControl.hidden = YES;
    }
    
    // Create and initialize a swipe right gesture
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRightGesture:)];
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizerRight.numberOfTouchesRequired = 1;
    [_collectionView addGestureRecognizer:swipeRecognizerRight];
    
    
    // Create and initialize a swipe right gesture
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeLeftGesture:)];
    swipeRecognizerLeft.direction =  UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizerLeft.numberOfTouchesRequired = 1;
    [_collectionView addGestureRecognizer:swipeRecognizerLeft];
    
    
}


- (void)loadEboticonFromServer
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0f, [[UIScreen mainScreen] bounds].size.height/2.0f-100);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[[Webservice alloc] init] loadEboticonsWithEndpoint:@"eboticons/published" onlyFreeOnce:YES completion:^(NSArray<EboticonGif *> *eboticons) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"######## %@",eboticons );
            [_allImages addObjectsFromArray:eboticons];
            [self populateGifArrays];
            [spinner stopAnimating];
            [self getPurchasedGif];
        });
        
    }];
}

- (void)getPurchasedGif
{
    [[[Webservice alloc] init] loadEboticonsWithEndpoint:@"eboticons/published" onlyFreeOnce:NO completion:^(NSArray<EboticonGif *> *eboticons) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self populateAllSection:eboticons];
        });
        
    }];
}

- (void) populateAllSection:(NSArray *)eboticons
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    NSString *savedSkinTone = [defaults stringForKey:@"skin_tone"];
    
    for (EboticonGif *eboticon in eboticons) {
        if ([savedSkinTone isEqualToString:eboticon.skinTone]) {
            if ([self productPurchased:eboticon.purchaseCategory]) {
                [_allImages addObject:eboticon];
            }
            if ([KeyboardHelper isBaePack:eboticon]) {
                
                if ([eboticon.category isEqualToString:CATEGORY_CAPTION]) {
                     [_baeImagesCaption addObject:eboticon];
                } else {
                     [_baeImagesNoCaption addObject:eboticon];
                }
            } else if([KeyboardHelper isChurchPack:eboticon]) {
                if ([eboticon.category isEqualToString:CATEGORY_CAPTION]) {
                    [_churchImagesCaption addObject:eboticon];
                } else {
                     [_churchImagesNoCaption addObject:eboticon];
                }
            } else if ([KeyboardHelper isGreekPack:eboticon]) {
                if ([eboticon.category isEqualToString:CATEGORY_CAPTION]) {
                    [_greekImagesCaption addObject:eboticon];
                } else {
                    [_greekImagesNoCaption addObject:eboticon];
                }
            } else if([KeyboardHelper isGreetingPack:eboticon]){
                if ([eboticon.category isEqualToString:CATEGORY_CAPTION]) {
                    [_greetingImagesCaption addObject:eboticon];
                } else {
                    [_greetingImagesNoCaption addObject:eboticon];
                }
            } else if ([KeyboardHelper isRatchetPack:eboticon]) {
                if ([eboticon.category isEqualToString:CATEGORY_CAPTION]) {
                    [_ratchetImagesCaption addObject:eboticon];
                } else {
                    [_ratchetImagesNoCaption addObject:eboticon];
                }
            }
        }
    }
    [self populateGifArrays];
    [_purchasedImagesNoCaption addObject:_baeImagesNoCaption];
    [_purchasedImagesNoCaption addObject:_churchImagesNoCaption];
    [_purchasedImagesNoCaption addObject:_greekImagesNoCaption];
    [_purchasedImagesNoCaption addObject:_greetingImagesNoCaption];
    [_purchasedImagesNoCaption addObject:_ratchetImagesNoCaption];
    
    [_purchasedImagesCaption addObject:_baeImagesCaption];
    [_purchasedImagesCaption addObject:_churchImagesCaption];
    [_purchasedImagesCaption addObject:_greekImagesCaption];
    [_purchasedImagesCaption addObject:_greetingImagesCaption];
    [_purchasedImagesCaption addObject:_ratchetImagesCaption];
}

- (void) loadGifs
{
    
    [_allImages removeAllObjects];
    [_purchasedImages removeAllObjects];
    [_purchasedImagesCaption removeAllObjects];
    [_purchasedImagesNoCaption removeAllObjects];
    [_exclamationImagesCaption removeAllObjects];
    [_exclamationImagesNoCaption removeAllObjects];
    [_smileImagesCaption removeAllObjects];
    [_smileImagesNoCaption removeAllObjects];
    [_nosmileImagesCaption removeAllObjects];
    [_nosmileImagesNoCaption removeAllObjects];
    [_giftImagesCaption removeAllObjects];
    [_giftImagesNoCaption removeAllObjects];
    [_heartImagesCaption removeAllObjects];
    [_heartImagesNoCaption removeAllObjects];
    
    //Set Gifs is no internet exists
    if([self doesInternetExists]){
        [self loadEboticonFromServer];
    }
    else{
        _showSection = NO;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_nointernet_gifs" ofType:@"csv"];
        
        NSError *error = nil;
        
        //Read All Gifs From CSV
        @try {
            NSArray * csvImages = [NSArray arrayWithContentsOfCSVFile:path];
            
            if (csvImages == nil) {
                NSLog(@"Error parsing file: %@", error);
                return;
            }
            else {
                
                
                // Prepare the array for processing in LazyLoadVC. Add each URL into a separate ImageRecord object and store it in the array.
                for (int cnt=0; cnt<[csvImages count]; cnt++)
                {
                    EboticonGif *eboticonObject = [[EboticonGif alloc] init];
                    
                    eboticonObject.fileName = [[csvImages objectAtIndex:cnt] objectAtIndex:0];
                    eboticonObject.stillName = [[csvImages objectAtIndex:cnt] objectAtIndex:1];
                    eboticonObject.displayName = [[csvImages objectAtIndex:cnt] objectAtIndex:2];
                    eboticonObject.category = [[csvImages objectAtIndex:cnt] objectAtIndex:3];         //Caption or No Cation
                    eboticonObject.emotionCategory = [[csvImages objectAtIndex:cnt] objectAtIndex:6];
                    eboticonObject.stillUrl        = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/%@", [[csvImages objectAtIndex:cnt] objectAtIndex:1]];
                    eboticonObject.gifUrl          = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/%@", [[csvImages objectAtIndex:cnt] objectAtIndex:0]];
                    
                    [_allImages addObject:eboticonObject];
                    [self populateGifArrays];
                }
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to load csv: %@",exception);
        }
    }
    
}

-(void) populateGifArrays
{
    if([_allImages count] > 0){
        
        EboticonGif *currentGif = [[EboticonGif alloc]init];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
        NSString *savedSkinTone = [defaults stringForKey:@"skin_tone"];
        [_smileImagesCaption removeAllObjects];
        [_smileImagesNoCaption removeAllObjects];
        [_nosmileImagesCaption removeAllObjects];
        [_nosmileImagesNoCaption removeAllObjects];
        
        [_heartImagesCaption removeAllObjects];
        [_heartImagesNoCaption removeAllObjects];
        
        [_giftImagesCaption removeAllObjects];
        [_giftImagesNoCaption removeAllObjects];
        [_exclamationImagesCaption removeAllObjects];
        [_exclamationImagesNoCaption removeAllObjects];
        for(int i = 0; i < [_allImages count]; i++){
            currentGif = [_allImages objectAtIndex:i];
            
            NSString * gifCategory = currentGif.emotionCategory; //Category
            NSString * gifCaption = currentGif.category;
            NSString * gifFileName = currentGif.fileName;
            
            NSString * skinTone = [currentGif skinTone];           //Skin
            
            
            if([skinTone isEqual:savedSkinTone]){
                
                //NSLog(@"Eboticon %@ with category:%@ and caption: %@",gifFileName,gifCategory, gifCaption);
                
                if([gifCategory isEqual:CATEGORY_SMILE]) {
                    //  NSLog(@"Adding eboticon to category CATEGORY_SMILE:%@",[currentGif fileName]);
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_smileImagesCaption addObject:[_allImages objectAtIndex:i]];
                    else{
                        [_smileImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                    }
                    
                } else if([gifCategory isEqual:CATEGORY_NOSMILE]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_nosmileImagesCaption addObject:[_allImages objectAtIndex:i]];
                    else{
                        [_nosmileImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                    }
                    
                }
                else if([gifCategory isEqual:CATEGORY_HEART]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_heartImagesCaption addObject:[_allImages objectAtIndex:i]];
                    else{
                        [_heartImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                    }
                    
                    
                    
                }
                else if([gifCategory isEqual:CATEGORY_GIFT]) {
                    
                    //Check for Caption
                    if ([gifCaption isEqual:@"Caption"])
                        [_giftImagesCaption addObject:[_allImages objectAtIndex:i]];
                    else{
                        [_giftImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                    }
                    
                    
                }
                else if([gifCategory isEqual:CATEGORY_EXCLAMATION]) {
                    
                    
                    if ([gifCaption isEqual:@"Caption"])
                        [_exclamationImagesCaption addObject:[_allImages objectAtIndex:i]];
                    else{
                        [_exclamationImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                    }
                    
                    
                }
                else {
                    NSLog(@"Eboticon category not recognized for eboticon: %@ with category:%@",gifFileName,gifCategory);
                }
            }
        }//End for
        
        
        //Print Counts
        // NSLog(@"smile images caption: %lu", (unsigned long)_smileImagesCaption.count);
        // NSLog(@"heart images no caption: %lu", (unsigned long)_smileImagesNoCaption.count);
        //NSLog(@"heart images caption: %lu", (unsigned long)_heartImagesCaption.count);
        // NSLog(@"heart images no caption: %lu", (unsigned long)_heartImagesNoCaption.count);
        
        //Set currnet gifs
        _currentEboticonGifs = _smileImagesCaption;
        [self changeCategory:1];
        
        [_collectionView reloadData];       //Relaod the images into view
        
     //   [self changeKeyboardFlowLayout];                //Change flowlayout
        
        
    } else {
        NSLog(@"Eboticon Gif array count is less than zero.");
    }
    
}







#pragma mark-
#pragma mark Reachability

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus internetStatus = [self.internetReachability currentReachabilityStatus];
    //NSLog(@"Network status: %li", (long)internetStatus);
    
    if (internetStatus != NotReachable) {
        
        // NSLog(@"Internet connection exists");
        self.noConnectionImageView.hidden = YES;
        self. self.captionSwitch.hidden = NO;
        self.storeButton.hidden = NO;
        self.facebookButton.hidden = NO;
        
        
        //Load CSV into Array
        [self loadGifs];
        
        //Populate Gifs
        [self populateGifArrays];
        
        //Reload keyboard data
        [_collectionView reloadData];
        
    }
    else {
        
        //Load CSV into Array
        [self loadGifs];
        
        //        [self populateGifArrays];
        
        
        //there-is-no-connection warning
        //NSLog(@"NO Internet connection exists");
        //Set Image View
        //        self.noConnectionImageView.frame = CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height-44);
        //        self.noConnectionImageView.hidden = NO;
        //        self. self.captionSwitch.hidden = YES;
        //        self.pageControl.hidden = YES;
        
        
        // Make toast with an image
        [self.view makeToast:@"Please turn on internet for full access."
                    duration:3.0
                    position:CSToastPositionCenter
         ];
        
        //Reload keyboard data
        //        [_collectionView reloadData];
        //        [self changePageControlNum];
    }
    
}

- (BOOL) doesInternetExists {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        //   NSLog(@"Internet connection exists");
        return YES;
    }
    else {
        //there-is-no-connection warning
        //  NSLog(@"NO Internet connection exists");
        return NO;
    }
}


//
- (BOOL) isRequestsOpenAccessEnabled {
    
    if([UIPasteboard generalPasteboard]){
        return YES;
    }
    else{
        return NO;
    }
    
}

#pragma mark - Key methods


- (void)changeCaptionSwitch:(id)sender{
    if([sender isOn]){
        // Execute any code when the switch is ON
        // NSLog(@"Switch is ON");
        _captionState = 1;
    } else{
        // Execute any code when the switch is OFF
        //NSLog(@"Switch is OFF");
        _captionState = 0;
    }
    
    
    //Load the Gifs
    switch (_currentCategory) {
            
        case 1: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _smileImagesCaption;
            }
            else{
                _currentEboticonGifs = _smileImagesNoCaption;
            }
            
        }
            break;
            //No Smile
        case 2: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _nosmileImagesCaption;
            }
            else{
                _currentEboticonGifs = _nosmileImagesNoCaption;
            }
            
            
        }
            break;
            //Gift
        case 3: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _giftImagesCaption;
            }
            else{
                _currentEboticonGifs = _giftImagesNoCaption;
            }
            
            
            
        }
            break;
            //Exclamation
        case 4: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _exclamationImagesCaption;
            }
            else{
                _currentEboticonGifs = _exclamationImagesNoCaption;
            }
            
        }
            break;
            
            //Heart
        case 5: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _heartImagesCaption;
            }
            else{
                _currentEboticonGifs = _heartImagesNoCaption;
            }
            
        }
            break;
            
            //Purchased
            
        case 6: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _purchasedImagesCaption;
            }
            else{
                _currentEboticonGifs = _purchasedImagesNoCaption;
            }
            
        }
            break;
            
            //Return or Globe
        default:
            break;
    }
    
    //Reload keyboard data
    [_collectionView reloadData];
    
}

- (IBAction) globeKeyPressed:(UIButton*)sender {
    
    //switches to user's next keyboard
    [self advanceToNextInputMode];
}

- (IBAction) backKeyPressed:(UIButton*)sender {
    
    //switches to user's next keyboard
    [self.textDocumentProxy deleteBackward];
}

- (IBAction) categoryKeyPressed:(UIButton*)sender {
    
    //switches to user's next category
    //NSLog(@"Category %ld Pressed", (long)sender.tag);
    //Change category
    _showSection = NO;
    [self changeCategory:sender.tag];
     [_unlockViewContainer setAlpha:0];
    
}

-(IBAction) purchasedKeyPressed: (UIButton*) sender {
    _showSection = YES;
    [self changeCategory:sender.tag];
}


- (void) changeCategory: (NSInteger)tag{
    
    //Show Toast
    if(![self doesInternetExists]){
        // Make toast with an image
        [self.view makeToast:@"Please turn on internet for full access."
                    duration:3.0
                    position:CSToastPositionCenter
         ];
    }
    
    
    //Make sure nothing is animated
    _currentCategory = tag;
    _tappedImageCount = 0;
    _currentImageSelected = 0;
    
    //Make sure keypad is hidden
    _collectionView.hidden = NO;
    self.captionSwitch.hidden = NO;
    self.storeButton.hidden = NO;
    self.facebookButton.hidden = NO;
    self.topBarView.hidden = NO;
    self.keypadView.hidden = YES;
    self.isKeypadOn = false;
    self.isFacebookButtonOn = NO;
    
    //Change the toolbar
    //NSLog(@"tag: %ld", (long)tag);
    switch (tag) {
            
            
            //Smile
        case 1: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HLHappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
//            [self sortDataBasedOn:_captionState == 1 andCategory:CATEGORY_SMILE];
            if (_captionState) {
                _currentEboticonGifs = _smileImagesCaption;
            }
            else{
                _currentEboticonGifs = _smileImagesNoCaption;
            }
            
        }
            break;
            //No Smile
        case 2: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"HLNotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
//            [self sortDataBasedOn:_captionState == 1 andCategory:CATEGORY_NOSMILE];
            if (_captionState) {
                _currentEboticonGifs = _nosmileImagesCaption;
            }
            else{
                _currentEboticonGifs = _nosmileImagesNoCaption;
            }
            
            
        }
            break;
            //Gift
        case 3: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"HLGiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
//            [self sortDataBasedOn:_captionState == 1 andCategory:CATEGORY_GIFT];
            if (_captionState) {
                _currentEboticonGifs = _giftImagesCaption;
            }
            else{
                _currentEboticonGifs = _giftImagesNoCaption;
            }
            
            
            
        }
            break;
            //Exclamation
        case 4: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"HLExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _exclamationImagesCaption;
            }
            else{
                _currentEboticonGifs = _exclamationImagesNoCaption;
            }
            
        }
            break;
            
            //Heart
        case 5: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HLHeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
//            [self sortDataBasedOn:_captionState == 1 andCategory:CATEGORY_HEART];
            if (_captionState) {
                _currentEboticonGifs = _heartImagesCaption;
            }
            else{
                _currentEboticonGifs = _heartImagesNoCaption;
            }
            
        }
            break;
            
        case 6: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.purchasedButton setImage:[UIImage imageNamed:@"HLPurchased.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _purchasedImagesCaption;
            }
            else{
                _currentEboticonGifs = _purchasedImagesNoCaption;
            }
            
        }
            break;
            
            //Return or Globe
        default:
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            [self.keypadButton setImage:[UIImage imageNamed:@"Keypad.png"] forState:UIControlStateNormal];
            break;
    }//end switch
    
    [_collectionView reloadData];
}


//- (void) changeKeyboardFlowLayout {
//    
//    // CGFloat pageWidth = _collectionView.frame.size.width;
//    CGFloat pageHeight = _collectionView.frame.size.height;
//    CGFloat newItemSizeHeight;
//    CGFloat newItemSizeWidth;
//    // UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.
//    
//    
//    //Check for Landscape or Portrait mode
//    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
//        //Keyboard is in Portrait
//        //NSLog(@"Portrait");
//        
//        //Create 5x2 grid
//        //newItemSizeWidth = floor(pageWidth/5) - 1;  //Hied
//        newItemSizeHeight = floor(pageHeight/2);
//        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
//        
//        
//    }
//    else{
//        //Keyboard is in Landscape
//        // NSLog(@"Landscape");
//        
//        //Create 9x2 grid
//        //newItemSizeWidth = floor(pageWidth/9) - 1;
//        newItemSizeHeight = floor(pageHeight/2);
//        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
//    }
//    
//    //NSLog(@"pageHeight %f", pageHeight);
//    //NSLog(@"pageWidth %f", pageWidth);
//    //NSLog(@"sectionInset top and bottom %f", sectionInset.top+sectionInset.bottom);
//    //NSLog(@"sectionInset top and bottom %f", sectionInset.left+sectionInset.right);
//    //    NSLog(@"newItemSizeHeight 1: %f", newItemSizeHeight);
//    //    NSLog(@"newItemSizeWidth  1: %f", newItemSizeWidth);
//    
//    //Create new item size
//    self.flowLayout.itemSize = CGSizeMake(newItemSizeWidth, newItemSizeHeight);
//    
//    
//}



/////////////////////////////////////
//   Scrollview Delegates
/////////////////////////////////////
#pragma mark - Scrollview Delegates
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (!decelerate)
        [self loadImagesForOnscreenRows];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
        //NSLog(@"%s", __PRETTY_FUNCTION__);

    [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
       // NSLog(@"%s", __PRETTY_FUNCTION__);


}

#pragma mark-
#pragma mark In App Products


- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateNumberLabelText];
}

- (void)updateNumberLabelText {
    //  NSLog(@"loading in keyboard sharedDefaults...");
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    _purchasedProducts = [defaults objectForKey:@"purchasedProducts"];
    //self.numberLabel.text = [NSString stringWithFormat:@"%d", number];
}
    
- (BOOL)productPurchased:(NSString *)productIdentifier
{
    
    //Get data from the app
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    NSArray *purchasedProducts = [defaults objectForKey:@"purchasedProducts"];
    for (NSString* identifier in purchasedProducts) {
        /*
         remove last letter of purhaseCategory and productIdentifier so both match as church1 != church2
         */
        if ([[identifier substringToIndex:[identifier length]-1] isEqualToString:[productIdentifier substringToIndex:[productIdentifier length]-1]]) {
            return true;
        }
    }
    return false;
}

- (NSString *)packName:(EboticonGif *)eboticon
{
    //Set Image
    if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        return @"Greek Pack";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        return @"Bae Pack";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        return @"Greeting Pack";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        return @"Church Pack";
    }
    else if ([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]) {
        return @"Ratchet Pack";
    }
    else {
        return @"";
    }
}

- (NSString *)packPrice:(EboticonGif *)eboticon
{
    //Set Image
    if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        return @"$1.99";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        return @"$0.99";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        return @"$0.99";
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        return @"$0.99";
    }
    else if ([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]) {
        return @"$0.99";
    }
    else {
        return @"";
    }
}

- (UIImage *)packSectionHeader:(EboticonGif *)eboticon
{
    //Set Image
    if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        return [UIImage imageNamed:@"GreekPackSectionHeader"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        return [UIImage imageNamed:@"BaePackSectionHeader"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        return [UIImage imageNamed:@"GreetingPackSectionHeader"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        return [UIImage imageNamed:@"ChurchPackSectionHeader"];
    }
    else if ([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]) {
        return [UIImage imageNamed:@"RatchPackSectionHeader"];
    }
    else {
        return nil;
    }
}

- (IBAction)closeUnlockView:(id)sender {
    [_unlockViewContainer setAlpha:0];
}
- (IBAction)unlock:(id)sender {
    [_unlockViewContainer setAlpha:0];
    NSURL *deeplink = [NSURL URLWithString:[NSString stringWithFormat:@"eboticon://cart_page/%@", self.selectedEboticon.purchaseCategory]];
    [self openURL:deeplink];
}


- (void)showUnlockView:(EboticonGif *)eboticon {
    self.selectedEboticon = eboticon;
    CGFloat boldTextFontSize = 17.0f;
    _descLabel.text = [NSString stringWithFormat:@"Unlock %@ to get these new emojis and stickers. It’s only %@. Get it NOW!",[self packName:eboticon], [self packPrice:eboticon]];
    NSRange range1 = [_descLabel.text rangeOfString:[self packName:eboticon]];
    NSRange range2 = [_descLabel.text rangeOfString:[self packPrice:eboticon]];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_descLabel.text];
    
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:boldTextFontSize]}
                            range:range1];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:boldTextFontSize]}
                            range:range2];
    
    _descLabel.attributedText = attributedText;
    [_unlockViewContainer setAlpha:1];
    
    //Set Image
    if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        _packImageView.image = [UIImage imageNamed:@"GreekPack"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.baepack2"]){
        _packImageView.image = [UIImage imageNamed:@"BaePack"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.greetingspack2"]){
        _packImageView.image = [UIImage imageNamed:@"GreetingPack"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        _packImageView.image = [UIImage imageNamed:@"ChurchPack"];
    }
    else if([eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack1"] || [eboticon.purchaseCategory isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]){
        _packImageView.image = [UIImage imageNamed:@"RatchetPack"];
    }
    else {
        _packImageView.image = [UIImage imageNamed:@"EboticonBundle"];
    }
    [self.view bringSubviewToFront:_unlockViewContainer];
}



#pragma mark-
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_showSection == YES) {
        return _currentEboticonGifs.count;
    }
    return 1;
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"Number of current gifs: %lu", (unsigned long)[_currentEboticonGifs count]);
    if (_showSection == YES) {
        return [[(NSArray *)_currentEboticonGifs objectAtIndex:section] count];
    }
    return  _currentEboticonGifs.count;;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
     NSLog(@" Loading row %lu", (long)indexPath.row) ;
     NSLog(@" Loading current count %lu", (unsigned long)[_currentEboticonGifs count]);
    
    KeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.imageView viewWithTag:505];
    
    // Set up the cell...
    // Fetch a image record from the array
    EboticonGif *currentGif = [[EboticonGif alloc]init];
    if (_showSection == YES) {
        currentGif = [[_currentEboticonGifs objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        currentGif = [_currentEboticonGifs objectAtIndex:indexPath.row];
    }

    [[cell imageView] setAlpha:1];
    if (![currentGif.purchaseCategory isEqualToString:@""]) {
        if (![self productPurchased:currentGif.purchaseCategory]) {
            [[cell imageView] setAlpha:0.5];
        }
    }
    
    NSLog(@" Loading still... %@", currentGif.stillUrl) ;
    NSLog(@" Loading gif... %@", currentGif.gifUrl) ;

    [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    
    
    if([self isRequestsOpenAccessEnabled]){
        
        //Load Gif File name
        if (_tappedImageCount == 1 && _currentImageSelected == indexPath.row){
            
            cell.imageView.image = [UIImage imageNamed:@"placeholder_loading.png"];
            
            
            //NSString * filePath= [[NSBundle mainBundle] pathForResource:currentGif.fileName ofType:@""];
            //NSLog(@"filePath: %@", filePath);
            
            if([self doesInternetExists]){
                [cell.imageView setImageWithResource:[NSURL URLWithString:currentGif.gifUrl]];
            }
            else{
                
                NSString *path=[[NSBundle mainBundle]pathForResource:currentGif.fileName ofType:@""];
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                [cell.imageView setImageWithResource:url];
            }
            
        }
        //Load Still Name
        else{
            


            // Check if the image exists in cache. If it does exists in cache, directly fetch it and display it in the cell
            if ([[ImageCache sharedImageCache] DoesExist:currentGif.stillUrl]== true)
            {
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                
                
                cell.imageView.image = [[ImageCache sharedImageCache] GetImage:currentGif.stillUrl];
                
                
            }
            // If it does not exist in cache, download it
            else
            {
                // Add activity indicator
                if (activityIndicator) [activityIndicator removeFromSuperview];
                activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.hidesWhenStopped = YES;
                activityIndicator.hidden = NO;
                [activityIndicator startAnimating];
                activityIndicator.center = cell.imageView.center;
                activityIndicator.tag = 505;
                [cell.imageView addSubview:activityIndicator];
                
                if([self doesInternetExists]){
                    
                    // Only load cached images; defer new downloads until scrolling ends
                    if (!currentGif.thumbImage)
                    {
                        if (_collectionView.dragging == NO && _collectionView.decelerating == NO)
                        {
                            [self startIconDownload:currentGif forIndexPath:indexPath];
                        }
                        // if a download is deferred or in progress, return a placeholder image
                        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
                    }
                    else
                    {
                        [activityIndicator stopAnimating];
                        [activityIndicator removeFromSuperview];
                        
                        cell.imageView.image = currentGif.thumbImage;
                        
                        
                    }
                }
                else{
                    [activityIndicator stopAnimating];
                    [activityIndicator removeFromSuperview];
                    
                    cell.imageView.image = [UIImage imageNamed:currentGif.stillName];
                }
                
                
                
            }
        }
    }
    else{
        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        //cell.imageView.image = [UIImage imageNamed:currentGif.stillName];
    }
    
    return cell;
}

//- (CGSize)_imageTargetSize {
//    CGSize size = ((UICollectionViewFlowLayout *)self.flowLayout).itemSize;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    return CGSizeMake(size.width * scale, size.height * scale);
//}



-(void) collectionView:(UICollectionView *) collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Button Tapped: %ld", (long)[indexPath row]);
    BOOL allowedOpenAccess = [self isRequestsOpenAccessEnabled]; // Can you allow access
    
    //Get current gif
    EboticonGif *currentGif = [[EboticonGif alloc]init];
    
    if (_showSection == YES) {
        currentGif = [[_currentEboticonGifs objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        currentGif = [_currentEboticonGifs objectAtIndex:indexPath.row];
    }
  
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    if (![currentGif.purchaseCategory isEqualToString:@""]) {
        if (![self productPurchased:currentGif.purchaseCategory]) {
            [self showUnlockView:currentGif];
            return;
        }
    }
    
    //First Tap
    if (_tappedImageCount == 0 && _currentImageSelected == indexPath.row && allowedOpenAccess){
        
        //        NSLog(@"Button Tapped once");
        //        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        //        NSLog(@"tap count %ld", (long)_tappedImageCount);
        //        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        
        
        //   NSLog(@"Button Tapped ");
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
        if([UIPasteboard generalPasteboard]){
            NSString * urlPath = currentGif.gifUrl;
            if (self.isFacebookButtonOn == YES) {
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                [pasteBoard setURL:[NSURL URLWithString:urlPath]];
                // Make toast with an image
                [self.view makeToast:@"Eboticon url copied!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            }else {
                if([self doesInternetExists]){
                    
                    
                    NSString * urlPath = currentGif.gifUrl;
                    
                    //   NSLog(@"urlPath: %@",urlPath);
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    //PARSE ANALYTICS
                    //                NSDictionary *dimensions = @{
                    //                                             @"category": @"eboticon_copied",
                    //                                             // Is it a weekday or the weekend?
                    //                                             @"eboji": currentGif.getFileName,
                    //                                             };
                    // Send the dimensions to Parse along with the 'read' event
                    
                    
                }
                else{
                    
                    NSString * filePath= [[NSBundle mainBundle] pathForResource:currentGif.fileName ofType:@""];
                    
                    //   NSLog(@"filePath: %@", filePath);
                    
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    // UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
                    // [pasteboard setImage:image];
                    
                }
                // Make toast with an image
                [self.view makeToast:@"Eboticon copied. Now paste it!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
                
            }
            
            
            
            
            //Send to Firebase
            [[FirebaseConfigurator sharedInstance] logEvent:currentGif.fileName];
            
            
            
        }
        else{
            
            // Make toast with an image
            [self.view makeToast:@"Please allow full access. Go to Settings->General->Keyboard->Eboticons->Allow full access"
                        duration:3.0
                        position:CSToastPositionCenter
             ];
            
        }
        
    }
    //Tapped different image
    else if (_tappedImageCount == 1 && _currentImageSelected != indexPath.row && allowedOpenAccess){
        
        //        NSLog(@"Button Tapped once different");
        //        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        //        NSLog(@"tap count %ld", (long)_tappedImageCount);
        //        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
        if([UIPasteboard generalPasteboard]){
            NSString * urlPath = currentGif.gifUrl;
            if (self.isFacebookButtonOn == YES) {
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                [pasteBoard setURL:[NSURL URLWithString:urlPath]];
                // Make toast with an image
                [self.view makeToast:@"Eboticon url copied!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            } else {
                if([self doesInternetExists]){
                    
                    
                    NSString * urlPath = currentGif.gifUrl;
                    NSLog(@"%@",urlPath);
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                }
                else{
                    
                    NSString * filePath= [[NSBundle mainBundle] pathForResource:currentGif.fileName ofType:@""];
                    
                    //    NSLog(@"filePath: %@", filePath);
                    
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    // UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
                    // [pasteboard setImage:image];
                    
                }
                
                // Send to Firebase
                [[FirebaseConfigurator sharedInstance] logEvent:currentGif.fileName];
                
                // Make toast with an image
                [self.view makeToast:@"Eboticon copied. Now paste it!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            }
            
            
            
        }
        else{
            
            // Make toast with an image
            [self.view makeToast:@"Please allow full access. Go to Settings->General->Keyboard->Eboticons->Allow full access"
                        duration:3.0
                        position:CSToastPositionCenter
             ];
            
        }
        
        
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_lastImageSelected inSection:0];
        [indexPaths addObject:lastPath];
        
    }
    else if (_tappedImageCount == 1 && _currentImageSelected == indexPath.row && allowedOpenAccess){       //Second Tap
        
        //    NSLog(@"Button Tapped twice");
        _tappedImageCount = 0;
        _currentImageSelected = 0;
        
        if([UIPasteboard generalPasteboard]){
            
            if (self.isFacebookButtonOn == YES) {
                NSString * urlPath = currentGif.gifUrl;
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                [pasteBoard setURL:[NSURL URLWithString:urlPath]];
                // Make toast with an image
                [self.view makeToast:@"Eboticon url copied!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            } else {
                if([self doesInternetExists]){
                    
                    NSString * urlPath = currentGif.gifUrl;
                    NSLog(@"%@",urlPath);
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    
                }
                else{
                    
                    NSString * filePath= [[NSBundle mainBundle] pathForResource:currentGif.fileName ofType:@""];
                    
                    NSLog(@"filePath: %@", filePath);
                    
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    // UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
                    // [pasteboard setImage:image];
                    
                }
                
                
                // Make toast with an image
                [self.view makeToast:@"Eboticon copied. Now paste it!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            }
            
            [[FirebaseConfigurator sharedInstance] logEvent:currentGif.fileName];
            
        }
        else{
            
            // Make toast with an image
            [self.view makeToast:@"Please allow full access. Go to Settings->General->Keyboard->Eboticons->Allow full access"
                        duration:3.0
                        position:CSToastPositionCenter
             ];
            
        }
    }
    //No image selected
    else if (_tappedImageCount == 0 && _currentImageSelected != indexPath.row && allowedOpenAccess){
        
        //        NSLog(@"Button Tapped once");
        //        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        //        NSLog(@"tap count %ld", (long)_tappedImageCount);
        //        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        
        
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
        // Make toast
        if([UIPasteboard generalPasteboard]){
            
            if (self.isFacebookButtonOn == YES) {
                NSString * urlPath = currentGif.gifUrl;
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                [pasteBoard setURL:[NSURL URLWithString:urlPath]];
                // Make toast with an image
                [self.view makeToast:@"Eboticon url copied!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            } else {
                if([self doesInternetExists]){
                    
                    NSString * urlPath = currentGif.gifUrl;
                    NSLog(@"%@",urlPath);
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                }
                else{
                    
                    NSString * filePath= [[NSBundle mainBundle] pathForResource:currentGif.fileName ofType:@""];
                    
                    NSLog(@"filePath: %@", filePath);
                    
                    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
                    //NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
                    
                    // UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
                    // [pasteboard setImage:image];
                    
                }
                
                // Make toast with an image
                [self.view makeToast:@"Eboticon copied. Now paste it!"
                            duration:3.0
                            position:CSToastPositionCenter
                 ];
            }
            
            //Send to Firebase
            [[FirebaseConfigurator sharedInstance] logEvent:currentGif.fileName];
            
            
        }
        else{
            
            // Make toast with an image
            [self.view makeToast:@"Please allow full access. Go to Settings->General->Keyboard->Eboticons->Allow full access"
                        duration:3.0
                        position:CSToastPositionCenter
             ];
            
        }
        
    }
    else {
        
        // Make toast with an image
        [self.view makeToast:@"Please allow full access. Go to Settings->General->Keyboard->Eboticons->Allow full access"
                    duration:3.0
                    position:CSToastPositionCenter
         ];
        
    }
    
    [indexPaths addObject:indexPath];
    [_collectionView  reloadItemsAtIndexPaths:indexPaths];
    
    //Select last image
    _lastImageSelected = _currentImageSelected;
    
}

#pragma mark - UICollectionViewDelegateFlowLayout Protocol methods
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//     NSLog(@"%f", _collectionView.frame.size.height);
//    
//    // CGFloat pageWidth = _collectionView.frame.size.width;
//    CGFloat pageHeight = _collectionView.frame.size.height;
//    CGFloat newItemSizeHeight;
//    CGFloat newItemSizeWidth;
//    UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.
//    
//    //Check for Landscape or Portrait mode
//    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
//        //Create 5x2 grid
//        newItemSizeHeight = floor(pageHeight/2) - (sectionInset.top+sectionInset.bottom);
//        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
//    }
//    else{
//        //Keyboard is in Landscape
//        NSLog(@"Landscape");
//        
//        //Create 9x2 grid
//        //newItemSizeWidth = floor(pageWidth/9) - 1;
//        newItemSizeHeight = floor(pageHeight/2) - (sectionInset.top+sectionInset.bottom);
//        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
//        
//        
//    }
//    
//    //NSLog(@"pageHeight %f", pageHeight);
//    //NSLog(@"pageWidth %f", pageWidth);
//    //NSLog(@"sectionInset top and bottom %f", sectionInset.top+sectionInset.bottom);
//    //NSLog(@"sectionInset top and bottom %f", sectionInset.left+sectionInset.right);
//    //NSLog(@"newItemSizeHeight 2: %f", newItemSizeHeight);
//    //NSLog(@"newItemSizeWidth  2: %f", newItemSizeWidth);
//    
//    //Create new item size
//    return CGSizeMake(newItemSizeWidth, newItemSizeHeight);
//}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
    // NSLog(@"%s", __PRETTY_FUNCTION__);
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s, width: %f", __PRETTY_FUNCTION__, self.view.bounds.size.width/3 - 8);
    return CGSizeMake(self.view.bounds.size.width/3 - 8, self.view.bounds.size.width/3 - 8);
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_showSection == YES) {
        return CGSizeMake(_collectionView.frame.size.width, 60);
    } else {
        return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PackSectionHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PackSectionHeaderCollectionReusableView" forIndexPath:indexPath];
    if (_showSection == YES) {
       EboticonGif *eboticon = [[_currentEboticonGifs objectAtIndex:indexPath.section] objectAtIndex:0];
        headerView.packSectionImageView.image = [self packSectionHeader:eboticon];
    }
    return headerView;
}

#pragma mark - Orientation Protocol methods


- (void)viewWillLayoutSubviews
{
   // [self.flowLayout invalidateLayout];
    
    //Set Keyboard Frame
//    self.keyboardView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    //Set activity frame and position
    self.activityIndicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    self.activityIndicator.center = self.view.center;
    
    //Set Frame Position
    self.captionSwitch.frame = CGRectMake(5.0f, 5.0f, 100.0f, 20.0f);
    
    //Set Page Control
    //self.topBarView.frame = CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height);
    
    //Set Image View
    self.noConnectionImageView.frame = CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height-44);
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //NSLog(@"viewDidLayoutSubviews");
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        //Keyboard is in Portrait
        //NSLog(@"Portrait");
        
        //Change the bottom border
        CGRect newFrame = self.bottomBorder.frame;
        newFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        [self.bottomBorder setFrame:newFrame];
        
        //Change flowlayout
        //[self changeKeyboardFlowLayout];
        
    }
    else{
        //Keyboard is in Landscape
        // NSLog(@"Landscape");
        
        //Change the bottom border
        CGRect newFrame = self.bottomBorder.frame;
        newFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        [self.bottomBorder setFrame:newFrame];
        
        //Change flowlayout
        //[self changeKeyboardFlowLayout];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // If memory warning is issued, then we can clear the objects to free some memory. Here we are simply removing all the images. But we can use a bit more logic to handle the memory here.
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.imageDownloadsInProgress removeAllObjects];
}


/////////////////////////////////////
//   Helper Methods
/////////////////////////////////////
#pragma mark - Helper Methods
- (void)startIconDownload:(EboticonGif *)currentGif forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imgDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (imgDownloader == nil)
    {
        imgDownloader = [[ImageDownloader alloc] init];
        imgDownloader.imageRecord = currentGif;
        [imgDownloader setCompletionHandler:^{
            
            KeyboardCell *cell = (KeyboardCell *)[_collectionView cellForItemAtIndexPath:indexPath];
            
            
            // Display the newly loaded image
            
            [UIView transitionWithView:cell.imageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                cell.imageView.image = currentGif.thumbImage;
                            } completion:nil];
            //cell.imageView.image = currentGif.thumbImage;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.imageView viewWithTag:505];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
        }];
        [self.imageDownloadsInProgress setObject:imgDownloader forKey:indexPath];
        [imgDownloader startDownload];
    }
}

- (void)loadImagesForOnscreenRows
{
    
    if ([_currentEboticonGifs count] > 0)
    {
        NSArray *visiblePaths = [_collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            EboticonGif *imgRecord = [[EboticonGif alloc] init];
            if (_showSection == YES) {
                imgRecord = [[_currentEboticonGifs objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            } else {
                imgRecord = [_currentEboticonGifs objectAtIndex:indexPath.row];
            }
            
            if (!imgRecord.thumbImage)
                // Avoid downloading if the image is already downloaded
            {
                [self startIconDownload:imgRecord forIndexPath:indexPath];
            }
        }
    }
}




#pragma mark - TextInput methods

- (void)textWillChange:(id<UITextInput>)textInput {
    
}

- (void)textDidChange:(id<UITextInput>)textInput {
    
}

#pragma mark - initialization method

- (void) initializeKeypad{
    
    //start with shift on
    _shiftStatus = 1;
    
    //initialize space key double tap
    UITapGestureRecognizer *spaceDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spaceKeyDoubleTapped:)];
    
    spaceDoubleTap.numberOfTapsRequired = 2;
    [spaceDoubleTap setDelaysTouchesEnded:NO];
    
    [self.spaceButton addGestureRecognizer:spaceDoubleTap];
    
    //initialize shift key double and triple tap
    UITapGestureRecognizer *shiftDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyDoubleTapped:)];
    UITapGestureRecognizer *shiftTripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyPressed:)];
    
    shiftDoubleTap.numberOfTapsRequired = 2;
    shiftTripleTap.numberOfTapsRequired = 3;
    
    [shiftDoubleTap setDelaysTouchesEnded:NO];
    [shiftTripleTap setDelaysTouchesEnded:NO];
    
    [self.shiftButton addGestureRecognizer:shiftDoubleTap];
    [self.shiftButton addGestureRecognizer:shiftTripleTap];
    
    self.keypadView.hidden = YES;
    self.isKeypadOn = false;
    self.isFacebookButtonOn = NO;
    
}

#pragma mark - key methods


- (IBAction)keypadPressed:(id)sender {
    
    //Set Category Button
    [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
    [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
    [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
    [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
    [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
    [self.purchasedButton setImage:[UIImage imageNamed:@"Purchased.png"] forState:UIControlStateNormal];
    [self.keypadButton setImage:[UIImage imageNamed:@"HLKeypad.png"] forState:UIControlStateNormal];
    
    if(!self.isKeypadOn){
        self.topBarView.hidden = YES;
        self.captionSwitch.hidden = YES;
        _collectionView.hidden = YES;
        self.keypadView.hidden = NO;
        self.isKeypadOn = true;
        self.facebookButton.hidden = YES;
        self.storeButton.hidden = YES;
    }
    else{
        
        
        
       // self.pageControl.hidden = NO;
        self.topBarView.hidden = NO;
        self.captionSwitch.hidden = NO;
        self.storeButton.hidden = NO;
        self.facebookButton.hidden = NO;
        _collectionView.hidden = NO;
        self.keypadView.hidden = YES;
        self.isKeypadOn = false;
    }
    
}

- (IBAction) keyPressed:(UIButton*)sender {
    
    //inserts the pressed character into the text document
    [self.textDocumentProxy insertText:sender.titleLabel.text];
    
    //if shiftStatus is 1, reset it to 0 by pressing the shift key
    if (_shiftStatus == 1) {
        [self shiftKeyPressed:self.shiftButton];
    }
    
}

-(IBAction) backspaceKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy deleteBackward];
}



-(IBAction) spaceKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy insertText:@" "];
    
}


-(void) spaceKeyDoubleTapped: (UIButton*) sender {
    
    //double tapping the space key automatically inserts a period and a space
    //if necessary, activate the shift button
    [self.textDocumentProxy deleteBackward];
    [self.textDocumentProxy insertText:@". "];
    
    if (_shiftStatus == 0) {
        [self shiftKeyPressed:self.shiftButton];
    }
}


-(IBAction) returnKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy insertText:@"\n"];
}


-(IBAction) shiftKeyPressed: (UIButton*) sender {
    
    //if shift is on or in caps lock mode, turn it off. Otherwise, turn it on
    _shiftStatus = _shiftStatus > 0 ? 0 : 1;
    
    [self shiftKeys];
}



-(void) shiftKeyDoubleTapped: (UIButton*) sender {
    
    //set shift to caps lock and set all letters to uppercase
    _shiftStatus = 2;
    
    [self shiftKeys];
    
}


- (void) shiftKeys {
    
    //if shift is off, set letters to lowercase, otherwise set them to uppercase
    if (_shiftStatus == 0) {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.lowercaseString forState:UIControlStateNormal];
        }
    } else {
        for (UIButton* letterButton in self.letterButtonsArray) {
            [letterButton setTitle:letterButton.titleLabel.text.uppercaseString forState:UIControlStateNormal];
        }
    }
    
    //adjust the shift button images to match shift mode
    NSString *shiftButtonImageName = [NSString stringWithFormat:@"shift_%i.png", _shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonImageName] forState:UIControlStateNormal];
    
    
    NSString *shiftButtonHLImageName = [NSString stringWithFormat:@"shift_%iHL.png", _shiftStatus];
    [self.shiftButton setImage:[UIImage imageNamed:shiftButtonHLImageName] forState:UIControlStateHighlighted];
    
}


- (IBAction) switchKeyboardMode:(UIButton*)sender {
    
    NSLog(@"switchKeyboardMode");

    
    self.numbersRow1View.hidden = YES;
    self.numbersRow2View.hidden = YES;
    self.symbolsRow1View.hidden = YES;
    self.symbolsRow2View.hidden = YES;
    self.numbersSymbolsRow3View.hidden = YES;
    
    //switches keyboard to ABC, 123, or #+= mode
    //case 1 = 123 mode, case 2 = #+= mode
    //default case = ABC mode
    
    switch (sender.tag) {
            
        case 1: {
            self.numbersRow1View.hidden = NO;
            self.numbersRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to #+= and row 4 switch button to ABC
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"symbols.png"] forState:UIControlStateNormal];
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"symbolsHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow3Button.tag = 2;
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"abc.png"] forState:UIControlStateNormal];
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"abcHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow4Button.tag = 0;
        }
            break;
            
        case 2: {
            self.symbolsRow1View.hidden = NO;
            self.symbolsRow2View.hidden = NO;
            self.numbersSymbolsRow3View.hidden = NO;
            
            //change row 3 switch button image to 123
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"numbers.png"] forState:UIControlStateNormal];
            [self.switchModeRow3Button setImage:[UIImage imageNamed:@"numbersHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow3Button.tag = 1;
        }
            break;
            
        default:
            //change the row 4 switch button image to 123
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"numbers.png"] forState:UIControlStateNormal];
            [self.switchModeRow4Button setImage:[UIImage imageNamed:@"numbersHL.png"] forState:UIControlStateHighlighted];
            self.switchModeRow4Button.tag = 1;
            break;
    }
    
}

#pragma mark-
#pragma mark Gesture Recognizer


- (void)respondToSwipeRightGesture:(UISwipeGestureRecognizer *)sender{
    //NSLog(@"Swipe Right Detected");
    
    if(_currentCategory > 1){
        //Change category
        [self changeCategory:_currentCategory-1];
    }
    else{
        //Change category
        [self changeCategory:6];
    }
    
    
}

- (void)respondToSwipeLeftGesture:(UISwipeGestureRecognizer *)sender{
    //  NSLog(@"Swipe Detected Left");
    
    if(_currentCategory < 6){
        //Change category
        [self changeCategory:_currentCategory+1];
    }
    else{
        //Change category
        [self changeCategory:1];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIView class]])
    {
        return YES;
    }
    return NO;
}


@end

