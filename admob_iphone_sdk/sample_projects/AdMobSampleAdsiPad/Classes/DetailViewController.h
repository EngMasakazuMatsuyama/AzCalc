//
//  DetailViewController.h
//  AdMobSampleAdsiPad
//
//  Copyright Admob. Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Earthquake.h"
#import "AdViewController.h"

@class USGSViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, MKMapViewDelegate> {
    
  UIPopoverController *popoverController;
  UIToolbar *toolbar;
  MKMapView *mapView;

  UIBarButtonItem *usgsFormButton;
  UIBarButtonItem *usgsPageButton;
  USGSViewController *usgsViewController;
  
  UIView *adView;
  AdViewController *adViewController;
}

@property (nonatomic, retain) IBOutlet UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *usgsFormButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *usgsPageButton;
@property (nonatomic, retain) IBOutlet UIView *adView;
@property (nonatomic, retain) IBOutlet AdViewController *adViewController;

- (void)showEarthquake:(Earthquake *)earthquake;
- (IBAction)buttonPressed:(id)sender;

@end
