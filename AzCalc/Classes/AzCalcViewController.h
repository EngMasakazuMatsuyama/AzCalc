//
//  AzCalcViewController.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class KeyButton;

@interface AzCalcViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, 
														UIScrollViewDelegate, ADBannerViewDelegate>
{
	IBOutlet ADBannerView	*ibADBannerView;
	IBOutlet UIPickerView	*ibPicker;
	IBOutlet UILabel		*ibLbEntry;
	//IBOutlet UILabel		*ibLbMemory;
	IBOutlet UIButton		*ibBuMemory;
	IBOutlet UIButton		*ibBuSetting;
	IBOutlet UIButton		*ibBuInformation;
	IBOutlet UIScrollView	*ibScrollView;
	
@private
	NSArray				*aDrums;
	NSArray				*aDrumButtons;
	//NSMutableArray		*maMemorys;		// in NSString
	NSArray				*aPadKeyButtons;
	
	NSInteger			entryComponent;
	BOOL				bDramRevers;	// これにより、ドラム逆転やりなおしモード時のキー連打不具合に対処している。
	BOOL				bZoomEntryComponent;  // YES= entryComponentの幅を最大にする
	BOOL				bADbannerIsVisible;  // iAd 広告内容があればYES
	BOOL				bADbannerFirstTime;  // iAd 広告内容があれば、起動時に表示するため
	BOOL				bDrumButtonTap1;	// 最初のタップでYES
	
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

//	int					iMemoryCols;	// 行数や高さは、iKeyRows,fKeyHeight を使用
//	float				fMemoryWidth;	// Memoryキートップの幅
	
	// Change Keyboard
	NSArray				*aKeyMaster;	// !=nil キーレイアウト変更モード
	KeyButton			*buChangeKey;	// 選択中のキー
	//NSMutableDictionary *mdKeyboard;	// viewDidLoadではローカルNSDictionaryを使っている。キー配置変更時にだけこれを使用。
	
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

	NSInteger  MiScrollViewPage;	// ibScrollViewの現在表示ページを常に保持
}

- (IBAction)ibBuMemory:(UIButton *)button;
- (IBAction)ibBuSetting:(UIButton *)button;
- (IBAction)ibBuInformation:(UIButton *)button;
- (IBAction)ibButton:(UIButton *)button; // 全電卓ボタンを割り当てている。.tag により識別

- (void)vMemorySave; // AzCalcViewController:applicationWillTerminateからコールされる
- (void)vMemoryLoad; // AzCalcViewController:applicationDidBecomeActiveからコールされる

@end

