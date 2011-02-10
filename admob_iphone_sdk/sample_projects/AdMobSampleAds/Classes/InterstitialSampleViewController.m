/**
 * InterstitialSampleViewController.m
 * AdMob iPhone SDK publisher sample code.
 *
 * Sample code for requesting an AdMob Interstitial Ad at
 * application open as well as before a video (pre-roll).
 */

#import "InterstitialSampleViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <math.h>


// Replace this with your own movie URL to test pre-roll.
#define MOVIE_URL @"http://mmv.admob.com/p/v/77/4b/774b0bc3eb7959af8d690fa63ee3f9da/video.mov"


@interface InterstitialSampleViewController()

- (void)startMovie;

@end


@implementation InterstitialSampleViewController

@synthesize label, playMovieButton;
@synthesize spinner;
@synthesize moviePlayer;

- (void)loadView
{
  [super loadView];

  [self welcomeUser];
  if(prerollInterstitial == nil)
  {
    prerollInterstitial = [[AdMobInterstitialAd requestInterstitialAt:AdMobInterstitialEventPreRoll 
                                                             delegate:self 
                                                 interstitialDelegate:self] retain];    
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [moviePlayer stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)dealloc 
{
  // remove movie notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
                                                object:moviePlayer];
  [moviePlayer release];
  [prerollInterstitial release];
  [super dealloc];
}

- (void)welcomeUser
{
  // Customize our view.
  [label setText:@"Welcome!"];
  playMovieButton.hidden = NO;
}

- (void)startMovie
{
  // Note we should always create a new MPMoviePlayerController object.  Apple's 
  // implementation has bugs if we try to reuse the player to play the same movie
  // again.
  self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:MOVIE_URL]];

#ifdef __IPHONE_3_2
  // Is this device running iPhone OS 3.2+?
  // Check for instance methods that only exists in 3.2 and above.
  if ([MPMoviePlayerController instancesRespondToSelector:@selector(controlStyle)]) {
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.moviePlayer.view];
  }
#endif
  
  // Register to receive a notification when the movie has finished playing. 
  [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(moviePlayBackDidFinish:) 
                                               name:MPMoviePlayerPlaybackDidFinishNotification 
                                             object:self.moviePlayer];
  
  [self.moviePlayer play];
  [self.moviePlayer release];
}


- (IBAction)buttonPressed:(id)button
{
  playMovieButton.hidden = YES;
  [spinner startAnimating];
  
  if(prerollInterstitial.ready)
  {
    // Show the pre-roll interstitial.  When it completes the delegate -interstitialDidDisappear
    // will be called and that will call -startMovie.
    [prerollInterstitial show];
    interstitialPlaying = YES;
    
  }
  else
  {
    [self startMovie];
  }
}

//  Notification called when the movie finished playing.
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
  // Workaround for bug in Apple's movie player.  The movie player is implemented
  // as a singleton so even though we registered for notifications to the
  // self.moviePlayer object, we'll also get notifications to the interstitial's movie player.
  // This flag tells us whether it was the interstitial video that completed or
  // self.moviePlayer.
  if(!interstitialPlaying)
  {
    // Workaround for another bug in Apple's MPMoviePlayerController pre 3.2.  This makes the
    // movie actually stop.
    if([self.moviePlayer respondsToSelector:@selector(setInitialPlaybackTime:)])
    {  
      [self.moviePlayer setInitialPlaybackTime:-1];
    } 
  }
}

#pragma mark AdMobInterstitialDelegate methods

// Sent when an interstitial ad request succefully returned an ad.  At the next transition
// point in your application call [ad show] to display the interstitial.
- (void)didReceiveInterstitial:(AdMobInterstitialAd *)ad
{
  if(prerollInterstitial == ad)
  {
    // we have already retained the prerollInterstitial, but we will
    // hold on to the ad until the movie is played.
  }
  [label setText:@"Welcome! Interstitial received."];
}

// Sent when an interstitial ad request completed without an interstitial to show.  This is
// common since interstitials are shown sparingly to users.
- (void)didFailToReceiveInterstitial:(AdMobInterstitialAd *)ad
{
  NSLog(@"No interstitial ad retrieved.  This is ok.");
  
  if(prerollInterstitial == ad)
  { 
    // There was no pre-roll interstitial so we have nothing to do.
  }
}

- (void)interstitialWillDisappear:(AdMobInterstitialAd *)ad
{
  // optionally do something here when the interstitial is about to disappear.
}

- (void)interstitialDidDisappear:(AdMobInterstitialAd *)ad
{
  interstitialPlaying = NO;
  
  if(prerollInterstitial == ad)
  {
    // The pre-roll has completed, play the regular movie
    [self startMovie];
  }
}

#pragma mark AdMobDelegate methods

// Use this to provide a publisher id for an ad request. Get a publisher id
// from http://www.admob.com
- (NSString *)publisherIdForAd:(AdMobView *)adView {
  return @"a14d4c11a95320e"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
  return self;
}

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

- (NSArray *)testDevices
{
  return [NSArray arrayWithObjects: ADMOB_SIMULATOR_ID, nil];
}

- (NSString *)testAdActionForAd:(AdMobView *)adMobView
{
  return @"video_int"; // see AdMobDelegateProtocol.h for a listing of valid values here
}
*/

@end