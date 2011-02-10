//
//  USGSViewController.h
//  AdMobSampleAdsiPad
//
//  Copyright 2010 AdMob, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface USGSViewController : UIViewController {
  UIButton *closeButton;
  UIWebView *webView;
  AdViewController *adViewController;
}

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet AdViewController *adViewController;

- (IBAction)buttonPressed:(id)button;

@end
