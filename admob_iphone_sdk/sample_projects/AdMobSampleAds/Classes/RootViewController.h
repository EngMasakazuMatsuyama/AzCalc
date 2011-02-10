/**
 * RootViewController.h
 * AdMob iPhone SDK publisher sample code.
 */

@interface RootViewController : UITableViewController {
  NSMutableArray *menuList;
}

/*
 code modified from original version located at http://github.com/erica/UITableViewCell-Compatibility
 license reproduced below: 
 
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

+ (UITableViewCell *)createTableViewCellWithStyle:(UITableViewCellStyle)style 
                                   cellIdentifier:(NSString *)identifier;
+ (void)setTextForUITableViewCell:(UITableViewCell *)cell withText:(NSString *)text;



@end
