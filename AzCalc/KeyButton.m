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


#pragma mark - <NSCoding> シリアライズ

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self) {
		iPage = [[decoder decodeObjectForKey:@"iPage"] integerValue];
		iCol = [[decoder decodeObjectForKey:@"iCol"] integerValue];
		iRow = [[decoder decodeObjectForKey:@"iRow"] integerValue];
		iColorNo = [[decoder decodeObjectForKey:@"iColorNo"] integerValue];
		fFontSize = [[decoder decodeObjectForKey:@"fFontSize"] floatValue];
		bDirty = [[decoder decodeObjectForKey:@"bDirty"] boolValue];
		RzUnit = [decoder decodeObjectForKey:@"RzUnit"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:[NSNumber numberWithInteger:iPage]  forKey:@"iPage"];
	[encoder encodeObject:[NSNumber numberWithInteger:iCol]  forKey:@"iCol"];
	[encoder encodeObject:[NSNumber numberWithInteger:iRow]  forKey:@"iRow"];
	[encoder encodeObject:[NSNumber numberWithInteger:iColorNo]  forKey:@"iColorNo"];
	[encoder encodeObject:[NSNumber numberWithFloat:fFontSize]  forKey:@"fFontSize"];
	[encoder encodeObject:[NSNumber numberWithBool:bDirty]  forKey:@"bDirty"];
	[encoder encodeObject:RzUnit forKey:@"RzUnit"];
}


#pragma mark - UIButton lifecicle


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
