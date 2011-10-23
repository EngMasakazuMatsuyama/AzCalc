//
//  KeyButton.m
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "KeyButton.h"


@implementation KeyButton

@synthesize iPage, iCol, iRow, iColorNo, fFontSize, bDirty, RzUnit;


#pragma mark - UIButton lifecicle

- (void)dealloc 
{
	[RzUnit release];
    [super dealloc];
}

- (KeyButton *)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
		// OK
		RzUnit = nil;
		iPage = 0;
		iCol = 0;
		iRow = 0;
		iColorNo = 0;
		fFontSize = 10;
		bDirty = NO;
		//bu.contentMode = UIViewContentModeScaleToFill;
		//bu.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);  変化なしだった。
		//self.imageView.contentMode = UIViewContentModeScaleToFill;
		//self.imageView.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);
    }
    return self;
}


@end
