//
//  ProgrammaticAdViewController.m
//  AdMobSampleAds
//

#import "ProgrammaticAdViewController.h"
#import "AdMobView.h"

@implementation ProgrammaticAdViewController

// The designated initializer.  Override if you create the controller programmatically
// and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
    self.title = @"Programmatic Ad";
  }
  return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  // get the window frame here.
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;

  UIView *view = [[UIView alloc] initWithFrame:appFrame];
  // making flexible because this will end up in a navigation controller.
  view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.view = view;

  [view release];

  // Request an ad
  adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
  [adMobAd retain]; // this will be released when it loads (or fails to load)

}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [adMobAd release];

  [super dealloc];
}

#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView {
  return @"a14d4c11a95320e"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
  return self;
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
  return [UIColor colorWithRed:0.592 green:0.314 blue:0.302 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
  return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
  return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

// To receive test ads rather than real ads...
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
  return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
*/

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did receive ad");
  // get the view frame
  CGRect frame = self.view.frame;

  // put the ad at the bottom of the screen
  adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);

  [self.view addSubview:adMobAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did fail to receive ad");
  [adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
  [adMobAd release];
  adMobAd = nil;
  // we could start a new ad request here, but in the interests of the user's battery life, let's not
}



@end