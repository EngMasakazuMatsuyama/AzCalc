//
//  AzCalcViewController.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#import "AzCalcAppDelegate.h"

#ifdef GD_Ad_ENABLED
#import <iAd/iAd.h>
#import "GADBannerView.h"
#endif

#define KeyMemorys_MAX		20	// M1〜M20


@class KeyButton;

@interface AzCalcViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate
#ifdef GD_Ad_ENABLED
		,ADBannerViewDelegate
#endif
> {
	IBOutlet UIPickerView*	ibPvDrum;
	IBOutlet UILabel*		ibLbEntry;
	IBOutlet UIButton*		ibBuMemory;
	IBOutlet UIButton*		ibBuSetting;
	IBOutlet UIButton*		ibBuInformation;
	IBOutlet UIScrollView*	ibScrollLower;
	IBOutlet UIScrollView*	ibScrollUpper; //[0.3]
	IBOutlet UITextView*	ibTvFormula;	//[0.3]
	IBOutlet UILabel*		ibLbFormAnswer;
	IBOutlet UIButton*		ibBuFormLeft;
	IBOutlet UIButton*		ibBuFormRight;
	IBOutlet UIButton*		ibBuGetDrum;
	//IBOutlet UIPanGestureRecognizer	*ibPanUpper;
	//IBOutlet UIPanGestureRecognizer	*ibPanLower;
	
@private
	//----------------------------------------------dealloc時にrelese
#ifdef GD_Ad_ENABLED
	ADBannerView*		RiAdBanner;
	GADBannerView*	RoAdMobView;
#endif
	NSArray				*RaDrums;
	NSArray				*RaDrumButtons;
	NSArray				*RaPadKeyButtons;
	NSArray				*RaKeyMaster;	// !=nil キーレイアウト変更モード
	//NSMutableDictionary	*RdicKeyboardSet;  //*RdicAllKeys;	//*dicKeys;
	//NSMutableDictionary	*RdicKeyMemorys;	// M1〜M20 の値を記録
	//NSMutableArray	*RaMemorys;	// M1〜M20 の値を記録
	UIImage				*RimgDrumButton;	
	UIImage				*RimgDrumPush;
	UIView					*mKeyView;
	UIView					*mKeyViewPrev;  // スクロール後に破棄する
	NSString				*mGvKeyUnitSI;
	NSString				*mGvKeyUnitSi2;
	NSString				*mGvKeyUnitSi3;
	
	//[1.0.10] mKm : Keymap
	NSMutableArray		*mKmPages;			// <--(All Page) <--(All KeyButton)
	NSMutableArray		*mKmMemorys;		// <--(Memory KeyButton)
	//NSArray				*mKmUnits;				// <--(Unit KeyButton)
	
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//UIView*			MviewKeyboard;

	//----------------------------------------------assign
	AzCalcAppDelegate	*mAppDelegate;
	NSInteger		entryComponent;
	BOOL				bDramRevers;		// これにより、ドラム逆転やりなおしモード時のキー連打不具合に対処している。
	BOOL				bZoomEntryComponent; // YES= entryComponentの幅を最大にする
	BOOL				bDrumButtonTap1;		// 最初のタップでYES
	BOOL				bDrumRefresh;				// =YES:ドラムを再表示する  =NO:[Copy]後などドラムを動かしたくないとき
	BOOL               bFormulaFilter;				// =YES:ペーストされたのでフィルタ処理する
    BOOL				bPad;								// =YES:iPad  =NO:iPhone
	BOOL				MbInformationOpen;
#ifdef GD_Ad_ENABLED
	BOOL				bADbannerIsVisible;		// iAd 広告内容があればYES
	//BOOL				bADbannerFirstTime;		// iAd 広告内容があれば、起動時に表示するため
	BOOL				bADbannerTopShow;		//[1.0.1]// =YES:トップの広告を表示する  =NO:入力が始まったので隠す
#endif
	
	// Keyboard spec
	int				iKeyPages;
	int				iKeyCols, iKeyOffsetCol;
	int				iKeyRows, iKeyOffsetRow;
	float				fKeyGap;
	float				fKeyFontZoom;
	float				fKeyWidGap;			// キートップ左右の余白
	float				fKeyHeiGap;			// キートップ上下の余白
	float				fKeyWidth;				// キートップの幅
	float				fKeyHeight;				// キートップの高さ
	float				MfTaxRate;				// 消費税率(%)
	float				MfAudioVolume;		// 0.0〜1.0
	
	// Setting
	NSInteger  MiSegDrums;		// ドラム数 ＜＜セグメント値に +1 している＞＞
	NSInteger  MiSegCalcMethod;
	NSInteger  MiSegDecimal;
	NSInteger  MiSegRound;
	NSInteger  MiSegReverseDrum;

	NSInteger  MiSvLowerPage;	// ibScrollLower の現在表示ページを常に保持
	NSInteger  MiSvUpperPage;	// ibScrollUpper の現在表示ページを常に保持
	NSInteger  MiSwipe1fingerCount;		// 1指で3回スワイプされたらヘルプメッセージを出すため
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

#ifdef GD_Ad_ENABLED
- (void)MvShowAdApple:(BOOL)bApple AdMob:(BOOL)bMob;
#endif

@end

