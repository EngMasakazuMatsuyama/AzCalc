//
//  DetailViewController.m
//  AdMobSampleAdsiPad
//
//  Copyright Admob. Inc. 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "EarthquakeListViewController.h"
#import "EarthquakeMapAnnotation.h"
#import "USGSViewController.h"


@implementation DetailViewController

@synthesize popoverController, toolbar, mapView;
@synthesize usgsFormButton, usgsPageButton;
@synthesize adView, adViewController;

#pragma mark -
#pragma mark Managing the detail item

- (void)showEarthquake:(Earthquake *)earthquake {
  MKCoordinateRegion region;
	region.center.latitude = [earthquake latitude];
	region.center.longitude = [earthquake longitude];
	region.span.latitudeDelta = 5;
	region.span.longitudeDelta = 5;
	[self.mapView setRegion:region animated:YES];
	EarthquakeMapAnnotation *annotation = [[EarthquakeMapAnnotation alloc] initWithEarthquake:earthquake];
	[self.mapView addAnnotation:annotation];
	[annotation release];
  if (popoverController != nil) {
    [popoverController dismissPopoverAnimated:YES];
  }        
}

#pragma mark -
#pragma mark Other Links item

- (IBAction)buttonPressed:(id)sender
{
  if(!usgsViewController)
  {
    usgsViewController = [[USGSViewController alloc] initWithNibName:@"USGSViewController" bundle:nil];
  }
  
  if(sender == usgsFormButton) {
    usgsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
  } else if(sender == usgsPageButton) {
    usgsViewController.modalPresentationStyle = UIModalPresentationPageSheet;
  }
  
  [self presentModalViewController:usgsViewController animated:YES];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController:(UISplitViewController*)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem
       forPopoverController:(UIPopoverController*)pc
{
  // check to see if this button is already in the array.
  if ([[toolbar items] objectAtIndex:0] != barButtonItem) {
    barButtonItem.title = @"Earthquake List";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
  }
  // IMPORTANT!!! IMPORTANT!!!
  // This reference is needed so that we can dismiss the popover whenever a modal
  // view controller will be shown
  self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController*)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  if([toolbar.items containsObject:barButtonItem]) {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObject:barButtonItem];
    [toolbar setItems:items animated:YES];
    [items release];    
  }
  // IMPORTANT!!! IMPORTANT!!!
  // Because the popover controller is being hidden, this popover reference can be cleared
  self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
  if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
    adView.hidden = NO;
  }
  else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    // Don't show the ad when in landscape since the 748x110 ad won't fit
    adView.hidden = YES;
  }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidUnload {
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [popoverController release];
  [toolbar release];
  [mapView release];
  [usgsFormButton release];
  [usgsPageButton release];
  [usgsViewController release];
  [adView release];
  [adViewController release];
  [super dealloc];
}


#pragma mark -
#pragma mark MapView support

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  MKAnnotationView *annotationView = [views objectAtIndex:0];
  [self.mapView selectAnnotation:annotationView.annotation animated:YES];
}

@end