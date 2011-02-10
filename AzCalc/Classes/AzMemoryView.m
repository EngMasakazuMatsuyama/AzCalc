//
//  AzMemoryView.m
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#import "AzMemoryView.h"


@implementation AzMemoryView

//@synthesize iPage, iCol, iRow, iColorNo, fFontSize, bDirty;


- (void)dealloc 
{
	[picView release];
	[super dealloc];
}

- (AzMemoryView *)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		// OK
		AzLOG(@"AzMemoryView: init OK");
		//
		picView = [[UIPickerView alloc] initWithFrame:frame];
		[self addSubview:picView]; 
		picView.delegate = self;
		picView.dataSource = self;
		picView.showsSelectionIndicator = YES;
		picView.hidden = NO;
		picView.backgroundColor = [UIColor clearColor];
		//
    }
    return self;
}


//-----------------------------------------------------------Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView 
			viewForRow:(NSInteger)row 
		  forComponent:(NSInteger)component
		   reusingView:(UIView *)reView
{
	UIView *vi = reView;  // Viewが再利用されるため
	UILabel *lb = nil;
	CGSize sz = [pickerView rowSizeForComponent:component];

	if (vi == nil) {
		vi = [[[UIView alloc] initWithFrame:CGRectMake(0,0,sz.width,30)] autorelease];
		// addSubview
		lb = [[UILabel alloc] initWithFrame:CGRectMake(5,0,sz.width-10,30)];
		lb.tag = 992;
		lb.backgroundColor = [UIColor clearColor];
		lb.adjustsFontSizeToFitWidth = YES;
		lb.minimumFontSize = 6;
		lb.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		[vi addSubview:lb]; [lb release];
	}
	if (lb == nil) {
		lb = (UILabel *)[vi viewWithTag:992];
	}
	lb.textAlignment = UITextAlignmentLeft;
	lb.font = [UIFont systemFontOfSize:20];
	lb.text =  NSLocalizedString(@"Drum Calculator",nil);
	
	return vi;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//[self.nextResponder touchesBegan:touches withEvent:event]; // ibPickerへ受け流す
	AzLOG(@"AzMemoryView: touchesBegan");
}


@end
