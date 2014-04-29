//
//  GifViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/27/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

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

#define RECENT_GIFS_KEY @"listOfRecentGifs"
#define CATEGORY_RECENT @"Recent"
#define CATEGORY_CAPTION @"Caption"
#define CATEGORY_NO_CAPTION @"NoCaption"


@interface GifCollectionViewController () {
    UIToolbar *_toolbar;
    NSMutableArray *_toolbarButtons;
    NSMutableArray *_eboticonGifs;
}

@property (nonatomic, strong) GifCollectionViewFlowLayout *layout;

@end

@implementation GifCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"Gif Category is %@",_gifCategory);
    
    if([_gifCategory isEqualToString:CATEGORY_RECENT])
    {
        UIBarButtonItem *clearbutton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Clear"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(clearRecentGifs)];
        self.navigationItem.rightBarButtonItem = clearbutton;
    }
   
    
    //Populate Gif Arrays
    //[self populateGifArrays];
    
    //Load Gif csv file
    NSLog(@"Eboticon Gif size %lu",(unsigned long)[_eboticonGifs count]);
    _eboticonGifs = [[NSMutableArray alloc] init];
    [self loadGifsFromCSV];
    NSLog(@"Gif Array count %lu",(unsigned long)[_eboticonGifs count]);
    [self populateGifArraysFromCSV];

    // set up toolbar
    //[self addToolbar];
    
    //Add background image
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Ebo_Background.png"]];
    
    //Add Layout Control
    self.layout = [[GifCollectionViewFlowLayout alloc]init];
    [self.collectionView setCollectionViewLayout:self.layout animated:YES];
    
    //GOOGLE ANALYTICS
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:_gifCategory forKey:kGAIScreenName]build]];
    
}

- (void) populateGifArrays
{
    _captionImages = [@[@"FinalDead.gif",
                        @"FinalGoneWithTheWind.gif",
                        @"FINALGottaGo.gif",
                        @"FinalHaveASeat.gif",
                        @"FinalICant.gif",
                        @"FinalLMAOKneeSlap.gif",
                        @"FinalLMAOlong.gif",
                        @"FINALLMAOShort.gif",
                        @"FinalOneSec.gif",
                        @"FinalTurnUp.gif",
                        @"FinalTwerkTeam.gif",
                        @"FinalWave.gif",
                        @"FinalWontHeDoIt.gif",
                        @"FinalWTH.gif",
                        @"FinalYouMad.gif"] mutableCopy];
    
    _noCaptionImages = [@[@"FinalCrying.gif",
                          @"FinalDeadNT.gif",
                          @"FinalGoneWithTheWindNT.gif",
                          @"FINALGottaGoNT.gif",
                          @"FinalHaveASeatNT.gif",
                          @"FinalICantNT.gif",
                          @"FinalLMAOKneeSlapNT.gif",
                          @"FinalLMAOlongNT.gif",
                          @"FINALLMAOShortNT.gif",
                          @"FinalOneSecNT.gif",
                          @"FinalTurnUpNT.gif",
                          @"FinalTwerkTeamNT.gif",
                          @"FinalWaveNT.gif",
                          @"FinalWontHeDoItNT.gif",
                          @"FinalYouMadNT.gif",
                          @"FinalWTHNT.gif"] mutableCopy];
    
    _allImages = [[_captionImages arrayByAddingObjectsFromArray:_noCaptionImages] mutableCopy];
    _recentImages = [self getRecentGifs];

    
}

- (void) loadGifsFromCSV
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_gifs" ofType:@"csv"];
    NSError *error = nil;
    
    @try {
        
        NSArray *csvArray = [NSArray arrayWithContentsOfCSVFile:path];
        if (csvArray == nil) {
            NSLog(@"Error parsing file: %@", error);
            return;
        } else {
            //NSLog(@"Number of Elements found: %lu", (unsigned long)[rows count]);
            EboticonGif *currentGif = [[EboticonGif alloc] init];
            NSMutableArray *element = [[NSMutableArray alloc]init];
            
            for(int i=0; i<[csvArray count];i++){
                element = [csvArray objectAtIndex: i];
                //NSLog (@"Element %i = %@", i, element);
                //NSLog (@"Element Count = %lu", (unsigned long)[element count]);
                
                for(int j=0; j<[element count];j++) {
                    NSString *value = [element objectAtIndex: j];
                    //NSLog (@"Value %i = %@", j, value);
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
                        default:
                            NSLog(@"Index out of bounds");
                            break;
                    }
                    //[_eboticonGifs addObject:currentGif];
                }
                [_eboticonGifs addObject:currentGif];
                currentGif = [[EboticonGif alloc] init];
                //NSLog(@"Eboticon: %@", currentGif);
                //NSLog(@"Eboticon filename:%@ stillname:%@ displayname:%@ category:%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category]);
                /**
                if(nil != _eboticonGifs){
                    [_eboticonGifs addObject:currentGif];
                } else {
                    _eboticonGifs = [NSMutableArray arrayWithObject:currentGif];
                }
                 **/
            }
            /**
            for (int a = 0; a< [_eboticonGifs count]; a++){
                NSLog(@"Eboticon filename:%@ stillname:%@ displayname:%@ category:%@", [[_eboticonGifs objectAtIndex:a] fileName], [[_eboticonGifs objectAtIndex:a] stillName], [[_eboticonGifs objectAtIndex:a] displayName], [[_eboticonGifs objectAtIndex:a] category]);
                
            }
             **/
        }
         
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to load csv: %@",exception);
    }
    
    
}

-(void) populateGifArraysFromCSV
{
    if([_eboticonGifs count] > 0){
        EboticonGif *currentGif = [EboticonGif alloc];
        _captionImages = [[NSMutableArray alloc]init];
        _noCaptionImages = [[NSMutableArray alloc]init];
        _allImages = [[NSMutableArray alloc]init];
        _recentImages = [[NSMutableArray alloc]init];

        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];
            NSLog(@"Current Gif filename:%@ stillname:%@ displayname:%@ category:%@", [currentGif fileName], [currentGif stillName], [currentGif displayName], [currentGif category]);
            if([[currentGif category] isEqual:CATEGORY_CAPTION]) {
                NSLog(@"Adding eboticon to category Caption:%@",[currentGif fileName]);
                [_captionImages addObject:[_eboticonGifs objectAtIndex:i]];
            } else if([[currentGif category] isEqual:CATEGORY_NO_CAPTION]) {
                NSLog(@"Adding eboticon to category noCaption:%@",[currentGif fileName]);
                [_noCaptionImages addObject:[_eboticonGifs objectAtIndex:i]];
            } else {
                NSLog(@"Eboticon category not recognized for eboticon: %@ with category:%@",[currentGif fileName],[currentGif category]);
            }
        }
        _allImages = [[_captionImages arrayByAddingObjectsFromArray:_noCaptionImages] mutableCopy];
        _recentImages = [self getRecentGifs];
        
    } else {
        NSLog(@"Eboticon Gif array count is less than zero.");
    }
}
-(void) addToolbar
{
    //Create toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //Create buttons
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *enlarge = [[UIBarButtonItem alloc] initWithTitle:@"Enlarge" style:UIBarButtonItemStyleBordered target:self action:nil];
    _toolbarButtons = [NSMutableArray arrayWithObjects:shareButton, enlarge, nil];

    
    [self.view addSubview:_toolbar];
    [self.view bringSubviewToFront:_toolbar];
    [_toolbar setItems:_toolbarButtons];
}

-(NSMutableArray*) getRecentGifs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentGifs = [[defaults objectForKey:RECENT_GIFS_KEY] mutableCopy];
    NSLog(@"getRecentGifs: %@",recentGifs);
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
    NSLog(@"Clear Recents");
    [self.collectionView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSLog(@"Returning Caption");
        return _captionImages.count;
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        NSLog(@"Returning No Caption");
        return _noCaptionImages.count;
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        NSLog(@"Returning No Caption");
        return _recentImages.count;
    }
    NSLog(@"Returning All");
    return _allImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EboticonGifCell *gifCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    long gifRow = [indexPath row];
    EboticonGif *eboticonGifName = [self getCurrentEboticonGif:gifRow];
    //long gifIndex = [self findFilenameIndex:eboticonGifName];
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
    } else {
        image = [UIImage imageNamed:_allImages[row]];
    }
    
    return image;
}

-(NSString *) getImageName: (long)row
{
    NSString *gifName;
    
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        gifName = _captionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        gifName = _noCaptionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        gifName = _recentImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else {
        gifName = _allImages[row];
        //NSLog(@"Image name is %@",gifName);
    }
    
    return gifName;
}

-(EboticonGif *) getCurrentEboticonGif: (long)row
{
    EboticonGif *gifName = [[EboticonGif alloc]init];
    
    if([_gifCategory isEqual: CATEGORY_CAPTION]){
        gifName = _captionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_NO_CAPTION]){
        gifName = _noCaptionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: CATEGORY_RECENT]){
        gifName = _recentImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else {
        gifName = _allImages[row];
        //NSLog(@"Image name is %@",gifName);
    }
    
    return gifName;
}

-(long) findFilenameIndex: (EboticonGif*) filename
{
    long index = -1;
    EboticonGif *test = [[EboticonGif alloc]init];
    
    for(int i = 0; i<[_eboticonGifs count]; i++){
        test = [_eboticonGifs objectAtIndex:i];
        if(nil != test && [test isEqual:filename]){
            NSLog(@"Filename found: %@ Index is %d",[filename getFileName], i);
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
    //EboticonGifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    //NSString *gifName = [self getImageName:[indexPath row]];
    
    [self performSegueWithIdentifier:@"toGifDetailViewController" sender:indexPath];
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}


@end
