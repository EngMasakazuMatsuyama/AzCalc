//
//  OptionVC.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/19.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OptionVC : UIViewController 
{
	IBOutlet UISegmentedControl	*ibSegGroupingSeparator;
	IBOutlet UISegmentedControl	*ibSegGroupingType;
	IBOutlet UISegmentedControl	*ibSegDecimalSeparator;
}

- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment;
- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment;
- (IBAction)ibBuOK:(UIButton *)button;

@end
