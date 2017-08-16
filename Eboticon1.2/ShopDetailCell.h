//
//  MyCell.h
//
//

#import <UIKit/UIKit.h>
#import "EboticonGif.h"
#import "OLImageView.h"
#import "FLAnimatedImage.h"

@interface ShopDetailCell : UICollectionViewCell
@property (strong, nonatomic) EboticonGif *cellGif;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *gifImageView;


@end
