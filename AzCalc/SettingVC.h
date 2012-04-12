//
//  SettingVC.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// ---------------------------------------------------------------------------------
// "SettingVC.xib" は、"MainWindow.xib" にて読み込まれる！！！
// ---------------------------------------------------------------------------------

#import <UIKit/UIKit.h>


@interface SettingVC : UIViewController 
{
	IBOutlet UISegmentedControl	*ibSegDrums;
	IBOutlet UISegmentedControl	*ibSegCalcMethod;
	IBOutlet UISegmentedControl	*ibSegDecimal;
	IBOutlet UISegmentedControl	*ibSegRound;
	IBOutlet UISegmentedControl	*ibSegReverseDrum;

	// Option-iPad
	IBOutlet UILabel			*ibLbVolume;
	IBOutlet UISlider			*ibSliderVolume;
	IBOutlet UILabel			*ibLbTax;
	IBOutlet UISlider			*ibSliderTax;
	IBOutlet UISegmentedControl	*ibSegGroupingSeparator;
	IBOutlet UISegmentedControl	*ibSegGroupingType;
	IBOutlet UISegmentedControl	*ibSegDecimalSeparator;
	IBOutlet UISegmentedControl	*ibSegButtonDesign;

@private
	AzCalcAppDelegate *appDelegate;  // initにて = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	// Option-iPad
	float		MfTaxRate;
	float		MfTaxRateModify;
}

- (IBAction)ibSegDrums:(UISegmentedControl *)segment;
- (IBAction)ibSegCalcMethod:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimal:(UISegmentedControl *)segment;
- (IBAction)ibSegRound:(UISegmentedControl *)segment;
- (IBAction)ibSegReverseDrum:(UISegmentedControl *)segment;
- (IBAction)ibSegButtonDesign:(UISegmentedControl *)segment;
- (IBAction)ibBuOK:(UIButton *)button;
- (IBAction)ibBuKeyboardEdit:(UIButton *)button;
- (IBAction)ibBuPageFlip:(UIButton *)button;
- (IBAction)ibBuDropbox:(UIButton *)button;

// Option-iPad
- (IBAction)ibSliderVolumeChange:(UISlider *)slider;
- (IBAction)ibSliderVolumeTouchUp:(UISlider *)slider;
- (IBAction)ibSliderTaxChange:(UISlider *)slider;
- (IBAction)ibSliderTaxTouchUp:(UISlider *)slider;
- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment;
- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment;

@end

