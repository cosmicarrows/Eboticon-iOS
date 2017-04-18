/*

 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*/

#import "RightViewController.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"
#import "SidebarCategoryTableViewCell.h"
#import "TTSwitch.h"
#import "FilterData.h"


//Name of Categories in the CSV File
#define CATEGORY_ALL @"all"
#define CATEGORY_RECENT @"Recent"
#define CATEGORY_PURCHASED @"Purchased"
#define CATEGORY_SMILE @"happy"
#define CATEGORY_NOSMILE @"not_happy"
#define CATEGORY_HEART @"love"
#define CATEGORY_GIFT @"greeting"
#define CATEGORY_EXCLAMATION @"exclamation"


@interface RightViewController ()
{
    NSNumber *_captionState;
}

//Caption Switch
@property (strong, nonatomic) TTSwitch *captionSwitch;


// Private Methods:
- (IBAction)replaceMe:(id)sender;
- (IBAction)replaceMeCustom:(id)sender;
- (IBAction)toggleFront:(id)sender;
@end

@implementation RightViewController

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
    
    // Create the data model for Table
    _categoryTitles = @[@"ALL", @"LOVE", @"HAPPY", @"UNHAPPY", @"EXCLAMATION", @"GREETING", @"SKIN TONE"];
    _categoryImages = @[@"Earth", @"HeartSmaller", @"HappySmaller", @"NotHappySmaller", @"ExclamationSmaller", @"GiftBoxSmaller", @"SkinToneIcon"];
    
    //Create Caption/No Caption Switch
    self.captionSwitch = [[TTSwitch alloc] initWithFrame:(CGRect){ 100.0f, 125.0f, 100.0f, 20.0f }];
    [[TTSwitch appearance] setTrackImage:[UIImage imageNamed:@"round-switch-track"]];
    [[TTSwitch appearance] setOverlayImage:[UIImage imageNamed:@"round-switch-overlay"]];
    [[TTSwitch appearance] setTrackMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [[TTSwitch appearance] setThumbImage:[UIImage imageNamed:@"round-switch-thumb"]];
    [[TTSwitch appearance] setThumbHighlightImage:[UIImage imageNamed:@"round-switch-thumb-highlight"]];
    [[TTSwitch appearance] setThumbMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [[TTSwitch appearance] setThumbInsetX:-6.0f];
    [[TTSwitch appearance] setThumbOffsetY:-6.0f];
    [self.captionSwitch addTarget:self action:@selector(changeCaptionSwitch:) forControlEvents:UIControlEventValueChanged];
    
    //Set Caption Switch to On
    self.captionSwitch.on = true;
     _captionState = @(1);
    FilterData *sharedFilterData = [FilterData sharedInstance];
    sharedFilterData.captionState = @(1);
    
    //Show Caption Switch
    [self.view addSubview: self.captionSwitch];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
}





#pragma mark - Key methods

- (void)changeCaptionSwitch:(id)sender{
    FilterData *sharedFilterData = [FilterData sharedInstance];
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
        _captionState = @(1);
        sharedFilterData.captionState = @(1);
     
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
        _captionState = @(0);
        sharedFilterData.captionState = @(0);
    }
    

    
}


#pragma mark -



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#define TestStatusBarStyle 0   // <-- set this to 1 to test status bar style
#if TestStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#endif

#define TestStatusBarHidden 0  // <-- set this to 1 to test status bar hidden
#if TestStatusBarHidden
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#endif



- (IBAction)replaceMe:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    RightViewController *replacement = [[RightViewController alloc] init];
    [self.revealViewController setRightViewController:replacement animated:YES];
}

- (IBAction)replaceMeCustom:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    RightViewController *replacement = [[RightViewController alloc] init];
    replacement.wantsCustomAnimation = YES;
    [self.revealViewController setRightViewController:replacement animated:YES];
}


- (IBAction)toggleFront:(id)sender
{
    //MapViewController *mapViewController = [[MapViewController alloc] init];
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    //[self.revealViewController pushFrontViewController:navigationController animated:YES];
}


- (IBAction) recentKeyPressed:(UIButton*)sender {
    
     NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //Change category
    SWRevealViewController *revealController = self.revealViewController;
    NSString *categoryName = CATEGORY_RECENT;
    NSLog(@"%s -- category: %@", __PRETTY_FUNCTION__, categoryName);
    
    TabViewController *tabBarController = [[TabViewController alloc] initWithCategory:categoryName];
    [revealController pushFrontViewController:tabBarController animated:YES];
    
}


- (IBAction) purchasedKeyPressed:(UIButton*)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
 
    
    //Change category
    SWRevealViewController *revealController = self.revealViewController;
    NSString *categoryName = CATEGORY_PURCHASED;
    NSLog(@"%s -- category: %@", __PRETTY_FUNCTION__, categoryName);

    TabViewController *tabBarController = [[TabViewController alloc] initWithCategory:categoryName];
    [revealController pushFrontViewController:tabBarController animated:YES];
    
    

}


- (void) categoryKeyPressed:(NSInteger)tag {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //switches to user's next category
 
    
    //Change category
    SWRevealViewController *revealController = self.revealViewController;
    MainViewController *mainViewController = [[MainViewController alloc] init];
    NSString *categoryName = @"";
    
    switch ((int)tag)
    {
        case 0:
        {
            categoryName = CATEGORY_ALL;
            break;
        }
        case 1:
        {
            categoryName = CATEGORY_HEART;
            break;
        }
            
        case 2:
        {
            
            categoryName = CATEGORY_SMILE;
            break;
        }
        case 3:
        {
            categoryName =  CATEGORY_NOSMILE;
            break;
        }
        case 4:
        {
            categoryName = CATEGORY_EXCLAMATION;
            break;
        }
        case 5:
        {
             categoryName = CATEGORY_GIFT;
             break;
        }
    }
        
        NSLog(@"The Category name is %@",categoryName);
        NSLog(@"The Caption state is %ld",(unsigned long)[_captionState  integerValue]);
        mainViewController.gifCategory = categoryName;
        mainViewController.captionState = _captionState;
    
        TabViewController *tabBarController = [[TabViewController alloc] initWithCategory:categoryName caption:_captionState];
    
        //UINavigationController *navigationMainController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        [revealController pushFrontViewController:tabBarController animated:YES];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@" %ld", [_categoryTitles count]);
    return [_categoryTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"***cellForRowAtIndexPath %ld", (long)indexPath.row);
    
    SidebarCategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"SidebarCategoryCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    }
    


    
    //NSLog(@"categoryImages: %@", [_categoryImages objectAtIndex:indexPath.row]);
    //NSLog(@"categoryTitles: %@", [_categoryTitles objectAtIndex:indexPath.row]);

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SidebarCategoryTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure Cell
    cell.categoryLabel.text = [_categoryTitles objectAtIndex:indexPath.row];
    cell.categoryImage.image = [UIImage imageNamed:[_categoryImages objectAtIndex:indexPath.row]];
}


#pragma mark -

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row < 6){
         [self categoryKeyPressed:indexPath.row];
    }
    
    if(indexPath.row == 6){
        
        NSLog(@"Change skin tone");
        // All instances of TestClass will be notified
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"changeSkintone"
         object:nil];
    }
   
}
#pragma mark -





//- (void)dealloc
//{
//    NSLog(@"RightController dealloc");
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    NSLog( @"%@: RIGHT %@", NSStringFromSelector(_cmd), self);
//}

@end
