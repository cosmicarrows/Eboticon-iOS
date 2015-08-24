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

//In-app purchases (IAP) libraries
#import "EboticonIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface ShopViewController () <UITableViewDataSource, UITableViewDelegate, KIImagePagerDelegate, KIImagePagerDataSource>{
    IBOutlet KIImagePager *_imagePager;
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"MasterBackground2.0.png"].CGImage;     //Add Background without repeating
    
    // Create the data model
    _packTitles = @[@"CHURCH PACK", @"GREEK PACK"];
    _packImages = @[@"PackChurchIcon", @"PackGreekIcon"];
    _packCosts  = @[@"$0.99", @"$0.99"];
    
    //Create Pull to Refresh
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.inAppPurchaseTable;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;

    
    
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
}

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
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.inAppPurchaseTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[EboticonIAPHelper sharedInstance] buyProduct:product];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImageView *imageView = [[UIImageView alloc]
                              initWithFrame:CGRectMake(0,0,3,44)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = NO;
    imageView.image = [UIImage imageNamed:@"NavigationBarLogo"];
    self.navigationItem.titleView = imageView;
    
    
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
    NSLog(@"packTitles: %@", [_packTitles objectAtIndex:indexPath.row]);
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ShopTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure Cell
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    cell.packTitle.text = [product.localizedTitle uppercaseString];
    
    [_priceFormatter setLocale:product.priceLocale];
    cell.packCost.text = [_priceFormatter stringFromNumber:product.price];
    
    
    if ([[EboticonIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.packPurchased.text = @"purchased";
    } else {
        cell.packPurchased.text = @"";
    }

    //cell.packCost.text  = [NSString stringWithFormat:@"$%@",[product.price stringValue]];
    cell.packImage.image = [UIImage imageNamed:[_packImages objectAtIndex:indexPath.row]];
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
    shopDetailCollectionViewController.productIdentifier = product.productIdentifier;
    
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
    _imagePager.slideshowTimeInterval = 5.5f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
}

- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    return @[
             @"http://www.inclingconsulting.com/eboticon/store/banner1.png",
             @"http://www.inclingconsulting.com/eboticon/store/banner2.png",
             @"http://www.inclingconsulting.com/eboticon/store/banner3.png"
             ];
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
