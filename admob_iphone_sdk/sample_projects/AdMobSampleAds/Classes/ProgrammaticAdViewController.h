//
//  ProgrammaticAdViewController.h
//  AdMobSampleAds
//

#import <UIKit/UIKit.h>
#import "AdMobDelegateProtocol.h"

@class AdMobView;

@interface ProgrammaticAdViewController : UIViewController<AdMobDelegate> {
  AdMobView *adMobAd;
}

@end
