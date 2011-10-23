//
//  Drum.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AzCalcAppDelegate.h"

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
	NSInteger				entryRow;			// 現在選択行　>=0 And <= [aOperators count];

	AzCalcAppDelegate *appDelegate;  // initにて = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];

	// Setting
	NSInteger	MiSegCalcMethod;
	NSInteger	MiSegDecimal;
	NSInteger	MiSegRound;
	NSInteger	MiSegReverseDrum;
	float		MfTaxRate;
}

@property (nonatomic, retain) NSMutableString	*entryAnswer;	
@property (nonatomic, retain) NSMutableString	*entryOperator;	
@property (nonatomic, retain) NSMutableString	*entryNumber;	
@property (nonatomic, retain) NSMutableString	*entryUnit;
@property (nonatomic, assign) NSInteger			entryRow;

- (id)init;											// 初期化
- (void)reSetting;									// Settingリセット
- (NSInteger)count;			// = [formulaOperators count];
- (void)entryKeyButton:(KeyButton *)keyButton;  // キー入力処理
- (void)entryUnitKey:(KeyButton *)keybu;  // 単位キー処理
- (BOOL)vNewLine:(NSString *)zNextOperator;	// entryをarrayに追加し、entryを新規作成する
//- (void)vCalcing:(NSString *)zNextOperator;
- (void)vEnterOperator:(NSString *)zOperator;

- (NSString *)zFormulaFromDrum;	// ドラム ⇒ 数式
- (NSString *)zAnswerDrum;
- (NSString *)zFormulaCalculator;	// ドラム ⇒ ibTvFormula用の数式文字列

// UNIT Convert
//- (NSString *)zUnitSiFromDrum;	// 現在のドラムで使われているUNIT-SI基本単位
//- (NSString *)zUnitRebuild;		// UNITを使用している場合、その系列に従ってキーやドラム表示を変更する
- (void)GvEntryUnitSet;

// formulaOperators,formulaNumbers,formulaUnits を隠匿するためのメソッド
- (NSString *)zOperator:(NSInteger)iRow;
- (NSString *)zNumber:(NSInteger)iRow;
- (NSString *)zUnitPara:(NSString *)zUnit withPara:(NSInteger)iPara;
- (NSString *)zUnit:(NSInteger)iRow withPara:(NSInteger)iPara;
- (NSString *)zUnit:(NSInteger)iRow;
- (NSString *)zAnswer;
- (void)vRemoveFromRow:(NSInteger)iRow;
//- (void)vEditFromRow:(NSInteger)iRow;



//+ (NSString *)strNumber:(NSString *)sender;

@end
