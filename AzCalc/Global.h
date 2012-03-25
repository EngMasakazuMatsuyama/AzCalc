//
//  Global.h
//  AzCalc
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション


#if defined (AzFREE) && !defined(AzMAKE_SPLASHFACE)
#define GD_Ad_ENABLED
//#define AdMobID_CalcRollPAD		@"a14dd47ad31c249"		// ドラタク　Pad Free パブリッシャー ID
//#define AdMobID_CalcRoll				@"a14d4cec7480f76";		// ドラタク　Free パブリッシャー ID
#endif

#define OR  ||

#ifdef DEBUG	//--------------------------------------------- DEBUG
#define AzDEBUG
#define AzLOG(...) NSLog(__VA_ARGS__)
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }

#else	//----------------------------------------------------- RELEASE
// その他のフラグ：-DNS_BLOCK_ASSERTIONS=1　（NSAssertが除去される）
#define AzLOG(...) 
#define NSLog(...) 
#define AzRETAIN_CHECK(...) 
#endif

#define YES_iPad   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


#define GD_PRODUCTNAME	@"AzCalc"  // IMPORTANT PRODUCT NAME  和名「ドラタク」
/*----- GD_PRODUCTNAME を変更するときに必要となる作業の覚書 -------------------------------
 ＊ソース変更
	AppDelegete.m にて NSBundle名に GD_PRODUCTNAME が渡されている。以下適切に変更しなければ、ここでフリーズする

 *実体ファイル名変更と同時に、XCODEから各ファイルの情報を開いて、実体を再指定(リンク)する
	AzCredit					ルートフォルダ名
	AzCredit_Prefix.pch		プリコンパイルヘッダ
	AzCredit.xcmappingmodel	データマッピング
	AzCredit.xcdatamodeld		データモデル

 ＊XCODE＞プロジェクト＞アクティブターゲット"AzCredit"を編集
		＞一般＞名前を変更
		＞ビルド＞プリダクト名、GCC_PREFIX_HEADRER を変更
		＞プロパティ＞旧名があれば変更

 *iPhoneシニュレータ＞コンテンツと設定をリセット

 *XCODE＞キャッシュを空にする

 *XCODE＞ビルド＞すべてのターゲットをクリーニング

 *XCODE＞ビルドして進行

 -----------------------------------------------------------------------*/

#define PLIST_CalcRoll							@"AzCalcRoll"						// .plistファイル名
#define PLIST_CalcRollPad						@"AzCalcRollPad"				// .plistファイル名

#define GUD_KmPages							@"GUD_KmPagesPhone"				//GUD_KmPages//[1.0.10]からのuserDef保存Key Phone専用ページ
#define GUD_KmPadPages					@"GUD_KmPagesPad"		//GUD_KmPadPages//[1.0.10]からのuserDef保存Key Pad専用ページ
#define GUD_KmPadFunc						@"GUD_KmPadKeys"			//GUD_KmPadFunc//[1.0.10]からのuserDef保存Key Pad拡張キー

// SettingVC
#define DECIMAL_Float	6		// Setting:GUD_Decimal 値がこれ以上ならば浮動小数点処理する　 ＜SettingVC設定に関連＞
#define GUD_Drums							@"GUD_Drums"
#define GUD_CalcMethod					@"GUD_CalcMethod"
#define GUD_Decimal							@"GUD_Decimal"
#define GUD_Round							@"GUD_Round"
#define GUD_ReverseDrum				@"GUD_ReverseDrum"
#define GUD_AudioVolume				@"GUD_AudioVolume"

// OptionVC
#define GUD_TaxRate						@"GUD_TaxRate"
#define GUD_RoundOption					@"GUD_RoundOption"
#define GUD_GroupingSeparator		@"GUD_GroupingSeparator"
#define GUD_GroupingType				@"GUD_GroupingType"
#define GUD_DecimalSeparator			@"GUD_DecimalSeparator"
#define GUD_ButtonDesign				@"GUD_ButtonDesign"


//
// Global.m Functions
//
//void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton );


//
// Google Analytics
//
#import "GANTracker.h"

#define __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) \
					[[GANTracker sharedTracker] startTrackerWithAccountID:ACCOUNT \
					dispatchPeriod:PERIOD delegate:DELEGATE];
#ifdef DEBUGxxxxxxx
#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) { \
			__GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE); \
						[GANTracker sharedTracker].debug = YES; \
						[GANTracker sharedTracker].dryRun = YES; }
#else
#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE);
#endif

#define GA_TRACK_PAGE(PAGE) { NSError *error; if (![[GANTracker sharedTracker] \
														trackPageview:[NSString stringWithFormat:@"/%@", PAGE] \
														withError:&error]) { NSLog(@"GA_TRACK_PAGE: error: %@",error.helpAnchor);  } }

#define GA_TRACK_EVENT(EVENT,ACTION,LABEL,VALUE) { \
						NSError *error; if (![[GANTracker sharedTracker] trackEvent:EVENT action:ACTION label:LABEL value:VALUE withError:&error]) \
						{ NSLog(@"GA_TRACK_EVENT: error: %@",error.helpAnchor); }  }

#define GA_TRACK_EVENT_ERROR(LABEL,VALUE)  { \
						NSString *_zAction_ = [NSString stringWithFormat:@"%@:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd)]; \
						GA_TRACK_EVENT(@"ERROR",_zAction_,LABEL,VALUE); }

#define GA_TRACK_CLASS  { GA_TRACK_PAGE(NSStringFromClass([self class])) }

#define GA_TRACK_METHOD { GA_TRACK_EVENT(NSStringFromClass([self class]),NSStringFromSelector(_cmd),@"",0); }


//END
