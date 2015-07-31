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
- (void)viewDidLoad
{
    [super viewDidLoad];
    


    self.url = [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  
    NSURL *newURL = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView setDelegate:self];
    [self.view addSubview:self.webView];
    
    //Load Spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 240);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:newURL]];
    self.canDisplayBannerAds = NO;
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    NSLog(@"Web view finished");
    [self.spinner stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"could not load the website caused by error: %@", error);
}

@end
    
