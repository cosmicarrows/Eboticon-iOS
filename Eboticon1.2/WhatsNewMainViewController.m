//
//  MainViewController.m
//  Reader
//

#import "WhatsNewMainViewController.h"
#import "WhatsNewWebViewController.h"
#import "Reachability.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_ERROR;
#define CURRENTSCREEN @"Whats New Screen"



@interface WhatsNewMainViewController ()


// Reachability
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

// No connection
@property (nonatomic, nonatomic) IBOutlet UIImageView *noConnectionImageView;

@end



@implementation NSString (mycategory)

- (NSString *)stringByStrippingHTML
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end

@implementation WhatsNewMainViewController
@synthesize parseResults = _parseResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    //Sets the navigation bar title
    [self.navigationController.navigationBar.topItem setTitle:@"What's New"];
    //Sets the navigation bar title
    //[self.navigationItem setTitle:@"What's New"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadFeed)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //Load Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSLog(@"center x: %f", [[UIScreen mainScreen] bounds].size.width/2.0f);
    NSLog(@"center y: %f", [[UIScreen mainScreen] bounds].size.height/2.0f);
    
    self.spinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0f, [[UIScreen mainScreen] bounds].size.height/2.0f-100);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    
    //Set table row height so it can fit title & 2 lines of summary
    self.tableView.rowHeight = 85;
    
    //Parse feed
    [self parseRssFeed];
    
    
    //Internet Reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Start Internet Reachability Notifier
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    //Check Internet Connection
    if(![self doesInternetExists]){
        //add Internet connection view and remove caption button
        [self showNoConnectionAlert];
    }
    
    //Ads
    self.canDisplayBannerAds = NO;
    
    //GOOGLE ANALYTICS
    @try {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:CURRENTSCREEN forKey:kGAIScreenName]build]];
    }
    @catch (NSException *exception) {
        DDLogError(@"[ERROR] in Automatic screen tracking: %@", exception.description);
    }
    
}

- (void)parseRssFeed{
    
    dispatch_async( dispatch_get_global_queue(0, 0), ^{
        
        KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@" http://inclingconsulting.com/eboticon/" delegate:self];
        // call the result handler block on the main queue (i.e. main thread)
        dispatch_async( dispatch_get_main_queue(), ^{
            // running synchronously on the main thread now -- call the handler
            _parseResults = [parser posts];
            [self stripHTMLFromSummary];
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
    });
    
    
    
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)stripHTMLFromSummary {
    NSLog(@"stripHTMLFromSummary");
    NSLog(@" COUNT: %lu", (unsigned long)self.parseResults.count);
    int i = 0;
    int count = self.parseResults.count;
    //cycles through each 'summary' element stripping HTML
    while (i < count) {
        NSString *tempString = [[self.parseResults objectAtIndex:i] objectForKey:@"summary"];
        NSString *strippedString = [tempString stringByStrippingHTML];
        NSMutableDictionary *dict = [self.parseResults objectAtIndex:i];
        [dict setObject:strippedString forKey:@"summary"];
        [self.parseResults replaceObjectAtIndex:i withObject:dict];
        i++;
    }
}

- (void)reloadFeed {
    
    //Check Internet Connection
    if(![self doesInternetExists]){
        //add Internet connection view and remove caption button
        [self showNoConnectionAlert];
    }
    
    [self.spinner startAnimating];
    dispatch_async( dispatch_get_global_queue(0, 0), ^{
        
        KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@"http://inclingconsulting.com/eboticon/" delegate:self];
        // call the result handler block on the main queue (i.e. main thread)
        dispatch_async( dispatch_get_main_queue(), ^{
            // running synchronously on the main thread now -- call the handler
            _parseResults = [parser posts];
            [self stripHTMLFromSummary];
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
    });
}

#pragma mark-
#pragma mark Reachability

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    NetworkStatus internetStatus = [self.internetReachability currentReachabilityStatus];
    NSLog(@"Network status: %li", (long)internetStatus);
    
    if (internetStatus != NotReachable) {
        
        //Reload Feed
        NSLog(@"Internet connection exists");
        [self reloadFeed];
    }
    else {
        //there-is-no-connection warning
        NSLog(@"NO Internet connection exists");
        [self showNoConnectionAlert];
    }
    
}

- (void) showNoConnectionAlert
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"No connection"
                                                       message:@"No internet connection affects data on this page. Please check internet connection and try again."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    
}

- (BOOL) doesInternetExists {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        NSLog(@"Internet connection exists");
        return YES;
    }
    else {
        //there-is-no-connection warning
        NSLog(@"NO Internet connection exists");
        return NO;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.parseResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Check if cell is nil. If it is create a new instance of it
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure titleLabel
    cell.textLabel.text = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.textLabel.numberOfLines = 2;
    //Configure detailTitleLabel
    cell.detailTextLabel.text = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"summary"];
    
    cell.detailTextLabel.numberOfLines = 2;
    
    //Set accessoryType
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"link"];
    NSString *title = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"title"];
    WhatsNewWebViewController *vc = [[WhatsNewWebViewController alloc] initWithURL:url title:title];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KMXMLParser Delegate

- (void)parserDidFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not parse feed. Check your network connection." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (void)parserCompletedSuccessfully {
    NSLog(@"parserCompletedSuccessfully");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"stop animating");
    
    
    
}

- (void)parserDidBegin {
    NSLog(@"parserDidBegin");
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

@end
