//
//  GifViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/27/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import "GifCollectionViewController.h"
#import "GifCollectionViewFlowLayout.h"
#import "GifCell.h"
#import "GifDetailViewController.h"
#import "OLImage.h"

@interface GifCollectionViewController () {
    UIToolbar *_toolbar;
    NSMutableArray *_toolbarButtons;
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
    
    /**
    _captionImages = [@[@"haveaseat.gif",
                        @"icant.gif",
                        @"turnup.gif",
                        @"youmad.gif",
                        @"gottago.gif"] mutableCopy];
    _noCaptionImages = [@[@"LMAOKneeSlap.gif",
                          @"LMAOlong.gif",
                          @"LMAOshort.gif",
                          @"crying.gif",
                          @"wave.gif"] mutableCopy];
     **/
    
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
    NSLog(@"Gif Category is %@",_gifCategory);

    // set up toolbar
    //[self addToolbar];
    
    //Add Layout Control
    self.layout = [[GifCollectionViewFlowLayout alloc]init];
    [self.collectionView setCollectionViewLayout:self.layout animated:YES];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = (NSIndexPath *) sender;
    NSMutableArray *imageNames;
    if([_gifCategory isEqual: @"Caption"]){
        imageNames = _captionImages;
    } else if ([_gifCategory isEqual: @"NoCaption"]){
        imageNames =  _noCaptionImages;
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
    if([_gifCategory isEqual: @"Caption"]){
        NSLog(@"Returning Caption");
        return _captionImages.count;
    } else if ([_gifCategory isEqual: @"NoCaption"]){
        NSLog(@"Returning No Caption");
        return _noCaptionImages.count;
    }
    NSLog(@"Returning All");
    return _allImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    
    long row = [indexPath row];

    //UIImage *image = [self getCellImage:row];
    NSString *gifName = [self getImageName:row];
    
    /**
    UIImage *image;
    long row = [indexPath row];
    NSString *gifName;
    
    if([_gifCategory isEqual: @"Caption"]){
        //NSLog(@"Returning Caption");
        image = [UIImage imageNamed:_captionImages[row]];
        gifName = _captionImages[row];
        NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: @"NoCaption"]){
        //NSLog(@"Returning No Caption");
        image = [UIImage imageNamed:_noCaptionImages[row]];
        gifName = _noCaptionImages[row];
        NSLog(@"Image name is %@",gifName);
    } else {
        image = [UIImage imageNamed:_allImages[row]];
        gifName = _allImages[row];
        NSLog(@"Image name is %@",gifName);
    }
     **/
    
    //cell.gifImage.image = image;
    //cell.gifImage = [[OLImageView alloc] initWithImage:[OLImage imageNamed:test]];
    
    //[cell.gifImage setImage:image];
    //[cell.gifImage startAnimating];
    //NSLog(@"Is animating: %d", cell.gifImage.isAnimating);
    //[cell animateGif];
    
    gifName = [gifName substringWithRange:NSMakeRange(0, [gifName length] - 4)];
    NSString *filepath  = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
    NSData *GIFDATA = [NSData dataWithContentsOfFile:filepath];
    //cell.gifImage.image = [OLImage imageWithData:GIFDATA];
    [cell setCellGif:GIFDATA];
    //[cell setCellImage:gifName];
    //[cell setGifImageView:[[OLImageView alloc] initWithImage:[OLImage imageNamed:gifName]]];
  
    
    return cell;
}

-(UIImage *) getCellImage: (long)row
{
    UIImage *image;
    
    if([_gifCategory isEqual: @"Caption"]){
        //NSLog(@"Returning Caption");
        image = [UIImage imageNamed:_captionImages[row]];
    } else if ([_gifCategory isEqual: @"NoCaption"]){
        //NSLog(@"Returning No Caption");
        image = [UIImage imageNamed:_noCaptionImages[row]];
    } else {
        image = [UIImage imageNamed:_allImages[row]];
    }
    
    return image;
}

-(NSString *) getImageName: (long)row
{
    NSString *gifName;
    
    if([_gifCategory isEqual: @"Caption"]){
        gifName = _captionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else if ([_gifCategory isEqual: @"NoCaption"]){
        gifName = _noCaptionImages[row];
        //NSLog(@"Image name is %@",gifName);
    } else {
        gifName = _allImages[row];
        //NSLog(@"Image name is %@",gifName);
    }
    
    return gifName;
}

#pragma mark - 
#pragma mark UICollectionViewDelegate

-(void) collectionView:(UICollectionView *) collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Gif Selected is %@",indexPath);
    GifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AnimatedGifCell" forIndexPath:indexPath];
    NSLog(@"Is animating: %d", [cell isCellAnimating]);
    NSString *gifName = [self getImageName:[indexPath row]];
    NSLog(@"Gif Name: %@", gifName);

    
    /**
    NSString *gifName = [self getImageName:[indexPath row]];
    NSURL *url = [self fileToURL:gifName];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[ UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
   
    [self presentViewController:controller animated:YES completion:nil];
    **/
    
    [self performSegueWithIdentifier:@"toGifDetailViewController" sender:indexPath];
    
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}


@end
