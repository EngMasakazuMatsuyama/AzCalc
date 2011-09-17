//
//  SetringVC.m
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#import "SettingVC.h"
#import "OptionVC.h"
#import "InformationVC.h"


@implementation SettingVC


#pragma mark - View dealloc

- (void)dealloc {
    [super dealloc];
}


#pragma mark - View lifecicle

- (void)loadView
{
	[super loadView];
	appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	ibSegDrums.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_Drums];
	ibSegCalcMethod.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
	ibSegDecimal.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_Decimal];
	ibSegRound.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_Round];
	ibSegReverseDrum.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];

	// Options
	NSInteger iVol = [defaults integerForKey:GUD_AudioVolume];
	ibLbVolume.text = [NSString stringWithFormat:@"%d", iVol];

	MfTaxRate = [defaults floatForKey:GUD_TaxRate];
	MfTaxRateModify = MfTaxRate;
	ibLbTax.text = [NSString stringWithFormat:@"%.1f%%", MfTaxRate];
	
	ibSegGroupingSeparator.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_GroupingSeparator];
	ibSegGroupingType.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_GroupingType];
	ibSegDecimalSeparator.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_DecimalSeparator];
}
// viewDidAppear はView表示直後に呼ばれる

#pragma mark  View 回転

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) return YES; // タテは常にOK
	else if (700 < self.view.frame.size.height) return YES; // iPad
	return NO;
}


#pragma mark - IBAction

- (IBAction)ibSegDrums:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_Drums];
}

- (IBAction)ibSegCalcMethod:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_CalcMethod];
}

- (IBAction)ibSegDecimal:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_Decimal];
}

- (IBAction)ibSegRound:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_Round];
}

- (IBAction)ibSegReverseDrum:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_ReverseDrum];
}


// 同じ処理が、OptionVC.m (iPhone用) にも存在する
- (IBAction)ibSliderVolumeChange:(UISlider *)slider
{
	NSInteger iVol  = (NSInteger)ibSliderVolume.value;
	if (iVol < 0) iVol = 0;
	else if (10 < iVol) iVol = 10;
	ibSliderVolume.value = iVol;
	ibLbVolume.text = [NSString stringWithFormat:@"%d", iVol];
}

- (IBAction)ibSliderVolumeTouchUp:(UISlider *)slider
{
	[[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)ibSliderVolume.value forKey:GUD_AudioVolume];
}


- (IBAction)ibSliderTaxChange:(UISlider *)slider
{
	//float f = MfTaxRate + floorf(ibSliderTax.value * 10.0) / 10.0; // 小数1位までにする
	float f = floorf((MfTaxRate + ibSliderTax.value) * 10.0) / 10.0; // 小数1位までにする
	if (f<0.1) f = 0.00;
	else if (99.8<f) f = 99.90;

	MfTaxRateModify = f;
	ibLbTax.text = [NSString stringWithFormat:@"%.2f%%", MfTaxRateModify];
}

- (IBAction)ibSliderTaxTouchUp:(UISlider *)slider
{
	MfTaxRate = MfTaxRateModify;
	[[NSUserDefaults standardUserDefaults] setFloat:MfTaxRate forKey:GUD_TaxRate];
	ibLbTax.text = [NSString stringWithFormat:@"%.2f%%", MfTaxRate];
	ibSliderTax.value = 0; // Center
}

- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_GroupingSeparator];
}

- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_GroupingType];
}

- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_DecimalSeparator];
}



- (IBAction)ibBuOK:(UIButton *)button
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize]; // plistへ書き出す
	appDelegate.bChangeKeyboard = NO;

	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuKeyboardEdit:(UIButton *)button
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize]; // plistへ書き出す
	appDelegate.bChangeKeyboard = YES;
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuPageFlip:(UIButton *)button
{
	appDelegate.ibOptionVC.modalTransitionStyle = UIModalTransitionStylePartialCurl; // めくれ上がる
	//appDelegate.ibInformationVC.view.hidden = YES;
	//appDelegate.ibSettingVC.view.hidden = NO;
	appDelegate.ibOptionVC.view.hidden = NO;
	[self presentModalViewController:appDelegate.ibOptionVC animated:YES];
}


@end
