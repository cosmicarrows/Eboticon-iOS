//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <unistd.h>
#import <netdb.h>

@interface WhatsNewWebViewController : UIViewController <UIWebViewDelegate>{
    NSMutableArray *arrAnimationColors;
    BOOL isLoaded;
    NSURL *siteUrl;
}

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;
//@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UITextView *txvLoadingMessage;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle;

@end
