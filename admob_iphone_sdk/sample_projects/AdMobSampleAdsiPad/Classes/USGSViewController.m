    //
//  USGSViewController.m
//  AdMobSampleAdsiPad
//
//  Copyright 2010 AdMob, Inc. All rights reserved.
//

#import "USGSViewController.h"


@implementation USGSViewController

@synthesize closeButton, webView, adViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.usgs.gov"]]];
}


- (IBAction)buttonPressed:(id)button {
  if(button == closeButton)
  {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
  }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [closeButton release];
  [webView release];
  [adViewController release];
  [super dealloc];
}

@end