/**
 * RootViewController.m
 * AdMob iPhone SDK publisher sample code.
 *
 * UITableView set up to show several methods of integration with AdMob Ads.
 */

#import "IBAdViewController.h"
#import "InterstitialSampleViewController.h"
#import "OpenGLAdViewController.h"
#import "ProgrammaticAdViewController.h"
#import "RootViewController.h"
#import "TableViewAdViewController.h"

static NSString *kCellIdentifier = @"AdMobIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kViewControllerKey = @"viewController";
static NSString *kViewControllerClassKey = @"viewControllerClass";

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.title = self.title;
  // this will create three different ways of integrating AdMob ads into your application.
  // initialize three different view controllers.
  menuList = [[NSMutableArray alloc] init];

  // we are demonstrating three different integration styles:

  // 1. Interface Builder integration
  [menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSLocalizedString(@"IBAdView Integration", @""), kTitleKey,
                       @"IBAdViewController", kViewControllerClassKey,
                       nil]];

  // 2. Programmatic integration
  ProgrammaticAdViewController *programmaticAdViewController = [[[ProgrammaticAdViewController alloc] init] autorelease];
  [menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSLocalizedString(@"Programmatic Integration", @""), kTitleKey,
                       programmaticAdViewController, kViewControllerKey,
                       nil]];

  // 3. Table View Controller integration
  [menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSLocalizedString(@"TableViewAdView Integration", @""), kTitleKey,
                       @"TableViewAdViewController", kViewControllerClassKey,
                       nil]];

#ifdef ADMOB_INTERSTITIAL_ENABLED
  // 4. Interstitial integration
  [menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSLocalizedString(@"InterstitialAd Integration", @""), kTitleKey,
                       @"InterstitialSampleViewController", kViewControllerClassKey,
                       nil]];
#endif
  // 5. OpenGL integration
  [menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSLocalizedString(@"OpenGL Integration", @""), kTitleKey,
                       @"OpenGLAdViewController", kViewControllerClassKey,
                       nil]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [menuList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (cell == nil) {
    cell = [[RootViewController createTableViewCellWithStyle:UITableViewCellStyleDefault  cellIdentifier:kCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

	// Configure the cell.
  [RootViewController setTextForUITableViewCell:cell withText:[[menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey]];

  return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
  UIViewController *targetViewController = [[menuList objectAtIndex:indexPath.row] objectForKey:kViewControllerKey];
  if (targetViewController == nil) {
    NSString *vcClassStr = [[menuList objectAtIndex:indexPath.row] objectForKey:kViewControllerClassKey];
    targetViewController = [[NSClassFromString(vcClassStr) alloc] initWithNibName:vcClassStr bundle:nil];
  }
  [[self navigationController] pushViewController:targetViewController animated:YES];
}


/*
 code modified from original version located at http://github.com/erica/UITableViewCell-Compatibility
 license reproduced below:

 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */
+ (UITableViewCell *)createTableViewCellWithStyle:(UITableViewCellStyle)style
                                   cellIdentifier:(NSString *)identifier
{
  UITableViewCell *cell = [UITableViewCell alloc];
  SEL initSelector = @selector(initWithStyle:reuseIdentifier:);

  if ([cell respondsToSelector:initSelector]) // 3.0 or later
  {
    NSMethodSignature *ms = [cell methodSignatureForSelector:initSelector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];

    [inv setTarget:cell];
    [inv setSelector:initSelector];
    [inv setArgument:&style atIndex:2];
    [inv setArgument:&identifier atIndex:3];

    [inv invoke];

    return cell;
  }

  // Earlier than 3.0
  CGRect frameRect = CGRectZero;

  initSelector = @selector(initWithFrame:reuseIdentifier:);
  NSMethodSignature *ms = [cell methodSignatureForSelector:initSelector];
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];

  [inv setTarget:cell];
  [inv setSelector:initSelector];
  [inv setArgument:&frameRect atIndex:2];
  [inv setArgument:&identifier atIndex:3];

  [inv invoke];
  return cell;
}

+ (void)setTextForUITableViewCell:(UITableViewCell *)cell withText:(NSString *)text
{
  // setText if possible.
  if([cell respondsToSelector:@selector(setText:)])
  {
    [cell performSelector:@selector(setText:) withObject:text];
  }
  else if([cell respondsToSelector:@selector(textLabel)])
  {
    UILabel *textLabel = [cell textLabel];
    [textLabel setText:text];
  }
}



- (void)dealloc {
  [menuList release];

  [super dealloc];
}


@end

