/**
 * TableViewAdViewController.m
 * AdMob iPhone SDK publisher code.
 */

#import "TableViewAdViewController.h"
#import "AdMobView.h"
#import "RootViewController.h"

@implementation TableViewAdViewController

// The designated initializer.  Override if you create the controller programmatically 
// and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
    self.title = @"TableView Ad";
  }
  return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *MyIdentifier = @"MyIdentifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
  if (cell == nil) {
    cell = [[RootViewController createTableViewCellWithStyle:UITableViewCellStyleDefault  cellIdentifier:MyIdentifier] autorelease];
    // Request an AdMob ad for this table view cell
    [cell.contentView addSubview:[AdMobView requestAdWithDelegate:self]];
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if((indexPath.section == 0) && (indexPath.row == 0)) {
    return 48.0; // this is the height of the AdMob ad
  }
  
  return 44.0; // this is the generic cell height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)didReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did receive ad");
}

- (void)didFailToReceiveAd:(AdMobView *)adView {
  NSLog(@"AdMob: Did fail to receive ad");
}

@end