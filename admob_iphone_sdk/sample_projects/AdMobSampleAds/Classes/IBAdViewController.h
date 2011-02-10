/**
 * IBAdViewController.h
 * AdMob iPhone SDK sample code.
 *
 */

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface IBAdViewController : UIViewController {
  AdViewController *adViewController;
}

@property (nonatomic,retain) IBOutlet AdViewController *adViewController;

@end