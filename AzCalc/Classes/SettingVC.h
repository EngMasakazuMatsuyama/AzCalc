//
//  SettingVC.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingVC : UIViewController 
{
	IBOutlet UISegmentedControl	*ibSegDrums;
	IBOutlet UISegmentedControl	*ibSegCalcMethod;
	IBOutlet UISegmentedControl	*ibSegDecimal;
	IBOutlet UISegmentedControl	*ibSegRound;
	IBOutlet UISegmentedControl	*ibSegReverseDrum;

	// Option-iPad
	IBOutlet UISegmentedControl	*ibSegGroupingSeparator;
	IBOutlet UISegmentedControl	*ibSegGroupingType;
	IBOutlet UISegmentedControl	*ibSegDecimalSeparator;
}

- (IBAction)ibSegDrums:(UISegmentedControl *)segment;
- (IBAction)ibSegCalcMethod:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimal:(UISegmentedControl *)segment;
- (IBAction)ibSegRound:(UISegmentedControl *)segment;
- (IBAction)ibSegReverseDrum:(UISegmentedControl *)segment;
- (IBAction)ibBuOK:(UIButton *)button;
- (IBAction)ibBuKeyboardEdit:(UIButton *)button;
- (IBAction)ibBuPageFlip:(UIButton *)button;

// Option-iPad
- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment;
- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment;

@end

