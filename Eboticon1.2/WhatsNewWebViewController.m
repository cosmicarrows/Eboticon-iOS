//
//  WebViewController.m
//  Reader
//

#import "WhatsNewWebViewController.h"
#import "AppDelegate.h"

@interface WhatsNewWebViewController ()

@end

@implementation WhatsNewWebViewController
@synthesize url = _url, webView = _webView;


- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle
{
    self = [super init];
    if (self) {
        _url = postURL;
        self.title = postTitle;
    }
    return self;
}

- (UIColor *)colorWithHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)loadAnimationForTheMessage:(NSInteger) nIndex{
    [UIView transitionWithView:self.txvLoadingMessage duration:0.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.txvLoadingMessage.textColor = [arrAnimationColors objectAtIndex:1 - nIndex];
    } completion:^(BOOL finished) {
        [self loadAnimationForTheMessage:1 - nIndex];
    }];
}

- (void)addLoadingMessage:(NSString *)sMessage{
    [self.txvLoadingMessage removeFromSuperview];
    
    CGFloat fScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat fScreenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat fMessageWidth = 200;
    CGFloat fMessageHeight = 40;
    CGFloat fMessageLeft = (fScreenWidth - fMessageWidth) / 2.0;
    CGFloat fMessageTop = (fScreenHeight - fMessageHeight) / 2.0;
    
    CGRect frameForMessage = CGRectMake(fMessageLeft, fMessageTop, fMessageWidth, fMessageHeight);
    
    arrAnimationColors = [[NSMutableArray alloc]init];
    
    [arrAnimationColors addObject:[self colorWithHexString:@"#502175"]];
    [arrAnimationColors addObject:[self colorWithHexString:@"#ffffff"]];
    
    self.txvLoadingMessage = [[UITextView alloc] initWithFrame:frameForMessage];
    [self.txvLoadingMessage setText:sMessage];
    [self.txvLoadingMessage setTextColor:[self colorWithHexString:@"#ff0000"]];
    [self.txvLoadingMessage setFont:[UIFont fontWithName:@"Avenir" size:14]];
    [self.txvLoadingMessage setTextAlignment:NSTextAlignmentCenter];
    self.txvLoadingMessage.clipsToBounds = YES;
    self.txvLoadingMessage.layer.cornerRadius = 10.0;
    
    [self.view addSubview:self.txvLoadingMessage];
    
    if (isLoaded)[self loadAnimationForTheMessage:0];
}

- (BOOL)isNetworkAvailable{
    char *hostName;
    struct hostent *hostinfo;
    hostName = "baidu.com";
    hostinfo = gethostbyname(hostName);
    if (hostinfo == NULL)return NO;
    return YES;
}

- (void)loadFinishedNotification:(NSString *)sNotification{
//    [self.spinner stopAnimating];
    [self.txvLoadingMessage removeFromSuperview];
    NSLog(@"%@", sNotification);
}

- (void)loadWebPage{
    isLoaded = YES;
    
    [self addLoadingMessage:@"Loading..."];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:siteUrl]];
    self.canDisplayBannerAds = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    
    if (isLoaded)return;
    
    if ([self isNetworkAvailable]){
        [self loadWebPage];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    isLoaded = NO;
    
    self.url = [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    siteUrl = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView setDelegate:self];
    [self.view addSubview:self.webView];
    
//    Load Spinner
//    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.spinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
//    self.spinner.hidesWhenStopped = YES;
//    [self.view addSubview:self.spinner];
//    [self.spinner startAnimating];
    
    if (![self isNetworkAvailable]){
        [self addLoadingMessage:@"No Connection!"];
        return;
    }
    
    [self loadWebPage];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // Release any retained subviews of the main view.
//    [self loadFinishedNotification:@"viewDidUnload"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebView delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //read your request here
    //before the webview will load your request

    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    //access your request
    //webView.request;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //access your request
    //webView.request;
    [self loadFinishedNotification:@"Web view finished"];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self loadFinishedNotification:[NSString stringWithFormat:@"could not load the website caused by error: %@", error.description]];
}

@end
    
