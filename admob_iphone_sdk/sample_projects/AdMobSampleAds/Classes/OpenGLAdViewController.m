//
//  OpenGLAdViewController.m
//  AdMobSampleAds
//

#import "AdMobView.h"
#import "OpenGLAdViewController.h"
#import "OpenGLSampleView.h"

#define kDrawingInset 2

@implementation OpenGLAdViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  // get the window frame here.
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;

  // making flexible because this will end up in a navigation controller.
  UIView *container = [[UIView alloc] initWithFrame:appFrame];
  container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.view = container;
  container.backgroundColor = [UIColor greenColor];

  // Put our actual drawing view in the container so that we can resize it when
  // an ad appears.
  CGRect viewFrame = CGRectInset(container.bounds, kDrawingInset, kDrawingInset);
  drawingView = [[OpenGLSampleView alloc] initWithFrame:viewFrame];
  drawingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [container addSubview:drawingView];
  [drawingView release];

  // Request an ad
  adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
  [adMobAd retain]; // this will be released when it loads (or fails to load)
}

- (void)viewWillAppear:(BOOL)animated {
  drawingView.animate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
  drawingView.animate = NO;
}

- (void)didReceiveAd:(AdMobView *)adView {
  [super didReceiveAd:adView];

  // get the view frame
  CGRect frame = self.view.frame;

  // put the ad at the bottom of the screen
  CGFloat adHeight = 48;
  adMobAd.frame = CGRectMake(0, frame.size.height - adHeight, frame.size.width, adHeight);
  [self.view addSubview:adMobAd];

  // Move our OGL view out of the way
  drawingView.frame = CGRectInset(CGRectMake(0, 0, frame.size.width, frame.size.height - adHeight),
                                  kDrawingInset, kDrawingInset);
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
  [adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
  [adMobAd release];
  adMobAd = nil;
  // we could start a new ad request here, but in the interests of the user's battery life, let's not
}

@end
