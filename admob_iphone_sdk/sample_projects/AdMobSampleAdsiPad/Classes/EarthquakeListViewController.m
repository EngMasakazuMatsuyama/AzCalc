//
//  EarthquakeListViewController.m
//  AdMobSampleAdsiPad
//
//  Copyright Admob. Inc. 2010. All rights reserved.
//

#import "EarthquakeListViewController.h"
#import "DetailViewController.h"
#import "EarthquakeCell.h"
#import "AdMobView.h"

@implementation EarthquakeListViewController

@synthesize detailViewController;
@synthesize tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.contentSizeForViewInPopover = CGSizeMake(320.0, 750.0);
  self.tableView.rowHeight = 48.0;
  earthquakesLoader = [[EarthquakesLoader alloc] initWithDelegate:self];

  // Request ad and show
  adMobView = [AdMobView requestAdOfSize:ADMOB_SIZE_320x270 withDelegate:self];
  [self.view addSubview:adMobView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (adMobView != nil) {
    // Move the ad view into place
    CGRect adFrame = adMobView.frame;
    adFrame.origin.y = self.view.bounds.size.height - adFrame.size.height;
    adMobView.frame = adFrame;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
  // first section to contain the ad, second to contain the earthquakes
  return 2;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) return 1; // just need one row for the ad
  return [earthquakesLoader.earthquakeList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  if (indexPath.section == 0) {
    static NSString *AdCellID = @"AdCellID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AdCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:AdCellID] autorelease];
      // Request an AdMob ad for this table view cell
      [cell.contentView addSubview:[AdMobView requestAdWithDelegate:self]];
    }
    return cell;
  }
  else {
    static NSString *EarthquakeCellID = @"EarquakeCellID";
    Earthquake *earthquake = [earthquakesLoader.earthquakeList objectAtIndex:indexPath.row];
    EarthquakeCell *cell = (EarthquakeCell *)[self.tableView dequeueReusableCellWithIdentifier:EarthquakeCellID];
    if (cell == nil) {
      cell = [[[EarthquakeCell alloc] initWithLocation:earthquake.location
                                                  date:earthquake.date
                                             magnitude:earthquake.magnitude
                                       reuseIdentifier:EarthquakeCellID] autorelease];
    }
    else {
      [cell setLocation:earthquake.location];
      [cell setDate:earthquake.date];
      [cell setMagnitude:earthquake.magnitude];
    }
    return cell;
  }
  return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) return;
  
	Earthquake *earthquake = [earthquakesLoader.earthquakeList objectAtIndex:indexPath.row];
	if (earthquake == nil)
		return;
  [self.detailViewController showEarthquake:earthquake];
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}


- (void)dealloc {
  [detailViewController release];
  [earthquakesLoader release];
  [tableView release];
  [adMobView release];
  [super dealloc];
}


#pragma mark -
#pragma mark EarthquakesLoader delegate

- (void)earthquakesDidLoad:(EarthquakesLoader *)loader {
  // There should just be one loader, if not, programmer error or something
  // really bad happened
  NSAssert(earthquakesLoader == loader, @"The earthquakesLoader is not mine!");
  [self.tableView reloadData];
}


#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView; {
  return @"a14d4c11a95320e"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
  // Return the top level view controller if possible. In this case, it is
  // the split view controller
  return self.splitViewController;
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

- (void)didReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did receive ad in EarthquakeList");
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did fail to receive ad in EarthquakeList");
}

- (void)willPresentFullScreenModalFromAd:(AdMobView *)adView {
  // IMPORTANT!!! IMPORTANT!!!
  // If we are about to get a full screen modal and we have a popover controller, dimiss it.
  // Otherwise, you may see the popover on top of the landing page.
  if(detailViewController.popoverController.popoverVisible) {
    [detailViewController.popoverController dismissPopoverAnimated:YES];
  }
}

@end
