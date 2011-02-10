/**
 * AdMobSampleAdsAppDelegate.h
 * AdMob iPhone SDK publisher sample code.
 */

#import "AdMobDelegateProtocol.h"
#import "AdMobInterstitialDelegateProtocol.h"
#import "AdMobInterstitialAd.h"

@interface AdMobSampleAdsAppDelegate : NSObject <UIApplicationDelegate, AdMobDelegate, AdMobInterstitialDelegate> {
    
  UIWindow *window;
  UINavigationController *navigationController;
  
  AdMobInterstitialAd *interstitialAd;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

