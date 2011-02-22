//
//  AzCalcViewController.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "AdMobDelegateProtocol.h"

@class KeyButton;

@interface AzCalcViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate,
														UIScrollViewDelegate, ADBannerViewDelegate, AdMobDelegate>
{
	IBOutlet ADBannerView	*ibAdBanner;
	IBOutlet UIPickerView	*ibPvDrum;
	IBOutlet UILabel		*ibLbEntry;
	IBOutlet UIButton		*ibBuMemory;
	IBOutlet UIButton		*ibBuSetting;
	IBOutlet UIButton		*ibBuInformation;
	IBOutlet UIScrollView	*ibScrollLower;
	IBOutlet UIScrollView	*ibScrollUpper; //[0.3]
	IBOutlet UITextView		*ibTvFormula;	//[0.3]
	IBOutlet UILabel		*ibLbFormAnswer;
	IBOutlet UIButton		*ibBuFormLeft;
	IBOutlet UIButton		*ibBuFormRight;
	IBOutlet UIButton		*ibBuGetDrum;
	
@private
	//----------------------------------------------dealloc時にrelese
	NSArray				*RaDrums;
	NSArray				*RaDrumButtons;
	NSArray				*RaPadKeyButtons;
	NSArray				*RaKeyMaster;	// !=nil キーレイアウト変更モード
	AdMobView			*RoAdMobView;

	//----------------------------------------------Owner移管につきdealloc時のrelese不要

	//----------------------------------------------assign
	NSInteger			entryComponent;
	BOOL				bDramRevers;		// これにより、ドラム逆転やりなおしモード時のキー連打不具合に対処している。
	BOOL				bZoomEntryComponent; // YES= entryComponentの幅を最大にする
	BOOL				bADbannerIsVisible; // iAd 広告内容があればYES
	BOOL				bADbannerFirstTime; // iAd 広告内容があれば、起動時に表示するため
	BOOL				bDrumButtonTap1;	// 最初のタップでYES
	BOOL				bDrumRefresh;		// =YES:ドラムを再表示する  =NO:[Copy]後などドラムを動かしたくないとき
	BOOL                bFormulaFilter;     // =YES:ペーストされたのでフィルタ処理する
    BOOL				bPad;				// =YES:iPad  =NO:iPhone
	float				MfTaxRate;
	
	// Keyboard spec
	int					iKeyPages;
	int					iKeyCols, iKeyOffsetCol;
	int					iKeyRows, iKeyOffsetRow;
	float				fKeyGap;
	float				fKeyFontZoom;
	float				fKeyWidGap;		// キートップ左右の余白
	float				fKeyHeiGap;		// キートップ上下の余白
	float				fKeyWidth;		// キートップの幅
	float				fKeyHeight;		// キートップの高さ

	// Change Keyboard
	KeyButton			*buChangeKey;	// 選択中のキー
	
	// Setting
	NSInteger  MiSegDrums;		// ドラム数 ＜＜セグメント値に +1 している＞＞
	NSInteger  MiSegCalcMethod;
	NSInteger  MiSegDecimal;
	NSInteger  MiSegRound;
	NSInteger  MiSegReverseDrum;

	NSInteger  MiSvLowerPage;	// ibScrollLower の現在表示ページを常に保持
	NSInteger  MiSvUpperPage;	// ibScrollUpper の現在表示ページを常に保持
}

- (IBAction)ibBuMemory:(UIButton *)button;
- (IBAction)ibBuSetting:(UIButton *)button;
- (IBAction)ibBuInformation:(UIButton *)button;
- (IBAction)ibButton:(UIButton *)button; // 全電卓ボタンを割り当てている。.tag により識別
- (IBAction)ibBuGetDrum:(UIButton *)button;

- (void)GvMemorySave; // AzCalcViewController:applicationWillTerminateからコールされる
- (void)GvMemoryLoad; // AzCalcViewController:applicationDidBecomeActiveからコールされる
- (void)GvKeyUnitGroupSI:(NSString *)unitSI andSI:(NSString *)unitSi2; // =nil:ハイライト解除
- (void)GvKeyUnitGroupSI:(NSString *)unitSI
				  andSi2:(NSString *)unitSi2
				  andSi3:(NSString *)unitSi3; // =nil:ハイライト解除

@end

