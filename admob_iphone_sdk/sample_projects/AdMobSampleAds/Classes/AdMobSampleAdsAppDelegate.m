/**
 * AdMobSampleAdsAppDelegate.m
 * AdMob iPhone SDK publisher sample code.
 */

#import "AdMobSampleAdsAppDelegate.h"
#import "RootViewController.h"


@implementation AdMobSampleAdsAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#ifdef ADMOB_INTERSTITIAL_ENABLED
  // Request an interstitial at "Application Open" time.
  // optionally retain the returned AdMobInterstitialAd.
  interstitialAd = [[AdMobInterstitialAd requestInterstitialAt:AdMobInterstitialEventAppOpen 
                                                      delegate:self 
                                          interstitialDelegate:self] retain];
#endif
  
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
  [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	// Save data if appropriate
}

#pragma mark -
#pragma mark AdMobDelegate methods

// Use this to provide a publisher id for an ad request. Get a publisher id
// from http://www.admob.com
- (NSString *)publisherIdForAd:(AdMobView *)adView 
{
  return @"a14d4c11a95320e"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView
{
  return navigationController;
}

#pragma mark -
#pragma mark AdMobDelegate test ad methods

// TODO: Comment these out when submitting to the App Store so real interstitials ads are returned instead of the test ones.
/*
  // Test ads are returned to these devices.  Device identifiers are the same used to register
  // as a development device with Apple.  To obtain a value open the Organizer 
  // (Window -> Organizer from Xcode), control-click or right-click on the device's name, and
  // choose "Copy Device Identifier".  Alternatively you can obtain it through code using
  // [UIDevice currentDevice].uniqueIdentifier.
  //
  // For example:
  //    - (NSArray *)testDevices {
  //      return [NSArray arrayWithObjects:
  //              ADMOB_SIMULATOR_ID,                             // Simulator
  //              //@"28ab37c3902621dd572509110745071f0101b124",  // Test iPhone 3GS 3.0.1
  //              //@"8cf09e81ef3ec5418c3450f7954e0e95db8ab200",  // Test iPod 2.2.1
  //              nil];
  //    }

- (NSArray *)testDevices {
  return [NSArray arrayWithObjects: ADMOB_SIMULATOR_ID, nil];
}

- (NSString *)testAdActionForAd:(AdMobView *)adMobView {
  return @"video_int"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
*/

#pragma mark -
#pragma mark AdMobInterstitialDelegate methods

// Sent when an interstitial ad request succefully returned an ad.  At the next transition
// point in your application call [ad show] to display the interstitial.
- (void)didReceiveInterstitial:(AdMobInterstitialAd *)ad
{
  if(ad == interstitialAd)
  {
    [ad show];
  }
}

// Sent when an interstitial ad request completed without an interstitial to show.  This is
// common since interstitials are shown sparingly to users.
- (void)didFailToReceiveInterstitial:(AdMobInterstitialAd *)ad
{
  NSLog(@"No interstitial ad retrieved.  This is ok.");
  [interstitialAd release];
  interstitialAd = nil;
}

- (void)interstitialDidDisappear:(AdMobInterstitialAd *)ad
{
  [interstitialAd release];
  interstitialAd = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
  [interstitialAd release];
	[navigationController release];
	[window release];
	[super dealloc];
}


@end
