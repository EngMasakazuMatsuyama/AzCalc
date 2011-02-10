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

@synthesize iPage, iCol, iRow, iColorNo, fFontSize, bDirty;


- (KeyButton *)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
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

/*
// KeyButton *kb = [button copy]; するために必要。 「萩原本 cf.P310」
- (id)copyWithZone:(NSZone *)zone
{
	//KeyButton *kb = [[[self class] allocWithZone:zone] init];
	KeyButton *kb = NSCopyObject(self, 0, zone);
	if (kb) {
		kb.iPage = iPage;
		kb.iCol = iCol;
		kb.iRow = iRow;
		kb.iColorNo = iColorNo;
		kb.fFontSize = fFontSize;
		kb.bDirty = bDirty;
	}
	return kb;
}
*/

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.nextResponder touchesBegan:touches withEvent:event]; // 受け流す
	
	CGPoint po = [[touches anyObject] locationInView:self];
	AzLOG(@"---KeyButton:touchesBegan:(%f, %f)", po.x, po.y);
}	

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:self];
	AzLOG(@"---KeyButton:touchesMoved:(%f, %f)", po.x, po.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:self];
	AzLOG(@"---KeyButton:touchesEnded:(%f, %f)", po.x, po.y);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:self];
	AzLOG(@"--------------KeyButton:touchesCancelled:(%f, %f)", po.x, po.y);
}
*/

@end
