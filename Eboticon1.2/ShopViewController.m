//
//  ShopViewController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 7/29/15.
//  Copyright (c) 2015 Incling. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController () <UITableViewDataSource, UITableViewDelegate, KIImagePagerDelegate, KIImagePagerDataSource>{
    IBOutlet KIImagePager *_imagePager;
}

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"MasterBackground2.0.png"].CGImage;     //Add Background without repeating
    
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (! cell) {
        NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"ShopTableCell" owner:nil options:nil];
        cell = [parts objectAtIndex:0];
    }
    
    return cell;
}
#pragma mark -

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
