//
//  CalcFunctions.h
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBCD.h"  // BCD固定小数点演算 ＜＜この.cpp関数を利用するファイルの拡張子は .m ⇒ .mm にすること＞＞

#define PRECISION		 15	// 有効桁数＝整数桁＋小数桁（小数点は含まない）

// Operator String
#define OP_START	@">" // 願いましては
#define OP_ADD		@"+" // 加算
#define OP_SUB		@"-" // 減算 Unicode[002D] 内部用文字（String ⇒ doubleValue)変換のために必須
#define OP_MULT		@"×" // 掛算
#define OP_DIVI		@"÷" // 割算
#define OP_ANS		@"=" // 答え
#define OP_GT		@">GT" // 総計 ＜＜1字目を OP_START にして「開始行」扱いすることを示す＞＞
#define OP_ROOT		@"√"	// ルート

// Number String
#define NUM_0		@"0"
#define NUM_DECI	@"."	// 小数点

// Unit String
#define UNI_PERC	@"%"	// パーセント
#define UNI_PERML	@"‰"	// パーミル
#define UNI_AddTAX	@"+Tax"	// 税込み
#define UNI_SubTAX	@"-Tax"	// 税抜き


@interface CalcFunctions : NSObject {
}

// クラスメソッド（グローバル関数）
+ (void)setCalcMethod:(NSInteger)i;
+ (void)setDecimal:(NSInteger)i;
+ (void)setRound:(NSInteger)i;
+ (NSString *)zAnswerFromFormula:(NSString *)zFormula; // 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え

@end
