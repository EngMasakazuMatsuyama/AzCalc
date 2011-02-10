//
//  EarthquakeListViewController.h
//  AdMobSampleAdsiPad
//
//  Copyright Admob. Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EarthquakesLoader.h"
#import "AdMobDelegateProtocol.h"

@class DetailViewController;
@class AdMobView;

@interface EarthquakeListViewController : UIViewController <EarthquakesLoaderDelegate,
                                                            UITableViewDelegate,
                                                            UITableViewDataSource,
                                                            AdMobDelegate>
{
  DetailViewController *detailViewController;
  EarthquakesLoader *earthquakesLoader;
  UITableView *tableView;
  AdMobView *adMobView;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
