//
//  MasterViewController.m
//  Eboticon1.2
//
//  Created by Jarryd McCree on 12/23/13.
//  Copyright (c) 2013 Incling. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "JMCategoryData.h"
#import "JMCategoriesData.h"
#import "GifCollectionViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


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
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    /**
     UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     **/
    self.title = @"Eboticon";
    /**
    UIImage *logoImage = [UIImage imageNamed:@"Eboticon_Final.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    self.navigationItem.titleView = logoImageView;
     **/
    
    //Ebo Background
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Ebo_Background.png"]];
    
    //GOOGLE ANALYTICS
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Home Screen" forKey:kGAIScreenName]build]];

    
    /**
     Lists all fonts
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
     **/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    /**
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
     **/
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
    /**
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
     **/
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    JMCategoriesData *eboticonPic = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = eboticonPic.data.title;
    cell.imageView.image = eboticonPic.thumbImage;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    } else if ([[segue identifier] isEqualToString:@"showGifCollection"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GifCollectionViewController *destViewController = segue.destinationViewController;
        JMCategoriesData *categoryData = _categories[indexPath.row];
        NSString *categoryName = categoryData.data.title;
        NSLog(@"Category name is %@",categoryName);
        destViewController.gifCategory = categoryName;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
     **/
    JMCategoriesData *categoryData = _categories[indexPath.row];
    NSString *categoryName = categoryData.data.title;
    NSLog(@"Category name is %@",categoryName);
    
    if ([categoryName isEqualToString:@"More"]){
        [self performSegueWithIdentifier:@"showMoreView" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showGifCollection" sender:self];        
    }
}


@end
