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


- (void)dealloc 
{
	[RzUnit release];
    [super dealloc];
}

- (KeyButton *)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
		// OK
		iPage = 0;
		iCol = 0;
		iRow = 0;
		iColorNo = 0;
		fFontSize = 10;
		bDirty = NO;
    }
    return self;
}


@end
