//
//  ShopViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopTableCell.h"
#import "ShopDetailCollectionViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DDLog.h"



//In-app purchases (IAP) libraries
#import "EboticonIAPHelper.h"
#import <StoreKit/StoreKit.h>

static const int ddLogLevel = LOG_LEVEL_ERROR;
#define CURRENTSCREEN @"Shop Screen"




@interface ShopViewController () <UITableViewDataSource, UITableViewDelegate, KIImagePagerDelegate, KIImagePagerDataSource>{
    IBOutlet KIImagePager *_imagePager;
    NSNumberFormatter * _priceFormatter;
}

@end

@implementation ShopViewController

- (void)reload {
    NSLog(@"Reloading...");
    _products = nil;
    [self.inAppPurchaseTable reloadData];
    [[EboticonIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.inAppPurchaseTable reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Restore Purchases");
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.inAppPurchaseTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}


- (void) restoreButtonTapped:(id)sender {
    
    NSLog(@"Restore Purchases");
    [[EboticonIAPHelper sharedInstance] restoreCompletedTransactions];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"products count: %lu", (unsigned long)_products.count);
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopTableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"shopCell"];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ShopTableCell" bundle:nil] forCellReuseIdentifier:@"shopCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"shopCell"];
    }
    
    
    NSLog(@"packImages: %@", [_packImages objectAtIndex:indexPath.row]);
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ShopTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure Cell
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    cell.packTitle.text = [product.localizedTitle uppercaseString];
    
    [_priceFormatter setLocale:product.priceLocale];
    NSDecimalNumber *freeCost = [NSDecimalNumber decimalNumberWithDecimal:
                                 [[NSNumber numberWithFloat:0.0f] decimalValue]];
    
    if ([product.price compare:freeCost] == NSOrderedSame)
    {
        cell.packCost.text = @"FREE";
    }else{
        cell.packCost.text = @"PREVIEW";
    }
    
    
    if ([[EboticonIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        
        [cell.packCost setFont: [UIFont systemFontOfSize:7]];
        cell.packCost.text = @"PURCHASED";
    }
    
    //Set Image
    if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.churchpack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:2]];
    }
    if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.churchpack2"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:2]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greekpack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:1]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greekpack2"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:1]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.ratchpack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:3]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.ratchpack2"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:3]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.baepack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:0]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.ratchpack3"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:3]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.greetingspack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:4]];
    }
    else if([product.productIdentifier isEqualToString:@"com.eboticon.Eboticon.holidaypack1"]){
        cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:5]];
    }
}



#pragma mark -

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self shopKeyPressed:indexPath.row];
    
    // Configure Cell
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    ShopDetailCollectionViewController *shopDetailCollectionViewController =  [[ShopDetailCollectionViewController alloc] initWithNibName:@"ShopDetailView" bundle:nil];
    shopDetailCollectionViewController.product = product;
    
    NSLog(@"The shop productIdentifier is %@",product.productIdentifier);
    
    [[self navigationController] pushViewController:shopDetailCollectionViewController animated:YES];
}

#pragma mark -


- (void) shopKeyPressed:(NSInteger)tag {
    
    NSLog(@"The shop category name is %ld",(long)tag);
    
}

#pragma mark - KIImagePager DataSource
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _imagePager.imageCounterDisabled = YES;
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    
    /******** fit background image to the imagePager's frame *********/
    
    UIGraphicsBeginImageContext(_imagePager.frame.size);
    [[UIImage imageNamed:@"banner1.png"] drawInRect:_imagePager.bounds];
    UIImage *imageFirstSlider = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _imagePager.backgroundColor = [[UIColor alloc] initWithPatternImage:imageFirstSlider];
    _imagePager.slideshowTimeInterval = 5.5f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
    
    [_imagePager setBounces:NO];
    
    UIImageView *imageView = [[UIImageView alloc]
                              initWithFrame:CGRectMake(10,0,3,20)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = NO;
    imageView.image = [UIImage imageNamed:@"NavigationBarLogo"];
    self.navigationItem.titleView = imageView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSTimer*)createTimer {
    // create timer on run loop
    return [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
}

- (void)timerTicked:(NSTimer*)timer {
    NSLog(@"%i", (int)_products.count);
    if (_products.count > 0){
        [self actionStop:nil];
        [self.inAppPurchaseTable reloadData];
    }
}

- (void)actionStop:(id)sender {
    // stop the timer
    [myTimer invalidate];
    myTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"MasterBackground2.0.png"].CGImage;     //Add Background without repeating
    
    // Create the data model
    _packImages = @[@"BaePackIcon", @"GreekPackIcons", @"ChurchPackIcon", @"RatchPackIcon", @"GreetingsPackIcon",@"holidaypackicon"];
    
    //Add Restore Button
    UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restoreButtonTapped:)];
    self.navigationItem.rightBarButtonItem = restoreButton;
    
    //Create Pull to Refresh
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.inAppPurchaseTable;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    if (_products == nil){
        _products = [[NSArray alloc]init];
        myTimer = [self createTimer];
    } else {
        [self.inAppPurchaseTable reloadData];
    }
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:CURRENTSCREEN forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
    
}

- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    if (arrImagePagerImages.count == 0){
        return @[[UIImage imageNamed:@"banner1.png"]];
    } else {
        return arrImagePagerImages;
    }
    
    return nil;
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager *)pager
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *) captionForImageAtIndex:(NSUInteger)index inPager:(KIImagePager *)pager
{
    /*  return @[
     @"First screenshot",
     @"Another screenshot",
     @"Last one! ;-)"
     ][index];
     */
    
    return false;
    
}

#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    //NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    // NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
