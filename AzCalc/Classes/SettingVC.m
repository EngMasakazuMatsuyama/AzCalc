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

- (void)dealloc {
    [super dealloc];
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
}
// viewDidAppear はView表示直後に呼ばれる



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

- (IBAction)ibBuOK:(UIButton *)button
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize]; // plistへ書き出す

	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuPageFlip:(UIButton *)button
{
	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ibOptionVC.modalTransitionStyle = UIModalTransitionStylePartialCurl; // めくれ上がる
	//appDelegate.ibInformationVC.view.hidden = YES;
	//appDelegate.ibSettingVC.view.hidden = NO;
	appDelegate.ibOptionVC.view.hidden = NO;
	[self presentModalViewController:appDelegate.ibOptionVC animated:YES];
}


@end
