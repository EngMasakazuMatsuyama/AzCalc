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
	IBOutlet UILabel			*ibLbVolume;
	IBOutlet UILabel			*ibLbTax;
	IBOutlet UISlider			*ibSliderVolume;
	IBOutlet UISlider			*ibSliderTax;
	IBOutlet UISegmentedControl	*ibSegGroupingSeparator;
	IBOutlet UISegmentedControl	*ibSegGroupingType;
	IBOutlet UISegmentedControl	*ibSegDecimalSeparator;
	IBOutlet UISegmentedControl	*ibSegButtonDesign;

@private
	float		MfTaxRate;
	float		MfTaxRateModify;
}

- (IBAction)ibSliderVolumeChange:(UISlider *)slider;
- (IBAction)ibSliderVolumeTouchUp:(UISlider *)slider;
- (IBAction)ibSliderTaxChange:(UISlider *)slider;
- (IBAction)ibSliderTaxTouchUp:(UISlider *)slider;
- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment;
- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment;
- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment;
- (IBAction)ibSegButtonDesign:(UISegmentedControl *)segment;
- (IBAction)ibBuOK:(UIButton *)button;

@end
