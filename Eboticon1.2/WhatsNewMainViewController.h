//
//  MainViewController.h
//  Reader
//

#import <UIKit/UIKit.h>
#import "KMXMLParser.h"
#import <iAd/iAd.h>

@interface WhatsNewMainViewController : UITableViewController <KMXMLParserDelegate>


@property (strong, nonatomic) NSMutableArray *parseResults;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end
