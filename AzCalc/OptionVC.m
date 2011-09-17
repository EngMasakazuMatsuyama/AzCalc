//
//  OptionVC.m
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/19.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "OptionVC.h"


@implementation OptionVC

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark - View dealloc

- (void)dealloc {
    [super dealloc];
}


#pragma mark - View lifecicle

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
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


#pragma mark - IBAction

// 同じ処理が、SettingVC.m (iPad用) にも存在する
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
	float f = floorf((MfTaxRate + ibSliderTax.value) * 10.0) / 10.0; //[1.0.5] 小数1位までにする
	if (f<0.1) f = 0.0;
	else if (99.8<f) f = 99.9;
	
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
	// (0) 9,9
	// (1) 9'9
	// (2) 9 9
	// (3) 9.9
}

- (IBAction)ibSegGroupingType:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_GroupingType];
	// (0)   123 123  International
	// (1) 12 12 123  India
	// (2) 1234 1234  Kanji zone
}

- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_DecimalSeparator];
	// (0) 0.0
	// (1) 0·0
	// (2) 0,0
}

- (IBAction)ibBuOK:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}


@end
