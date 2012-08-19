//
//  AzCalcViewController.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#ifdef GD_Ad_ENABLED
//[1.1.6] iAd優先 AdMob補助 方式に戻した。 iAdは30秒以上表示するだけでも収益あり
#import <iAd/iAd.h>
#import "GADBannerView.h"
//#import "AdWhirlView.h"
//#import "AdWhirlDelegateProtocol.h"
//#define GAD_SIZE_320x50     CGSizeMake(320, 50)
//#import "MasManagerViewController.h"
//#import "NADView.h"  //AppBank nend
#endif

#import "AzCalcAppDelegate.h"
#import "AZDropboxVC.h"


#define KeyMemorys_MAX		20	// M1〜M20


@class KeyButton;

@interface AzCalcViewController : UIViewController  <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate, AZDropboxDelegate
#ifdef GD_Ad_ENABLED
		//, AdWhirlDelegate, NADViewDelegate, ADBannerViewDelegate
		, ADBannerViewDelegate, GADBannerViewDelegate
#endif
> {
	IBOutlet UIPickerView	*ibPvDrum;
	IBOutlet UILabel			*ibLbEntry;
	IBOutlet UIButton		*ibBuMemory;
	IBOutlet UIButton		*ibBuSetting;
	IBOutlet UIButton		*ibBuInformation;
	IBOutlet UIScrollView	*ibScrollLower;
	IBOutlet UIScrollView	*ibScrollUpper; //[0.3]
	IBOutlet UITextView	*ibTvFormula;	//[0.3]
	IBOutlet UILabel			*ibLbFormAnswer;
	IBOutlet UIButton		*ibBuFormLeft;
	IBOutlet UIButton		*ibBuFormRight;
	IBOutlet UIButton		*ibBuGetDrum;
	
@private
	NSArray				*RaDrums;
	NSArray				*RaDrumButtons;
	NSArray				*RaKeyMaster;	// !=nil キーレイアウト変更モード
	UIImage				*RimgDrumButton;	
	UIImage				*RimgDrumPush;
	UIView					*mKeyView;
	UIView					*mKeyViewPrev;  // スクロール後に破棄する
	NSString				*mGvKeyUnitSI;
	NSString				*mGvKeyUnitSi2;
	NSString				*mGvKeyUnitSi3;
	NSArray				*mPadMemoryKeyButtons; // <--(KeyButton *)[M]
	
	//[1.0.10] mKm : KeyMap   ＜＜＜注意！ 配下も全てMutableにすること。
	NSMutableArray		*mKmPages;			// <--(NSMutableArray *)All Page <--(NSMutableDictionary *) キー配列
	NSMutableArray		*mKmPadFunc;		// <--(NSMutableDictionary *) iPad拡張メモリキー配列
	NSMutableArray		*mKmMemorys;		// <--(NSMutableDictionary *) mKmPagesとmKmPadFuncの[M]キーをリンクしている
	
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
	ADBannerView						*RiAdBanner;
	GADBannerView						*RoAdMobView;
	//GADBannerView*	RoAdMobView;
	//AdWhirlView							*mAdWhirlView;
	//NADView									*mNendView;
	//MasManagerViewController	*mMedibaAd; 

	BOOL				bADbannerIsVisible;		// iAd 広告内容があればYES
	BOOL				bAdShow;						// 広告表示可否
	//BOOL				bADbannerFirstTime;		// iAd 広告内容があれば、起動時に表示するため
	//[1.1.6]Ad隠さない、常時表示する。
	//BOOL				bADbannerTopShow;		//[1.0.1]// =YES:トップの広告を表示する  =NO:入力が始まったので隠す
#endif
	
	// Keyboard spec
	int				iKeyPages;
	int				iKeyCols; //, iKeyOffsetCol;
	int				iKeyRows; //, iKeyOffsetRow;
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
	
	AVAudioPlayer	*mSoundClick;	//ARCにより破棄されないようにするため
	AVAudioPlayer	*mSoundSwipe;
	AVAudioPlayer	*mSoundLock;
	AVAudioPlayer	*mSoundUnlock;
	AVAudioPlayer	*mSoundRollex;	//Roll切替音
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
- (void)adShow:(BOOL)bShow;	// applicationDidEnterBackground:から呼び出される
#endif

// delegate
- (NSString*)GzCalcRollLoad:(NSString*)zCalcRollPath;
- (void)GvDropbox:(UIViewController*)rootViewController;

@end

