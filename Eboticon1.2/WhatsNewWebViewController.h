//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface WhatsNewWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle;

@end
