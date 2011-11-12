//
//  AzMemoryView.h
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AzMemoryView : UIView  <UIPickerViewDelegate, UIPickerViewDataSource>
{

@private
	UIPickerView		*picView;
	NSMutableArray		*maMemorys;		// in NSString
}

- (AzMemoryView *)initWithFrame:(CGRect)frame;
- (void)memoryCopy:(NSString *)zNum;
- (NSString *)memoryPaste;
- (void)memoryClear:(NSString *)zNum;

@end
