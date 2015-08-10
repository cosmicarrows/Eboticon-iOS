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
#import "GifCollectionViewController.h"
#import "GifCollectionViewFlowLayout.h"
#import "GifDetailViewController.h"
#import "OLImage.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "CHCSVParser.h"
#import "EboticonGif.h"
#import "EboticonGifCell.h"
#import "DDLog.h"
#import <QuartzCore/QuartzCore.h>
#import "SWRevealViewController.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;

#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define CATEGORY_RECENT @"Recent"
#define CATEGORY_CAPTION @"Caption"
#define CATEGORY_NO_CAPTION @"No Caption"
#define CSV_CATEGORY_NO_CAPTION @"NoCaption"

//Name of Categories in the CSV File
#define CATEGORY_ALL @"all"
#define CATEGORY_SMILE @"happy"
#define CATEGORY_NOSMILE @"not_happy"
#define CATEGORY_HEART @"love"
#define CATEGORY_GIFT @"greeting"
#define CATEGORY_EXCLAMATION @"exclamation"

@interface MainViewController (){
     NSInteger _captionState;
     UIToolbar *_toolbar;
     NSMutableArray *_toolbarButtons;
     NSMutableArray *_eboticonGifs;
    
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
    
    NSMutableArray *_currentEboticonGifs;
}

// Collection View
@property (nonatomic, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MasterBackground2.0.png"]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"MasterBackground2.0.png"].CGImage;     //Add Background without repeating
    
    
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
        self.navigationItem.rightBarButtonItem = clearbutton;
    }
    
    //Load Gif csv file
    NSLog(@"Eboticon Gif size %lu",(unsigned long)[_eboticonGifs count]);
    _eboticonGifs = [[NSMutableArray alloc] init];
    [self loadGifsFromCSV];
    
    NSLog(@"Gif Array count %lu",(unsigned long)[_eboticonGifs count]);
    [self populateGifArraysFromCSV];
    
    //Register the Gif Cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"EboticonGifCell" bundle:nil] forCellWithReuseIdentifier:@"AnimatedGifCell"];
    
    //Add background image
    //self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Ebo_Background.png"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //Add Layout Control
    //self.flowLayout = [[GifCollectionViewFlowLayout alloc]init];
    [self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:_gifCategory forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        NSLog(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
    
    //Add sidebar menu button
    [self setSidebarItems];
    
    //Make nav bar transparent
    [self makeNavBarTransparent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSidebarItems{
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(rightRevealToggle:)];
    
    self.navigationItem.rightBarButtonItem = revealButtonItem;
    
}

- (void) makeNavBarTransparent {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}


- (void) loadGifsFromCSV
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_gifs" ofType:@"csv"];
    NSError *error = nil;
    
    @try {
        
        NSArray *csvArray = [NSArray arrayWithContentsOfCSVFile:path];
        if (csvArray == nil) {
            DDLogError(@"Error parsing file: %@", error);
            return;
        } else {
            EboticonGif *currentGif = [[EboticonGif alloc] init];
            NSMutableArray *element = [[NSMutableArray alloc]init];
            
            for(int i=0; i<[csvArray count];i++){
                element = [csvArray objectAtIndex: i];
                DDLogDebug(@"Element %i = %@", i, element);
                DDLogDebug(@"Element Count = %lu", (unsigned long)[element count]);
                
                for(int j=0; j<[element count];j++) {
                    NSString *value = [element objectAtIndex: j];
                    DDLogDebug(@"Value %i = %@", j, value);
                    switch (j) {
                        case 0:
                            [currentGif setFileName:value];
                            break;
                        case 1:
                            [currentGif setStillName:value];
                            break;
                        case 2:
                            [currentGif setDisplayName:value];
                            break;
                        case 3:
                            [currentGif setCategory:value];
                            break;
                        case 4:
                            [currentGif setMovFileName:value];
                            break;
                        case 5:
                            [currentGif setDisplayType:value];
                            break;
                        case 6:
                            [currentGif setEmotionCategory:value];
                            break;
                        default:
                            DDLogWarn(@"Index out of bounds");
                            break;
                    }
                    //[_eboticonGifs addObject:currentGif];
                }
                [_eboticonGifs addObject:currentGif];
                currentGif = [[EboticonGif alloc] init];
                DDLogDebug(@"Eboticon: %@", currentGif);
                DDLogDebug(@"Eboticon filename:%@ stillname:%@ displayname:%@ category:%@ displayType:%@ emotionCategory%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category], [currentGif displayType], [currentGif emotionCategory]);
                /**
                 if(nil != _eboticonGifs){
                 [_eboticonGifs addObject:currentGif];
                 } else {
                 _eboticonGifs = [NSMutableArray arrayWithObject:currentGif];
                 }
                 **/
            }
            
            for (int a = 0; a< [_eboticonGifs count]; a++){
                DDLogDebug(@"Eboticon filename:%@ stillname:%@ displayname:%@ category:%@ movie:%@ displayname:%@ emotionCategory%@", [[_eboticonGifs objectAtIndex:a] fileName], [[_eboticonGifs objectAtIndex:a] stillName], [[_eboticonGifs objectAtIndex:a] displayName], [[_eboticonGifs objectAtIndex:a] category],[[_eboticonGifs objectAtIndex:a] movFileName], [[_eboticonGifs objectAtIndex:a] displayType], [[_eboticonGifs objectAtIndex:a] emotionCategory]);
                
            }
            
        }
        
    }
    @catch (NSException *exception) {
        DDLogError(@"Unable to load csv: %@",exception);
    }
    
    
}

-(void) populateGifArraysFromCSV
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
            NSString * gifCaption = [currentGif category];          //Caption
            
            //NSLog(@"Category: %@", gifCategory);
            // NSLog(@"Caption: %@", gifCaption);
            
             // NSLog(@"Current Gif filename:%@ stillname:%@ displayname:%@ category:%@ movie:%@ displayType:%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category], [currentGif movFileName], [currentGif displayType]);
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
        }//End for

        
        /*
        
        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];
            DDLogDebug(@"Current Gif filename:%@ stillname:%@ displayname:%@ category:%@ movie:%@ displayType:%@ emotionCategory%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category], [currentGif movFileName], [currentGif displayType], [currentGif emotionCategory]);
            if([[currentGif category] isEqual:CATEGORY_CAPTION]) {
                DDLogDebug(@"Adding eboticon to category Caption:%@",[currentGif fileName]);
                [_captionImages addObject:[_eboticonGifs objectAtIndex:i]];
            } else if([[currentGif category] isEqual:CSV_CATEGORY_NO_CAPTION]) {
                DDLogDebug(@"Adding eboticon to category noCaption:%@",[currentGif fileName]);
                [_noCaptionImages addObject:[_eboticonGifs objectAtIndex:i]];
            } else {
                DDLogDebug(@"Eboticon category not recognized for eboticon: %@ with category:%@",[currentGif fileName],[currentGif category]);
            }
        }
         */
        
        //_allImages = [[_captionImages arrayByAddingObjectsFromArray:_noCaptionImages] mutableCopy];
        _allImages = [_eboticonGifs mutableCopy];
        _recentImages = [self getRecentGifs];
        
    } else {
        DDLogWarn(@"Eboticon Gif array count is less than zero.");
    }
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = (NSIndexPath *) sender;
    NSMutableArray *imageNames;
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        imageNames = _captionImages;
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        imageNames =  _noCaptionImages;
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        imageNames =  _recentImages;
    } else {
        imageNames = _allImages;
    }
    
    GifDetailViewController *gifDetailViewController = (GifDetailViewController*) segue.destinationViewController;
    gifDetailViewController.imageNames = imageNames;
    gifDetailViewController.index = indexPath.row;
    
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
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        DDLogDebug(@"Returning Caption");
        return _captionImages.count;
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        DDLogDebug(@"Returning No Caption");
        return _noCaptionImages.count;
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        DDLogDebug(@"Returning No Caption");
        return _recentImages.count;
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
    
    
    DDLogDebug(@"Returning All");
    return _allImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EboticonGifCell *gifCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    
    //rounded corners
    gifCell.layer.masksToBounds = YES;
    gifCell.layer.cornerRadius = 6;
    
    
    EboticonGif *eboticonGifName = [self getCurrentEboticonGif:[indexPath row]];
    [gifCell setCellGif:eboticonGifName];
    
    return gifCell;
}

-(UIImage *) getCellImage: (long)row
{
    UIImage *image;
    
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        image = [UIImage imageNamed:_captionImages[row]];
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        image = [UIImage imageNamed:_noCaptionImages[row]];
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        image = [UIImage imageNamed:_recentImages[row]];
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
        image = [UIImage imageNamed:_allImages[row]];
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
    } else {
        gifName = _allImages[row];
        DDLogDebug(@"Image name is %@",gifName);
    }
    
    return gifName;
}


-(EboticonGif *) getCurrentEboticonGif: (long)row
{
    EboticonGif *currentGifObject = [[EboticonGif alloc]init];
    
   // NSLog(@"%@",_gifCategory);
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        currentGifObject = _captionImages[row];
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        currentGifObject = _noCaptionImages[row];
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        currentGifObject = _recentImages[row];
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
        currentGifObject = _allImages[row];
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

#pragma mark -
#pragma mark UICollectionViewDelegate

-(void) collectionView:(UICollectionView *) collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSMutableArray *imageNames;
    
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        imageNames = _captionImages;
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        imageNames = _noCaptionImages;
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        imageNames = _recentImages;
    }else if ([_gifCategory isEqual: CATEGORY_SMILE]){
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
        _gifCategory = CATEGORY_ALL;
        imageNames = _allImages;
    }
    
    GifDetailViewController *gifDetailViewController =  [[GifDetailViewController alloc] initWithNibName:@"GifDetailView" bundle:nil];
    
    NSLog(@"Row: %ld", (long)indexPath.row);
    NSLog(@"Passing images count: %ld", (long)[imageNames count]);
    NSLog(@"Category: %@", _gifCategory);
    
    
    gifDetailViewController.gifCategory = _gifCategory;
    gifDetailViewController.index = indexPath.row;
    gifDetailViewController.imageNames = imageNames;
    
    [[self navigationController] pushViewController:gifDetailViewController animated:YES];
    
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

@end
