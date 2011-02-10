//
//  AzCalcVC.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AzCalcVC : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, 
														ADBannerViewDelegate>
{
	IBOutlet ADBannerView	*ibADBannerView;
	IBOutlet UIPickerView	*ibPicker;
	IBOutlet UILabel		*ibLbEntry;
	IBOutlet UIButton		*ibBuMemory;
	IBOutlet UILabel		*ibLbMemory;

@private
	NSArray				*arrayDrums;
	NSArray				*arrayButtons;
	NSInteger			entryComponent;
	BOOL				bDramRevers;	// これにより、ドラム逆転やりなおしモード時のキー連打不具合に対処している。
	BOOL				bZoomEntryComponent;  // YES= entryComponentの幅を最大にする
	BOOL				bADbannerIsVisible;  // iAd 広告内容があればYES
	BOOL				bADbannerFirstTime;  // iAd 広告内容があれば、起動時に表示するため
	BOOL				bDrumButtonTap1;	// 最初のタップでYES
	
	// Setting
	NSInteger  MiSegDrums;		// ドラム数 ＜＜セグメント値に +1 している＞＞
	NSInteger  MiSegCalcMethod;
	NSInteger  MiSegDecimal;
	NSInteger  MiSegRound;
	NSInteger  MiSegReverseDrum;
	// Option
	//NSString	*MzGroupingSeparator;
	//NSInteger	MiGroupingSize;
	//NSString	*MzDecimalSeparator;
}

- (IBAction)ibBuSetting:(UIButton *)button;
- (IBAction)ibBuInformation:(UIButton *)button;
- (IBAction)ibButton:(UIButton *)button; // 全電卓ボタンを割り当てている。.tag により識別

@end

