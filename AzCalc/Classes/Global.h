//
//  Global.h
//  AzCalc
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション
#define GD_iAd_ENABLED
#define GD_AdMob_ENABLED

#define GD_UNIT_ENABLED		// 単位機能

#define OR  ||

#ifdef AzDEBUG 
#define AzLOG(...) NSLog(__VA_ARGS__)
#else
#define AzLOG(...) 
#endif

#ifdef AzDEBUG
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }
#else
#define AzRETAIN_CHECK(...) 
#endif


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

#define GUD_KeyboardSet					@"GUD_KeyboardSet"  // NSMutableDictionary
#define GUD_KeyMemorys					@"GUD_KeyMemorys"	// NSMutableDictionary

// SettingVC
#define DECIMAL_Float	6		// Setting:GUD_Decimal 値がこれ以上ならば浮動小数点処理する　 ＜SettingVC設定に関連＞
#define GUD_Drums						@"GUD_Drums"
#define GUD_CalcMethod					@"GUD_CalcMethod"
#define GUD_Decimal						@"GUD_Decimal"
#define GUD_Round						@"GUD_Round"
#define GUD_ReverseDrum					@"GUD_ReverseDrum"

// OptionVC
#define GUD_TaxRate						@"GUD_TaxRate"
#define GUD_RoundOption					@"GUD_RoundOption"
#define GUD_GroupingSeparator			@"GUD_GroupingSeparator"
#define GUD_GroupingType				@"GUD_GroupingType"
#define GUD_DecimalSeparator			@"GUD_DecimalSeparator"


//END
