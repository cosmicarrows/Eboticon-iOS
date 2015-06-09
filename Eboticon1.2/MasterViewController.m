//
//  MasterViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/23/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import "MasterViewController.h"
#import "JMCategoryData.h"
#import "JMCategoriesData.h"
#import "GifCollectionViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize categories = _categories;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

#ifdef FREE
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo-Lite.png"]];
#else
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationBarLogo.png"]];
#endif

    self.tableView.backgroundColor = [UIColor clearColor];
    
    //self.tableView.scrollEnabled = false;
    self.tableView.alwaysBounceVertical = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MasterBackground2.0.png"]];
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Home Screen" forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    JMCategoriesData *eboticonPic = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = eboticonPic.data.title;
    cell.imageView.image = eboticonPic.thumbImage;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor= [UIColor whiteColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat navNarHeight = 66; //Height of navigation bar plus status bar
    CGRect screenBounds = [[UIScreen mainScreen] bounds]; //screen size
    CGFloat screenHeight = screenBounds.size.height;
    CGFloat rowHeight = (screenHeight-navNarHeight)/5;
    return rowHeight;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogDebug(@"prepareForSegue: %@", segue.identifier);
    
    if ([[segue identifier] isEqualToString:@"showGifCollection"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GifCollectionViewController *destViewController = segue.destinationViewController;
        JMCategoriesData *categoryData = _categories[indexPath.row];
        NSString *categoryName = categoryData.data.title;
        DDLogDebug(@"Category name is %@",categoryName);
        destViewController.gifCategory = categoryName;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    JMCategoriesData *categoryData = _categories[indexPath.row];
    NSString *categoryName = categoryData.data.title;
    DDLogDebug(@"Category name is %@",categoryName);
    
    if ([categoryName isEqualToString:@"More"]){
        [self performSegueWithIdentifier:@"showMoreView" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showGifCollection" sender:self];        
    }
}


@end
