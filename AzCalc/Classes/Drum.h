//
//  Drum.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DRUM_RECORDS	200	// 1ドラムの最大行数制限


@class KeyButton;

@interface Drum : NSObject 
{
@private
	NSMutableArray		*formulaOperators;	// entryOperatorをaddする
	NSMutableArray		*formulaNumbers;	// entryNumberをaddする
	NSMutableArray		*formulaUnits;		// entryUnit をaddする
											
											// Az数値文字列（使用文字は、[+][-][.][0〜9]のみ、スペース無し）
	NSMutableString		*entryAnswer;		// Az数値文字列：前行までの回答値、あれば演算子の前に表示する。数値入力が始まれば非表示
	NSMutableString		*entryOperator;		// NSArray にして MaOperator へ追加する
	NSMutableString		*entryNumber;		// Az数値文字列：入力中は文字列扱いする ＜＜小数以下の0を表示するため ＆ [BS]処理が簡単
	NSMutableString		*entryUnit;			// 単位 [%][‰] [mm][cm][m][km] [￥][＄]
	NSInteger			entryRow;			// 現在選択行　>=0 And <= [aOperators count];

	// Setting
	NSInteger	MiSegCalcMethod;
	NSInteger	MiSegDecimal;
	NSInteger	MiSegRound;
	NSInteger	MiSegReverseDrum;
	float		MfTaxRate;
}

@property (nonatomic, readonly) NSMutableArray	*formulaOperators;	// picker view 表示のためRO
@property (nonatomic, readonly) NSMutableArray	*formulaNumbers;	// picker view 表示のためRO
@property (nonatomic, readonly) NSMutableArray	*formulaUnits;		// picker view 表示のためRO

@property (nonatomic, retain) NSMutableString	*entryAnswer;	
@property (nonatomic, retain) NSMutableString	*entryOperator;	
@property (nonatomic, retain) NSMutableString	*entryNumber;	
@property (nonatomic, retain) NSMutableString	*entryUnit;

@property (nonatomic, assign) NSInteger			entryRow;
//@property (nonatomic, assign) double			dMemory;


- (id)init;											// 初期化
- (void)reSetting;									// Settingリセット
- (NSInteger)count;			// = [formulaOperators count];
- (void)entryKeyTag:(NSInteger)iKeyTag keyButton:(KeyButton *)keyButton;  // キー入力処理
- (BOOL)vNewLine:(NSString *)zNextOperator;	// entryをarrayに追加し、entryを新規作成する
- (void)vCalcing:(NSString *)zNextOperator;
- (NSString *)zFormulaFromDrum;	// ドラム ⇒ 数式
- (NSString *)zAnswerDrum;
- (NSString *)stringFormula;	// ドラム ⇒ ibTvFormula数式

//+ (NSString *)strNumber:(NSString *)sender;

@end
