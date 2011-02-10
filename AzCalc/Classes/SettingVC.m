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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


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
- (void)viewDidLoad 
{
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
