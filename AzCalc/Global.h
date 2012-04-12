//
//  Global.h
//  AzCalc
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AZClass.h"

//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション


#if defined (AzFREE) && !defined(AzMAKE_SPLASHFACE)
#define GD_Ad_ENABLED
//#define AdMobID_CalcRollPAD		@"a14dd47ad31c249"		// ドラタク　Pad Free パブリッシャー ID
//#define AdMobID_CalcRoll				@"a14d4cec7480f76";		// ドラタク　Free パブリッシャー ID
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


//END
