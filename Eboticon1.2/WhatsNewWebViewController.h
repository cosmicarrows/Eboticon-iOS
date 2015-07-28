//
//  WebViewController.h
//  Reader
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface WhatsNewWebViewController : UIViewController

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle;

@end
