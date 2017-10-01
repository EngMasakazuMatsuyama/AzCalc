//
//  Global.h
//  AzCalc
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#define AZClass_GoogleAnalytics
#import "AZClass.h"

//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション


#if defined (AzFREE) && !defined(AzMAKE_SPLASHFACE)
#define GD_Ad_ENABLED
//[1.1.6] iAd優先 AdMob補助 方式に戻した。 iAdは30秒以上表示するだけでも収益あり
#define AdMobID_CalcRollPAD		@"a14dd47ad31c249"		// ドラタク　Pad Free パブリッシャー ID
#define AdMobID_CalcRoll				@"a14d4cec7480f76";		// ドラタク　Free パブリッシャー ID
#endif


#define GD_PRODUCTNAME	@"AzCalc"  // IMPORTANT PRODUCT NAME  和名「ドラタク」

#define CALCROLL_EXT			@"calcroll"		//小文字のみ！　　リリース済みにつき変更禁止 （変更するならば旧名にも対応すること）

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


//END
