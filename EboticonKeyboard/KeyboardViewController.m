//
//  KeyboardViewController.m
//  iOSKeyboardTemplate
//
//  Copyright (c) 2014 BJH Studios. All rights reserved.
//  questions or comments contact jeff@bjhstudios.com

#import <QuartzCore/QuartzCore.h>

#import "KeyboardViewController.h"
#import "KeyboardCollectionViewFlowLayout.h"
#import "ShopDetailCell.h"
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
    
    int _shiftStatus; //0 = off, 1 = on, 2 = caps lock
    
 
}

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

// Collection View
@property (nonatomic, nonatomic) IBOutlet UICollectionView *keyboardCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
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

//Caption Switch
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) UIButton *storeButton;
@property (strong, nonatomic) UIButton *facebookButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;


@property (nonatomic, assign) BOOL isKeypadOn;
@property (nonatomic, assign) BOOL isFacebookButtonOn;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Keyboard Started");
    
    //Init
    
    [FirebaseConfigurator sharedInstance];
    NSString *string = [[FirebaseConfigurator sharedInstance] test];

    
    NSLog(@"%@", string);
    
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    // Add a target that will be invoked when the page control is
    [self.pageControl
     addTarget:self
     action:@selector(pageControlChanged:)
     forControlEvents:UIControlEventValueChanged
     ];
    
    //Add bottom border
    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self. self.topBarView.frame.size.height - 1.0f, self. self.topBarView.frame.size.width, 1)];
    self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.2f];
    [self.topBarView addSubview:self.bottomBorder];
    
    //Show no connection png
    self.noConnectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    self.noConnectionImageView .image = [UIImage imageNamed:@"no_connection.png"];
    self.noConnectionImageView.hidden = YES;
    [self.view addSubview:self.noConnectionImageView ];
    
    //Activity Indicator
    [self createActivityIndicator];
    
    //Create Caption Switch
    [self createCaptionSwitch];
    
    //Initialize Extension
    [self initializeExtension];
    
    //    Initialize Keypad
    [self initializeKeypad];
    [self createStoreAndFacebookButton];
    

    
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
    //self.captionSwitch = [[TTSwitch alloc] initWithFrame:(CGRect){ self.keyboardCollectionView.frame.size.width/2.0f-50.0f, 2.0f, 100.0f, 20.0f }];
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

- (void)viewWillLayoutSubviews
{
    [self.flowLayout invalidateLayout];
    
    //Set Keyboard Frame
    self.keyboardView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
   
    
    //Set activity frame and position
    self.activityIndicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    self.activityIndicator.center = self.view.center;
    
    //Set Frame Position
    self.captionSwitch.frame = CGRectMake(5.0f, 5.0f, 100.0f, 20.0f);
    
    //Set Page Control
    //self.topBarView.frame = CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height);
    
    //Set Page Control
    self.pageControl.frame = CGRectMake(self.view.frame.size.width - 45, 5.0f, 39.0f, 37.0f);
    
    //Set Image View
    self.noConnectionImageView.frame = CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height-44);
    
    
    
    //CGFloat pageWidth    = self.keyboardCollectionView.frame.size.width;
    CGFloat pageWidth      = self.flowLayout.itemSize.width*4;
    CGFloat pageHeight     = self.keyboardCollectionView.frame.size.height;
    CGFloat pageNumber      =    self.pageControl.numberOfPages;
    //CGFloat contentSize    = self.keyboardCollectionView.contentSize.width;

    [self.keyboardCollectionView setContentSize:CGSizeMake(pageWidth*pageNumber, pageHeight)];
    
//    NSLog(@"keyboard width %f", self.keyboardView.frame.size.width);
//    NSLog(@"keyboard collection view width %f", self.keyboardCollectionView.frame.size.width);
//    NSLog(@"keyboard collection view content size width %f",  self.keyboardCollectionView.contentSize.width);
    
}

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
    self.pageControl.numberOfPages = 1;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
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
    
    
    

    
    
//    _exclamationImagesCaption = [[NSMutableArray alloc]init];
//    _exclamationImagesNoCaption = [[NSMutableArray alloc]init];
//    _smileImagesCaption = [[NSMutableArray alloc]init];
//    _smileImagesNoCaption = [[NSMutableArray alloc]init];
//    _nosmileImagesCaption = [[NSMutableArray alloc]init];
//    _nosmileImagesNoCaption = [[NSMutableArray alloc]init];
//    _giftImagesCaption = [[NSMutableArray alloc]init];
//    _giftImagesNoCaption = [[NSMutableArray alloc]init];
//    _heartImagesCaption = [[NSMutableArray alloc]init];
//    _heartImagesNoCaption = [[NSMutableArray alloc]init];
    
    //Intialize current tapped image
    _tappedImageCount       = 0;
    _currentImageSelected   = 0;
    _lastImageSelected      = 0;
    _captionState           = 1;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    

    
    
    //Setup Keyboard
    [self initializeKeyboard];
    
    //Load CSV into Array
    [self loadGifsFromCSV];
    
    //Load CSV into Array
    [self loadPurchasedProducts];
    
    //Setup item size of keyboard layout to fit keyboard.
    [self changeKeyboardFlowLayout];
    
    [self populateGifArraysFromCSV];
    
    if([self doesInternetExists]){
        //Convert CSV to an array
//        self. self.captionSwitch.hidden = NO;
//        self.pageControl.hidden = NO;
//        [self populateGifArraysFromCSV];
        
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
    [self.keyboardCollectionView addGestureRecognizer:swipeRecognizerRight];
    
    
    // Create and initialize a swipe right gesture
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeLeftGesture:)];
    swipeRecognizerLeft.direction =  UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizerLeft.numberOfTouchesRequired = 1;
    [self.keyboardCollectionView addGestureRecognizer:swipeRecognizerLeft];
    
    
}
- (void) initializeKeyboard {
    
    // Configure collection flow layout
    self.flowLayout = [[KeyboardCollectionViewFlowLayout alloc] init];
    
    //collectionView.frame
    self.keyboardCollectionView.showsHorizontalScrollIndicator = YES;
    self.keyboardCollectionView.pagingEnabled = NO;
    [self.keyboardCollectionView setCollectionViewLayout:self.flowLayout];
    
}

- (void) loadGifsFromCSV
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
    
    NSString *path;
    
    //Set Gifs is no internet exists
    if([self doesInternetExists]){
        path = [[NSBundle mainBundle] pathForResource:@"eboticon_gifs" ofType:@"csv"];
    }
    else{
        path = [[NSBundle mainBundle] pathForResource:@"eboticon_nointernet_gifs" ofType:@"csv"];
    }
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
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to load csv: %@",exception);
    }
}


-(void) populateGifArraysFromCSV
{
    if([_allImages count] > 0){
        
        EboticonGif *currentGif = [[EboticonGif alloc]init];
        

        
        for(int i = 0; i < [_allImages count]; i++){
            currentGif = [_allImages objectAtIndex:i];
            
            NSString * gifCategory = currentGif.emotionCategory; //Category
            NSString * gifCaption = currentGif.category;
            NSString * gifFileName = currentGif.fileName;;
            
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
        }//End for
        
        
        //Print Counts
           // NSLog(@"smile images caption: %lu", (unsigned long)_smileImagesCaption.count);
           // NSLog(@"heart images no caption: %lu", (unsigned long)_smileImagesNoCaption.count);
            //NSLog(@"heart images caption: %lu", (unsigned long)_heartImagesCaption.count);
           // NSLog(@"heart images no caption: %lu", (unsigned long)_heartImagesNoCaption.count);
        
        //Set currnet gifs
        _currentEboticonGifs = _smileImagesCaption;
        [self changeCategory:1];
        
        
        [self.keyboardCollectionView reloadData];       //Relaod the images into view
        [self changePageControlNum];                    //Change the page control
        
        [self changeKeyboardFlowLayout];                //Change flowlayout
        
        
    } else {
        NSLog(@"Eboticon Gif array count is less than zero.");
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
        [self changeCategory:5];
    }
    
    
}

- (void)respondToSwipeLeftGesture:(UISwipeGestureRecognizer *)sender{
  //  NSLog(@"Swipe Detected Left");
    
    if(_currentCategory < 5){
        
        
        //Change category
        [self changeCategory:_currentCategory+1];
    }
    else{
        //Change category
        [self changeCategory:1];
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
        self.pageControl.hidden = NO;
       
        
        //Load CSV into Array
        [self loadGifsFromCSV];
        
        //Populate Gifs
        [self populateGifArraysFromCSV];
        
        //Reload keyboard data
        //[self.keyboardCollectionView reloadData];
        //[self changePageControlNum];
        
    }
    else {
        
        //Load CSV into Array
        [self loadGifsFromCSV];
        
        [self populateGifArraysFromCSV];
        
        
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
//        [self.keyboardCollectionView reloadData];
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
    [self.keyboardCollectionView reloadData];
    [self changePageControlNum];
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
    [self changeCategory:sender.tag];
    
}

-(IBAction) purchasedKeyPressed: (UIButton*) sender {
    
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
    self.keyboardCollectionView.hidden = NO;
    self.captionSwitch.hidden = NO;
    self.storeButton.hidden = NO;
    self.facebookButton.hidden = NO;
    self.pageControl.hidden = NO;
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
    
    [self.keyboardCollectionView reloadData];
    [self changePageControlNum];
}

#pragma mark-
#pragma mark PageControl


- (void)pageControlChanged:(id)sender
{
    
    //NSLog(@"pageControlChanged");
    //UIPageControl *pageControl = sender;
    CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * self.pageControl.currentPage, 0);
    [self.keyboardCollectionView setContentOffset:scrollTo animated:YES];
}

- (void) changePageControlNum {
    
   // NSLog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat numberOfGifs = [_currentEboticonGifs count];
    CGFloat pageNumber;
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        //Keyboard is in Portrait
        pageNumber = ceil(numberOfGifs/8);
        
        
    }
    else{
        //Keyboard is in Landscape
        //NSLog(@"Landscape");
        pageNumber = ceil(numberOfGifs/18);
    }
    
    
    //CGFloat pageWidth    = self.keyboardCollectionView.frame.size.width;
    CGFloat pageWidth      = self.flowLayout.itemSize.width*4;
    CGFloat pageHeight     = self.keyboardCollectionView.frame.size.height;
    //CGFloat contentSize    = self.keyboardCollectionView.contentSize.width;
    
    
    //NSLog(@"%f", numberOfGifs);
    
//     NSLog(@"*****");
//    NSLog(@"page num   : %f", pageNumber);
//     NSLog(@"numberOfGifs: %f", numberOfGifs);
//     NSLog(@"page num   calc: %f", ceil(numberOfGifs/8));
//     NSLog(@"page width 2: %f", pageWidth);
//    NSLog(@"*****");
    
    
    //Page Control
    self.pageControl.numberOfPages = pageNumber;
    
    if (pageNumber >3) {
        self.pageControl.frame = CGRectMake(self.view.frame.size.width - 45 - ((pageNumber-3)*10.0), 0.0f, 39.0f, 37.0f);
    }
    
    self.keyboardCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    if(pageNumber == 1 && numberOfGifs>6){
        [self.keyboardCollectionView setContentSize:CGSizeMake(pageWidth*2, pageHeight)];
    }
    else{
        [self.keyboardCollectionView setContentSize:CGSizeMake(pageWidth*pageNumber, pageHeight)];
    }
    
    //self.keyboardCollectionView.contentSize.width      = self.flowLayout.itemSize.width*4;
   // NSLog(@"content size: %f", self.keyboardCollectionView.contentSize.width);
    
}


- (void) changeKeyboardFlowLayout {
    
   // CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    CGFloat pageHeight = self.keyboardCollectionView.frame.size.height;
    CGFloat newItemSizeHeight;
    CGFloat newItemSizeWidth;
   // UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.
    
    
    //Check for Landscape or Portrait mode
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        //Keyboard is in Portrait
        //NSLog(@"Portrait");
        
        //Create 5x2 grid
        //newItemSizeWidth = floor(pageWidth/5) - 1;  //Hied
        newItemSizeHeight = floor(pageHeight/2) - 3;
        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
        
        
    }
    else{
        //Keyboard is in Landscape
       // NSLog(@"Landscape");
        
        //Create 9x2 grid
        //newItemSizeWidth = floor(pageWidth/9) - 1;
        newItemSizeHeight = floor(pageHeight/2) - 4;
        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
    }
    
    //NSLog(@"pageHeight %f", pageHeight);
    //NSLog(@"pageWidth %f", pageWidth);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.top+sectionInset.bottom);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.left+sectionInset.right);
//    NSLog(@"newItemSizeHeight 1: %f", newItemSizeHeight);
//    NSLog(@"newItemSizeWidth  1: %f", newItemSizeWidth);
    
    //Create new item size
    self.flowLayout.itemSize = CGSizeMake(newItemSizeWidth, newItemSizeHeight);
    
    
}



/////////////////////////////////////
//   Scrollview Delegates
/////////////////////////////////////
#pragma mark - Scrollview Delegates
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [self loadImagesForOnscreenRows];
    
    
   // NSLog(@"scrollViewDidEndDecelerating");
    CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    self.pageControl.currentPage = self.keyboardCollectionView.contentOffset.x / pageWidth;
    
    //Reset Scroll State
    _scrollSwipeState = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width - 75;
    if (rightEdge >= scrollView.contentSize.width) {
        // we are at the end
       // NSLog(@"At the right end!");
        
        if(_currentCategory < 6 && _scrollSwipeState == 0){
            
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:_currentCategory+1];
        }
        else if(_currentCategory == 6 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:1];
        }
    }
    
    
    
    float leftEdge = scrollView.contentOffset.x;
    // NSLog(@"scrollView.contentOffset: %f", scrollView.contentOffset.x);
    if (leftEdge <= -75) {
        // we are at the en d
       // NSLog(@"At the left Edge end!");
        
        if(_currentCategory > 1 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:_currentCategory-1];
        }
        else if(_currentCategory == 1 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:6];
        }
        
    }
    
}

#pragma mark-
#pragma mark In App Products


/*
 
 - (void)getProducts {

 _products = nil;
 [[EboticonIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
 if (success) {
 _products = products;
 }
 }];
 }
 
 */

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateNumberLabelText];
}

- (void)updateNumberLabelText {
  //  NSLog(@"loading in keyboard sharedDefaults...");
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    _purchasedProducts = [defaults objectForKey:@"purchasedProducts"];
    //self.numberLabel.text = [NSString stringWithFormat:@"%d", number];
}


- (void)loadPurchasedProducts {
  //  NSLog(@"loadPurchasedProducts...");
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    _purchasedProducts = [defaults objectForKey:@"purchasedProducts"];
    
    for(NSString* productIdentifiers in _purchasedProducts) {
    //    NSLog(@"loadPurchasedGifsFromCSV: %@", productIdentifiers);
        [self loadPurchasedGifsFromCSV:productIdentifiers];
    }
    
}


- (void) loadPurchasedGifsFromCSV:(NSString*)productIdentifier
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_purchase_gifs" ofType:@"csv"];
    
   // NSError *error = nil;
    
    //Read All Gifs From CSV
    @try {
        NSArray * csvImages = [NSArray arrayWithContentsOfCSVFile:path];
        
        if (csvImages == nil) {
     //       NSLog(@"Error parsing file: %@", error);
            return;
        }
        else {
            
     //       NSLog(@"Number purchased gifs: %lu", (unsigned long)[csvImages count]);
            // Prepare the array for processing in LazyLoadVC. Add each URL into a separate ImageRecord object and store it in the array.
            for (int cnt=0; cnt<[csvImages count]; cnt++)
            {
                
                
                EboticonGif *eboticonObject = [[EboticonGif alloc] init];
                
                eboticonObject.fileName = [[csvImages objectAtIndex:cnt] objectAtIndex:0];
                eboticonObject.stillName = [[csvImages objectAtIndex:cnt] objectAtIndex:1];
                eboticonObject.displayName = [[csvImages objectAtIndex:cnt] objectAtIndex:2];
                eboticonObject.category = [[csvImages objectAtIndex:cnt] objectAtIndex:3];         //Caption or No Cation
                eboticonObject.emotionCategory = [[csvImages objectAtIndex:cnt] objectAtIndex:6];
                eboticonObject.purchaseCategory = [[csvImages objectAtIndex:cnt] objectAtIndex:7];
                
                eboticonObject.stillUrl        = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/purchased/%@", [[csvImages objectAtIndex:cnt] objectAtIndex:1]];
                eboticonObject.gifUrl          = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/purchased/%@", [[csvImages objectAtIndex:cnt] objectAtIndex:0]];
                
                
                NSString * purchaseCategory = eboticonObject.purchaseCategory;
               // NSString * gifCategory = eboticonObject.emotionCategory;
                NSString * isCaption = eboticonObject.category;
                
                if([productIdentifier isEqual:purchaseCategory]) {
//                    NSLog(@"adding  gif: %d", cnt);
//                    NSLog(@"emotionCategory : %@", gifCategory);
                    [_purchasedImages addObject:eboticonObject];
                    [_allImages addObject:eboticonObject];
                }
                
                if([productIdentifier isEqual:purchaseCategory] && _captionState && [isCaption isEqual:@"Caption"]) {
//                    NSLog(@"adding  gif: %d", cnt);
//                    NSLog(@"emotionCategory : %@", gifCategory);
                    [_purchasedImagesCaption addObject:eboticonObject];
                    //[_allImages addObject:eboticonObject];
                }
              
                if([productIdentifier isEqual:purchaseCategory] && _captionState && [isCaption isEqual:@"NoCaption"]) {
//                    NSLog(@"adding  gif: %d", cnt);
//                    NSLog(@"emotionCategory : %@", gifCategory);
                    [_purchasedImagesNoCaption addObject:eboticonObject];
                    //[_allImages addObject:eboticonObject];
                }
            }
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to load csv: %@",exception);
    }
}

#pragma mark-
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NSLog(@"NUmber of current gifs: %lu", (unsigned long)[_currentEboticonGifs count]);
    return [_currentEboticonGifs count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
   // NSLog(@" Loading row %lu", (long)indexPath.row) ;
   // NSLog(@" Loading current count %lu", (unsigned long)[_currentEboticonGifs count]);
    
    ShopDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.imageView viewWithTag:505];
    
    // Set up the cell...
    // Fetch a image record from the array
    EboticonGif *currentGif = [[EboticonGif alloc]init];
    currentGif = [_currentEboticonGifs objectAtIndex: (long)indexPath.row];
  

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
                        if (self.keyboardCollectionView.dragging == NO && self.keyboardCollectionView.decelerating == NO)
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

- (CGSize)_imageTargetSize {
    CGSize size = ((UICollectionViewFlowLayout *)self.flowLayout).itemSize;
    CGFloat scale = [UIScreen mainScreen].scale;
    return CGSizeMake(size.width * scale, size.height * scale);
}

-(void) collectionView:(UICollectionView *) collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Button Tapped: %ld", (long)[indexPath row]);
    BOOL allowedOpenAccess = [self isRequestsOpenAccessEnabled]; // Can you allow access
    
    //Get current gif
    EboticonGif *currentGif = [[EboticonGif alloc]init];
    currentGif = [_currentEboticonGifs objectAtIndex: (long)indexPath.row];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];

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
    [self.keyboardCollectionView  reloadItemsAtIndexPaths:indexPaths];
    
    //Select last image
    _lastImageSelected = _currentImageSelected;
    
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
            
            ShopDetailCell *cell = (ShopDetailCell *)[self.keyboardCollectionView cellForItemAtIndexPath:indexPath];
            
            
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
        NSArray *visiblePaths = [self.keyboardCollectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            EboticonGif *imgRecord = [_currentEboticonGifs objectAtIndex:indexPath.row];
            
            if (!imgRecord.thumbImage)
                // Avoid downloading if the image is already downloaded
            {
                [self startIconDownload:imgRecord forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Protocol methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
   // CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    CGFloat pageHeight = self.keyboardCollectionView.frame.size.height;
    CGFloat newItemSizeHeight;
    CGFloat newItemSizeWidth;
    UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.

    //Check for Landscape or Portrait mode
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
        //Create 5x2 grid
        newItemSizeHeight = floor(pageHeight/2) - (sectionInset.top+sectionInset.bottom);
        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
    }
    else{
        //Keyboard is in Landscape
        NSLog(@"Landscape");
        
        //Create 9x2 grid
        //newItemSizeWidth = floor(pageWidth/9) - 1;
        newItemSizeHeight = floor(pageHeight/2) - (sectionInset.top+sectionInset.bottom);
        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
        
        
    }
    
    //NSLog(@"pageHeight %f", pageHeight);
    //NSLog(@"pageWidth %f", pageWidth);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.top+sectionInset.bottom);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.left+sectionInset.right);
    //NSLog(@"newItemSizeHeight 2: %f", newItemSizeHeight);
    //NSLog(@"newItemSizeWidth  2: %f", newItemSizeWidth);
    
    //Create new item size
    return CGSizeMake(newItemSizeWidth, newItemSizeHeight);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
   // NSLog(@"%s", __PRETTY_FUNCTION__);
    return UIEdgeInsetsMake(2, 2, 2, 2);
}


#pragma mark - Orientation Protocol methods


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
        
        //Change Page Control
        [self changePageControlNum];
        
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
        
        //Change Page Control
        [self changePageControlNum];
        
        //Change flowlayout
        //[self changeKeyboardFlowLayout];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated{
    
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


    self.pageControl.hidden = YES;
    self.topBarView.hidden = YES;
    self.captionSwitch.hidden = YES;
    self.keyboardCollectionView.hidden = YES;
    self.keypadView.hidden = NO;
    self.isKeypadOn = true;
        self.facebookButton.hidden = YES;
        self.storeButton.hidden = YES;
        
    }
    else{
        
       
        
        self.pageControl.hidden = NO;
        self.topBarView.hidden = NO;
        self.captionSwitch.hidden = NO;
        self.storeButton.hidden = NO;
        self.facebookButton.hidden = NO;
        self.keyboardCollectionView.hidden = NO;
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


@end

