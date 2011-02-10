//
//  AdMobSampleAdsiPadAppDelegate.h
//  AdMobSampleAdsiPad
//
//  Copyright Admob. Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdMobDelegateProtocol.h"
#import "AdMobInterstitialDelegateProtocol.h"
#import "AdMobInterstitialAd.h"


@class EarthquakeListViewController;
@class DetailViewController;

@interface AdMobSampleAdsiPadAppDelegate : NSObject <UIApplicationDelegate, AdMobDelegate, AdMobInterstitialDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    EarthquakeListViewController *rootViewController;
    DetailViewController *detailViewController;
  
    AdMobInterstitialAd *interstitialAd;
    UIView *initialMaskView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet EarthquakeListViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
