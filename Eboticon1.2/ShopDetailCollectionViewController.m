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

//static const int ddLogLevel = LOG_LEVEL_ERROR;
static const int ddLogLevel = LOG_LEVEL_DEBUG;

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
    [self loadGifsFromCSV];
    DDLogDebug(@"Gif Array count %lu",(unsigned long)[_eboticonGifs count]);
    
    //Sets the navigation bar title
    [self.navigationItem setTitle:[self.product.localizedTitle uppercaseString]];
    
    //Create Pack Gifs object
    [self createPackGifs];
    

    //Add Buy Button
    if ([[EboticonIAPHelper sharedInstance] productPurchased:self.product.productIdentifier]) {
        DDLogDebug(@"Not purchased");
        
    } else {
        //Add Share Button
        UIBarButtonItem *buyButton = [[UIBarButtonItem alloc] initWithTitle:@"Buy" style:UIBarButtonItemStylePlain target:self action:@selector(buyButtonTapped:)];
        self.navigationItem.rightBarButtonItem = buyButton;
    }
    

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"ShopDetailCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
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

- (void) loadGifsFromCSV
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"eboticon_purchase_gifs" ofType:@"csv"];

    
    @try {
        
        NSArray *csvArray = [NSArray arrayWithContentsOfCSVFile:path];
        if (csvArray == nil) {
            NSLog(@"Error parsing file");
            return;
        } else {
            EboticonGif *currentGif = [[EboticonGif alloc] init];
            NSMutableArray *element = [[NSMutableArray alloc]init];
            
            for(int i=0; i<[csvArray count];i++){
                element = [csvArray objectAtIndex: i];
                DDLogDebug(@"Element %i = %@", i, element);
               // DDLogDebug(@"Element Count = %lu", (unsigned long)[element count]);
                
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
                     //       DDLogWarn(@"Index out of bounds");
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
            
        }
        
    }
    @catch (NSException *exception) {
        DDLogError(@"Unable to load csv: %@",exception);
    }
    
    
}

-(void) createPackGifs
{
    if([_eboticonGifs count] > 0){
        EboticonGif *currentGif = [EboticonGif alloc];
        
        for(int i = 0; i < [_eboticonGifs count]; i++){
            currentGif = [_eboticonGifs objectAtIndex:i];
            
            NSString * gifCategory = [currentGif emotionCategory]; //Category
            
             DDLogDebug(@"gifCategory: %@", gifCategory);
            
            if([self.product.productIdentifier isEqual:gifCategory]) {
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
    }
}


#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_packGifs count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (ShopDetailCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    EboticonGif *currentGif = [_packGifs objectAtIndex:indexPath.row];
    NSLog(@"gif filename %@", currentGif.getFileName);
    
    NSString * path = [[NSBundle mainBundle] pathForResource:currentGif.getFileName ofType:nil];
    NSData * data = [NSData dataWithContentsOfFile:path];
    FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:data];

    cell.gifImageView.animatedImage = image;

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"Select %ld",(long)indexPath.row);
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
