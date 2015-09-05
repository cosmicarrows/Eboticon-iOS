//
//  KeyboardViewController.m
//  iOSKeyboardTemplate
//
//  Copyright (c) 2014 BJH Studios. All rights reserved.
//  questions or comments contact jeff@bjhstudios.com

#import "KeyboardViewController.h"
#import "KeyboardCollectionViewFlowLayout.h"
#import "ShopDetailCell.h"
#import "UIView+Toast.h"
#import "CHCSVParser.h"

#import "TTSwitch.h"

//#import <DFImageManager/DFImageManagerKit.h>
#import "Reachability.h"

#define CATEGORY_SMILE @"Happy"
#define CATEGORY_NOSMILE @"Sad"
#define CATEGORY_HEART @"Love"
#define CATEGORY_GIFT @"Greeting"
#define CATEGORY_EXCLAMATION @"Exclamation"

@interface KeyboardViewController () {
    
    NSInteger _currentCategory;
    NSInteger _tappedImageCount;
    NSInteger _currentImageSelected;
    NSInteger _lastImageSelected;
    NSInteger _captionState;
    NSInteger _scrollSwipeState;
    
    NSArray *_csvImages;
    
    NSMutableArray *_currentEboticonGifs;
    
    NSMutableArray *_allImages;
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
    
}


- (void)respondToSwipeRightGesture:(UISwipeGestureRecognizer *)sender;
- (void)respondToSwipeLeftGesture:(UISwipeGestureRecognizer *)sender;

// Categories
@property (weak, nonatomic) IBOutlet UIButton *globeKey;
@property (weak, nonatomic) IBOutlet UIButton *heartButton;
@property (weak, nonatomic) IBOutlet UIButton *smileButton;
@property (weak, nonatomic) IBOutlet UIButton *noSmileButton;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;
@property (weak, nonatomic) IBOutlet UIButton *exclamationButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;

// Collection View
@property (nonatomic, nonatomic) IBOutlet UICollectionView *keyboardCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

// Reachability
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

// No connection
@property (nonatomic, nonatomic) IBOutlet UIImageView *noConnectionImageView;



//Bottom border
@property (nonatomic, nonatomic) UIView *bottomBorder;

//Caption Button
@property (weak, nonatomic) IBOutlet UIImageView *topBarView;

//Caption Switch
@property (strong, nonatomic) IBOutlet TTSwitch *captionSwitch;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
    
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    

    // Add a target that will be invoked when the page control is
    // changed by tapping on it
    [self.pageControl
     addTarget:self
     action:@selector(pageControlChanged:)
     forControlEvents:UIControlEventValueChanged
     ];
    
    // Set the number of pages to the number of pages in the paged interface
    // and let the height flex so that it sits nicely in its frame
    self.pageControl.numberOfPages = 1;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    
    //Initialize Gifs
    _currentEboticonGifs         = [[NSMutableArray alloc] init];
    _allImages                   = [[NSMutableArray alloc] init];
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
    
    //Intialize current tapped image
    _tappedImageCount       = 0;
    _currentImageSelected   = 0;
    _lastImageSelected      = 0;
    _captionState           = 1;
    
    //Add bottom border
    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self. self.topBarView.frame.size.height - 1.0f, self. self.topBarView.frame.size.width, 1)];
    self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.2f];
    
    [self.topBarView addSubview:self.bottomBorder];
    
    NSLog(@"Keyboard Started");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    //Setup Keyboard
    [self initializeKeyboard];
    
    
    
    //Load CSV into Array
    [self loadGifsFromCSV];
    
    //Setup item size of keyboard layout to fit keyboard.
    [self changeKeyboardFlowLayout];
    
    if([self doesInternetExists]){
        //Convert CSV to an array
        self. self.captionSwitch.hidden = NO;
        self.pageControl.hidden = NO;
        [self populateGifArraysFromCSV];
    
    }
    else{
        //add Internet connection view and remove caption button
        self.noConnectionImageView.hidden = NO;
        self. self.captionSwitch.hidden = YES;
        self.pageControl.hidden = YES;
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





- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Eboticon memory warning");
    
}


#pragma mark-
#pragma mark Gesture Recognizer


- (void)respondToSwipeRightGesture:(UISwipeGestureRecognizer *)sender{
    NSLog(@"Swipe Right Detected");
    
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
    NSLog(@"Swipe Detected Left");
    
    if(_currentCategory < 5){
        
        
        //Change category
        [self changeCategory:_currentCategory+1];
    }
    else{
        //Change category
        [self changeCategory:1];
    }
    
    
}


#pragma mark - TextInput methods

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateNumberLabelText];
}

- (void)updateNumberLabelText {
     NSLog(@"loading in keyboard sharedDefaults...");
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.eboticon.eboticon"];
    NSArray *purchasedProducts = [defaults objectForKey:@"purchasedProducts"];
    //self.numberLabel.text = [NSString stringWithFormat:@"%d", number];
}


#pragma mark - TextInput methods

- (void)textWillChange:(id<UITextInput>)textInput {
    
}

- (void)textDidChange:(id<UITextInput>)textInput {
    
}


#pragma mark-
#pragma mark Reachability

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus internetStatus = [self.internetReachability currentReachabilityStatus];
    NSLog(@"Network status: %li", (long)internetStatus);
    
    if (internetStatus != NotReachable) {
        
        //
        NSLog(@"Internet connection exists");
        self.noConnectionImageView.hidden = YES;
        self. self.captionSwitch.hidden = NO;
        self.pageControl.hidden = NO;
  
    }
    else {
        //there-is-no-connection warning
        NSLog(@"NO Internet connection exists");
        self.noConnectionImageView.hidden = NO;
        self. self.captionSwitch.hidden = YES;
        self.pageControl.hidden = YES;
 
    }
    
}


- (BOOL) doesInternetExists {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        NSLog(@"Internet connection exists");
        return YES;
    }
    else {
        //there-is-no-connection warning
        NSLog(@"NO Internet connection exists");
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



#pragma mark - initialization method

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_gifs" ofType:@"csv"];
    NSError *error = nil;
    
    //Read All Gifs From CSV
    @try {
        
        _csvImages = [NSArray arrayWithContentsOfCSVFile:path];
        
        if (_csvImages == nil) {
            NSLog(@"Error parsing file: %@", error);
            return;
        }
        else {
            
            
            [_allImages addObjectsFromArray:_csvImages];
            
            NSMutableArray *element = [[NSMutableArray alloc]init];
            /*
            for(int i=0; i<[_csvImages count];i++){
                element = [_csvImages objectAtIndex: i];
                NSLog(@"Element %i = %@", i, element);
                NSLog(@"Element Count = %lu", (unsigned long)[element count]);
            }*/
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to load csv: %@",exception);
    }
    
    
}


-(void) populateGifArraysFromCSV
{
    if([_allImages count] > 0){
        
        NSMutableArray *currentGif = [[NSMutableArray alloc]init];
        
        _exclamationImagesCaption = [[NSMutableArray alloc]init];
        _exclamationImagesNoCaption = [[NSMutableArray alloc]init];
        _smileImagesCaption = [[NSMutableArray alloc]init];
        _smileImagesNoCaption = [[NSMutableArray alloc]init];
        _nosmileImagesCaption = [[NSMutableArray alloc]init];
        _nosmileImagesNoCaption = [[NSMutableArray alloc]init];
        _giftImagesCaption = [[NSMutableArray alloc]init];
        _giftImagesNoCaption = [[NSMutableArray alloc]init];
        _heartImagesCaption = [[NSMutableArray alloc]init];
        _heartImagesNoCaption = [[NSMutableArray alloc]init];
        
        for(int i = 0; i < [_allImages count]; i++){
            currentGif = [_allImages objectAtIndex:i];
            
            NSString * gifCategory = [currentGif objectAtIndex:6]; //Category
            NSString * gifCaption = [currentGif objectAtIndex:3];
            
            //  NSLog(@"Current Gif filename:%@ stillname:%@ displayname:%@ category:%@ movie:%@ displayType:%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category], [currentGif movFileName], [currentGif displayType]);
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
                
               // NSLog(@"Adding eboticon to category CATEGORY_HEART:%@",[currentGif objectAtIndex:0]);
            
            }
            else if([gifCategory isEqual:CATEGORY_GIFT]) {
                
                //Check for Caption
                if ([gifCaption isEqual:@"Caption"])
                    [_giftImagesCaption addObject:[_allImages objectAtIndex:i]];
                else{
                    [_giftImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                }
                
                // NSLog(@"Adding eboticon to category CATEGORY_GIFT:%@",[currentGif fileName]);
            }
            else if([gifCategory isEqual:CATEGORY_EXCLAMATION]) {
                
                
                if ([gifCaption isEqual:@"Caption"])
                    [_exclamationImagesCaption addObject:[_allImages objectAtIndex:i]];
                else{
                    [_exclamationImagesNoCaption addObject:[_allImages objectAtIndex:i]];
                }
                
                // NSLog(@"Adding eboticon to category CATEGORY_EXCLAMATION:%@",[currentGif fileName]);
            }
            else {
                //  NSLog(@"Eboticon category not recognized for eboticon: %@ with category:%@",[currentGif fileName],[currentGif category]);
            }
        }//End for
        
        //Set currnet gifs
        _currentEboticonGifs = _heartImagesCaption;
        [self changeCategory:1];
        
        
        [self.keyboardCollectionView reloadData];       //Relaod the images into view
        [self changePageControlNum];                    //Change the page control
        
        [self changeKeyboardFlowLayout];                //Change flowlayout
        
        
    } else {
        NSLog(@"Eboticon Gif array count is less than zero.");
    }
    
}


#pragma mark - Key methods


- (void)changeCaptionSwitch:(id)sender{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
        _captionState = 1;
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
        _captionState = 0;
    }
    
    
    //Load the Gifs
    switch (_currentCategory) {
            //Heart
        case 1: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _heartImagesCaption;
            }
            else{
                _currentEboticonGifs = _heartImagesNoCaption;
            }
            
        }
            break;
            //Smile
        case 2: {
            
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
        case 3: {
            
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
        case 4: {
            
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
        case 5: {
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _exclamationImagesCaption;
            }
            else{
                _currentEboticonGifs = _exclamationImagesNoCaption;
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


- (IBAction) categoryKeyPressed:(UIButton*)sender {
    
    //switches to user's next category
    NSLog(@"Category %ld Pressed", (long)sender.tag);
    
    //Change category
    [self changeCategory:sender.tag];
    
}

-(IBAction) deleteKeyPressed: (UIButton*) sender {
    
    [self.textDocumentProxy deleteBackward];       // Deletes the character to the left of the insertion point
}


- (void) changeCategory: (NSInteger)tag{
    
    //Make sure nothing is animated
    _currentCategory = tag;
    _tappedImageCount = 0;
    _currentImageSelected = 0;
    
    //Change the toolbar
    NSLog(@"tag: %ld", (long)tag);
    
    switch (tag) {
            
            //Heart
        case 1: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HLHeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _heartImagesCaption;
            }
            else{
                _currentEboticonGifs = _heartImagesNoCaption;
            }
            
        }
            break;
            //Smile
        case 2: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HLHappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            
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
        case 3: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"HLNotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            
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
        case 4: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"HLGiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"ExclamationSmaller.png"] forState:UIControlStateNormal];
            
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
        case 5: {
            
            //Set Category Button
            [self.heartButton setImage:[UIImage imageNamed:@"HeartSmaller.png"] forState:UIControlStateNormal];
            [self.smileButton setImage:[UIImage imageNamed:@"HappySmaller.png"] forState:UIControlStateNormal];
            [self.noSmileButton setImage:[UIImage imageNamed:@"NotHappySmaller.png"] forState:UIControlStateNormal];
            [self.giftButton setImage:[UIImage imageNamed:@"GiftBoxSmaller.png"] forState:UIControlStateNormal];
            [self.exclamationButton setImage:[UIImage imageNamed:@"HLExclamationSmaller.png"] forState:UIControlStateNormal];
            //[self.exclamationButton setImage:[UIImage imageNamed:@"Exclamation2.jpg"] forState:UIControlStateNormal];
            
            //Load Gifs depending on caption
            if (_captionState) {
                _currentEboticonGifs = _exclamationImagesCaption;
            }
            else{
                _currentEboticonGifs = _exclamationImagesNoCaption;
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
            break;
    }
    
    [self.keyboardCollectionView reloadData];
    [self changePageControlNum];
}

#pragma mark-
#pragma mark PageControl


- (void)pageControlChanged:(id)sender
{
    
    NSLog(@"pageControlChanged");
    //UIPageControl *pageControl = sender;
    CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * self.pageControl.currentPage, 0);
    [self.keyboardCollectionView setContentOffset:scrollTo animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
     NSLog(@"scrollViewDidEndDecelerating");
    CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    self.pageControl.currentPage = self.keyboardCollectionView.contentOffset.x / pageWidth;
    
    //Reset Scroll State
    _scrollSwipeState = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width - 75;
    if (rightEdge >= scrollView.contentSize.width) {
        // we are at the end
        NSLog(@"At the right end!");
        
        if(_currentCategory < 5 && _scrollSwipeState == 0){
            
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:_currentCategory+1];
        }
        else if(_currentCategory == 5 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:1];
        }
    }
    
    
    
    float leftEdge = scrollView.contentOffset.x;
   // NSLog(@"scrollView.contentOffset: %f", scrollView.contentOffset.x);
    if (leftEdge <= -75) {
        // we are at the en d
        NSLog(@"At the left Edge end!");
  
        if(_currentCategory > 1 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:_currentCategory-1];
        }
        else if(_currentCategory == 1 && _scrollSwipeState == 0){
            //Change category
            _scrollSwipeState = 1;
            [self changeCategory:5];
        }
        

    }

    
}

- (void) changePageControlNum {
    
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
    NSLog(@"*****");
    NSLog(@"numberOfGifs: %f", numberOfGifs)
    ;
    NSLog(@"page num   calc: %f", ceil(numberOfGifs/8));
    NSLog(@"page num   2: %f", pageNumber);
    NSLog(@"page width 2: %f", pageWidth);
    
    
    //Page Control
    self.pageControl.numberOfPages = pageNumber;
    
    self.keyboardCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    if(pageNumber == 1 && numberOfGifs>6){
        [self.keyboardCollectionView setContentSize:CGSizeMake(pageWidth*2, pageHeight)];
    }
    else{
        [self.keyboardCollectionView setContentSize:CGSizeMake(pageWidth*pageNumber, pageHeight)];
    }
    
    //self.keyboardCollectionView.contentSize.width      = self.flowLayout.itemSize.width*4;
    NSLog(@"content size: %f", self.keyboardCollectionView.contentSize.width);
    
}


- (void) changeKeyboardFlowLayout {
    
    CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
    CGFloat pageHeight = self.keyboardCollectionView.frame.size.height;
    CGFloat newItemSizeHeight;
    CGFloat newItemSizeWidth;
    UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.

    
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
        NSLog(@"Landscape");
        
        //Create 9x2 grid
        //newItemSizeWidth = floor(pageWidth/9) - 1;
        newItemSizeHeight = floor(pageHeight/2) - 4;
        newItemSizeWidth = floor(newItemSizeHeight*4.0/3.0);
    }

    //NSLog(@"pageHeight %f", pageHeight);
    //NSLog(@"pageWidth %f", pageWidth);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.top+sectionInset.bottom);
    //NSLog(@"sectionInset top and bottom %f", sectionInset.left+sectionInset.right);
    NSLog(@"newItemSizeHeight 1: %f", newItemSizeHeight);
    NSLog(@"newItemSizeWidth  1: %f", newItemSizeWidth);
    
    //Create new item size
    self.flowLayout.itemSize = CGSizeMake(newItemSizeWidth, newItemSizeHeight);
    

}




#pragma mark-
#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_currentEboticonGifs count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //csvRow is the a row of the csv
    NSMutableArray *csvRow = [[NSMutableArray alloc]init];
    csvRow = [_currentEboticonGifs objectAtIndex: (long)indexPath.row];
    
    //Set filename and
    NSString *filename      = [csvRow objectAtIndex: 0];       //Gif File Name
    NSString *stillname     = [csvRow objectAtIndex: 1];       //Png Still File Name
    
    
    ShopDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    
    
    
    //Change image to gif
    NSString * filePath;
    NSString * urlPath;
    
    if([self isRequestsOpenAccessEnabled]){
        
        [cell.imageView prepareForReuse];
        
        //Load Gif File name
        if (_tappedImageCount == 1 && _currentImageSelected == indexPath.row){
            filePath= [[NSBundle mainBundle] pathForResource:filename ofType:@""];
            
            urlPath = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/%@", filename];
            NSLog(@"Loading gif: %@", urlPath);
            
            [cell.imageView setImageWithResource:[NSURL URLWithString:urlPath]];
            
        }
        //Load Still Name
        else{

            [cell.imageView setImage:[UIImage imageNamed:stillname]];
        }
    }
    else{
        
        NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"placeholder" withExtension:@"png"];
        [cell.imageView setImageWithResource:imageURL targetSize:[self _imageTargetSize] contentMode:DFImageContentModeAspectFill options:nil];
        
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
    NSMutableArray *currentGif = [[NSMutableArray alloc]init];
    currentGif = [_currentEboticonGifs objectAtIndex: (long)indexPath.row];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    //Set filename
    NSString *filename      = [currentGif objectAtIndex: 0];       //Gif File Name
    
    //First Tap
    if (_tappedImageCount == 0 && _currentImageSelected == indexPath.row && allowedOpenAccess){
        
        NSLog(@"Button Tapped once");
        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        NSLog(@"tap count %ld", (long)_tappedImageCount);
        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        
        // Make toast
        [self.view makeToast:@"Tap again to copy Eboticon."
                    duration:2.0
                    position:CSToastPositionCenter
         ];
        
        
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
    }
    //Tapped different image
    else if (_tappedImageCount == 1 && _currentImageSelected != indexPath.row && allowedOpenAccess){
        
        NSLog(@"Button Tapped once different");
        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        NSLog(@"tap count %ld", (long)_tappedImageCount);
        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
        
        // Make toast
        [self.view makeToast:@"Tap again to copy Eboticon."
                    duration:2.0
                    position:CSToastPositionCenter
         ];
        
        
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_lastImageSelected inSection:0];
        [indexPaths addObject:lastPath];
        
        
    }
    else if (_tappedImageCount == 1 && _currentImageSelected == indexPath.row && allowedOpenAccess){       //Second Tap
        
        NSLog(@"Button Tapped twice");
        _tappedImageCount = 0;
        _currentImageSelected = 0;
        
        
        if([UIPasteboard generalPasteboard]){
            // UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
            // [pasteboard setImage:image];
            
            
           // NSString * filePath= [[NSBundle mainBundle] pathForResource:filename ofType:@""];
             NSString * urlPath = [NSString stringWithFormat:@"http://www.inclingconsulting.com/eboticon/%@", filename];
            
            NSLog(@"%@",urlPath);
            UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
            //NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlPath]];
            
            [pasteBoard setData:data forPasteboardType:@"com.compuserve.gif"];
            
            
            
            
            // Make toast with an image
            [self.view makeToast:@"Eboticon copied. Now paste it!"
                        duration:3.0
                        position:CSToastPositionCenter
             ];
            
            
            
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
        
        NSLog(@"Button Tapped once");
        NSLog(@"currentImage %ld", (long)_currentImageSelected);
        NSLog(@"tap count %ld", (long)_tappedImageCount);
        NSLog(@"lastImage %ld", (long)_lastImageSelected);
        
        
        _tappedImageCount = 1;
        _currentImageSelected = indexPath.row;
        
        // Make toast
        [self.view makeToast:@"Tap again to copy Eboticon."
                    duration:2.0
                    position:CSToastPositionCenter
         ];
        
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




#pragma mark - Orientation Protocol methods

- (void)viewWillLayoutSubviews
{
    [self.flowLayout invalidateLayout];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
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
        NSLog(@"Landscape");
        
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

#pragma mark - UICollectionViewDelegateFlowLayout Protocol methods

 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
 {

     CGFloat pageWidth = self.keyboardCollectionView.frame.size.width;
     CGFloat pageHeight = self.keyboardCollectionView.frame.size.height;
     CGFloat newItemSizeHeight;
     CGFloat newItemSizeWidth;
     UIEdgeInsets sectionInset = [self.flowLayout sectionInset]; //here the sectionInsets are always = 0 because of a timing issue so you need to force set width of an item a few pixels less than the width of the collectionView.
     
     
     //Check for Landscape or Portrait mode
     if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){
         //Keyboard is in Portrait
         //NSLog(@"Portrait");
         
         
         
         //Create 5x2 grid
         //newItemSizeWidth = floor(pageWidth/5) - 1;  //Hied
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
 return UIEdgeInsetsMake(2, 2, 2, 2);
 }
 


@end

