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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	ibSegGroupingSeparator.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_GroupingSeparator];
	ibSegGroupingSize.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_GroupingSize];
	ibSegDecimalSeparator.selectedSegmentIndex = (NSInteger)[defaults integerForKey:GUD_DecimalSeparator];
}
// viewDidAppear はView表示直後に呼ばれる


- (IBAction)ibSegGroupingSeparator:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_GroupingSeparator];
}

- (IBAction)ibSegGroupingSize:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_GroupingSize];
}

- (IBAction)ibSegDecimalSeparator:(UISegmentedControl *)segment
{
	[[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:GUD_DecimalSeparator];
}

- (IBAction)ibBuOK:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}


@end
