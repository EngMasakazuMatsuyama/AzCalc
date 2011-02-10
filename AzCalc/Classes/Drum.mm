//
//  Drum.mm　＜＜＜BCD.cpp関数を利用しているため.mmにする必要がある＞＞＞
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#include "SBCD.h"  // BCD固定小数点演算 ＜＜この.cpp関数を利用するファイルの拡張子は .m ⇒ .mm にすること＞＞
#import "Drum.h"
#import "KeyButton.h"


//[0.3]-----------------------------------------------------NSMutableArray Stack Method
@interface NSMutableArray (StackAdditions)
- (void)push:(id)obj;
- (id)pop;
@end

@implementation NSMutableArray (StackAdditions)
- (void)push:(id)obj
{
	[self addObject: obj];
}

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [[[self lastObject] retain] autorelease];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}
@end
//----------------------------------------------------------NSMutableArray Stack Method



@interface Drum (PrivateMethods)
- (BOOL)vNewLine:(NSString *)zNextOperator;	// entryをarrayに追加し、entryを新規作成する
- (void)vEnterOperator:(NSString *)zOperator;
- (NSInteger)iNumLength:(NSString *)zNum;
@end

@implementation Drum

@synthesize formulaOperators, formulaNumbers, formulaUnits;
@synthesize entryAnswer, entryOperator, entryNumber, entryUnit, entryRow;


- (void)dealloc 
{
	[entryUnit release];
	[entryNumber release];
	[entryOperator release];
	[entryAnswer release];
	
	[formulaUnits release];
	[formulaNumbers release];
	[formulaOperators release];

    [super dealloc];
}

- (id)init		// 初期化
{
	self = [super init];
	if (self != nil)
	{
		formulaOperators = [NSMutableArray new];
		formulaNumbers = [NSMutableArray new];
		formulaUnits = [NSMutableArray new];
		
		entryAnswer = [NSMutableString new];
		entryOperator = [[NSMutableString alloc] initWithString:OP_START];
		entryNumber = [NSMutableString new];
		entryUnit = [NSMutableString new];
		
		entryRow = 0;
		//dMemory = 0.0;
		
		[self reSetting];
	}
	return self;
	
}

- (void)reSetting				// Settingリセット
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Setting
	MiSegCalcMethod = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
	MiSegDecimal = (NSInteger)[defaults integerForKey:GUD_Decimal];
	if (DECIMAL_Float <= MiSegDecimal) MiSegDecimal = PRECISION; // [F]小数桁制限なし
	MiSegRound = (NSInteger)[defaults integerForKey:GUD_Round];
	MiSegReverseDrum = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];
}


- (NSInteger)count
{
	return [formulaOperators count];
}


- (void)entryKeyTag:(NSInteger)iKeyTag keyButton:(KeyButton *)keyButton  // キー入力処理
{
	AzLOG(@"entryKeyTag: (%d)", iKeyTag);
	
	// これ以降、localPool管理エリア
	NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
	// 以後、return;使用禁止！すると@finallyを通らず、localPoolが解放されない。
	//AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	@try {
		switch (iKeyTag) { // .Tag は、AzKeyMaster.plist の定義が元になる。
				//---------------------------------------------[0]-[99] Numbers
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				if ([entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
				}
				if (PRECISION-2 <= [entryNumber length]) { // [-][.]を考慮して(-2)
					// 改めて[-][.]を除いた有効桁数を調べる
					if (PRECISION <= [self iNumLength:entryNumber]) {
						break; // 有効桁数に到達
					}
				}
				if ([entryNumber hasPrefix:@"0"] OR [entryNumber hasPrefix:@"-0"]) {
					NSRange rg = [entryNumber rangeOfString:NUM_DECI];
					if (rg.location==NSNotFound) { // 小数点が無い ⇒ 整数部である
						if (0 < iKeyTag) { // 末尾の[0]を削除して数値を追加する
							[entryNumber deleteCharactersInRange:NSMakeRange([entryNumber length]-1, 1)]; // 末尾より1字削除
						} else break; // 2個目以降の[0]は無効
					}
				}
				[entryNumber appendFormat:@"%d", (int)iKeyTag];
				break;
				
				/*	case 10: // [A]  ＜＜HEX対応のため保留＞＞
				 case 11: // [B]
				 case 12: // [C]
				 case 13: // [D]
				 case 14: // [E]
				 case 15: // [F]
				 [entryNumber appendFormat:@"%d", (int)iKeyTag];
				 break; */
				
			case KeyTAG_DECIMAL: // [.]小数点
				if ([entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
				}
				if ([entryNumber length] <= 0) {
					[entryNumber appendString:@"0"]; // 最初に小数点が押された場合、先に0を入れる
				}
				else {
					NSRange rg = [entryNumber rangeOfString:NUM_DECI];
					if (rg.location != NSNotFound) { // 既に小数点がある（2個目である）
						break; // 無効  ＜＜return;ダメ！すると@finallyを通らない＞＞
					}
				}
				[entryNumber appendString:NUM_DECI];
				break;
				
			case KeyTAG_00: // [00]
				if (PRECISION-3 <= [entryNumber length]) { // [-][.]を考慮して(-2)
					// 改めて[-][.]を除いた有効桁数を調べる
					if (PRECISION-1 <= [self iNumLength:entryNumber]) {
						break; // 有効桁数に到達
					}
				}
				if ([entryNumber doubleValue] != 0.0) {
					[entryNumber appendString:@"00"];
				} else {
					NSRange rg = [entryNumber rangeOfString:NUM_DECI];
					if (rg.location != NSNotFound) { // 小数点あり
						[entryNumber appendString:@"00"];
					}
				}

				break;
				
			case KeyTAG_000: // [000]
				if (PRECISION-4 <= [entryNumber length]) { // [-][.]を考慮して(-2)
					// 改めて[-][.]を除いた有効桁数を調べる
					if (PRECISION-2 <= [self iNumLength:entryNumber]) {
						break; // 有効桁数に到達
					}
				}
				if ([entryNumber doubleValue] != 0.0) {
					[entryNumber appendString:@"000"];
				} else {
					NSRange rg = [entryNumber rangeOfString:NUM_DECI];
					if (rg.location != NSNotFound) { // 小数点あり
						[entryNumber appendString:@"000"];
					}
				}
				break;
			
			case KeyTAG_SIGN: // [+/-]
				if ([entryOperator hasPrefix:OP_ANS]) break; // [=]ならば無効
				if ([entryNumber doubleValue] < 0) {
					// 先頭の"-"を削除する
					[entryNumber deleteCharactersInRange:NSMakeRange(0,1)];
				} 
				else if (0 < [entryNumber doubleValue]) {
					// 先頭に"-"を挿入する
					[entryNumber insertString:OP_SUB atIndex:0];
				}
				break;
				
			case KeyTAG_PERC: // [%]パーセント ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する
				if ([entryNumber length]<=0) break; // 数値なし無効
				if ([entryOperator hasPrefix:OP_ANS]) {
					// [=]回答行で[%]を押したとき、改行して式を表示する   entryNumberは「Az数値文字列」である
					NSString *zNum = [NSString stringWithString:entryNumber]; // copy autolease
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// 新セクション
					[entryNumber setString:zNum]; // Az数値文字列をセット
					[entryUnit setString:NUM_PERC];
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				else {
					[entryUnit setString:NUM_PERC];
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				break;
			case KeyTAG_PERM: // [‰]パーミル ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する
				if ([entryNumber length]<=0) break; // 数値なし無効
				if ([entryOperator hasPrefix:OP_ANS]) {
					// [=]回答行で[‰]を押したとき、改行して式を表示する   entryNumberは「Az数値文字列」である
					NSString *zNum = [NSString stringWithString:entryNumber]; // copy autolease
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// 新セクション
					[entryNumber setString:zNum]; // Az数値文字列をセット
					[entryUnit setString:NUM_PERM];
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				else {
					[entryUnit setString:NUM_PERM];
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				break;
			case KeyTAG_ROOT: // [√]ルート
				if ([entryOperator hasPrefix:OP_ANS] && 0 < [entryNumber length]) {
					// [=]回答行で[√]を押したとき、改行して式を表示する   entryNumberは「Az数値文字列」である
					NSString *zNum = [NSString stringWithString:entryNumber]; // copy autolease
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// 新セクション
					[entryOperator appendString:NUM_ROOT]; // 演算子の末尾へ
					[entryNumber setString:zNum]; // Az数値文字列をセット
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				else {
					// 演算子後部に[√]を追加して計算式の一部にする
					if (![entryOperator hasSuffix:NUM_ROOT]) {
						[entryOperator appendString:NUM_ROOT]; // 演算子の末尾へ
					}
				}
				break;
				
				//---------------------------------------------[100]-[199] Operators
			case KeyTAG_ANSWER: // [=]
				if ([entryOperator length] <= 0) { // 演算子なし
					// 前行まで計算し回答する
					[entryAnswer setString:@""];
					[entryOperator setString:OP_ANS];
					[entryNumber setString:[self zAnswerDrum]]; 
					[entryUnit setString:@""];
					break;  // ＜＜return;ダメ！すると@finallyを通らない＞＞
				}
				else if ([entryOperator hasPrefix:OP_START]) { 
					// 前行が[>]であるとき
					// ↓ vCalcing
				}
				else if ([entryOperator hasPrefix:OP_ANS]) {
					// 前行が[=]であるとき、[=]が繰り返されたことになる
					// 直前と同じ計算を繰り返す ＜＜シャープモード＞＞
					if ([[formulaOperators lastObject] hasPrefix:OP_START]) { // 前行が[>]であるとき
						break;  // 直前が開始行なので無効   ＜＜return;ダメ！すると@finallyを通らない＞＞
					}
					// 直前の式をEntryにセット
					[entryOperator setString:[formulaOperators lastObject]];
					if ([entryOperator length] <= 0) {
						[entryOperator setString:OP_ADD]; // 直前の演算子が無いとき(最上行)、"+"にする
					}
					[entryNumber setString:[formulaNumbers lastObject]];
					[entryUnit setString:[formulaUnits lastObject]];
					// ↓ vCalcing
				}
				else if ([entryNumber isEqualToString:@""]) { 
					// 数値未定
				//	if (![entryOperator isEqualToString:@""]) {
				//		// [=]でない演算子が入っている
				//		// 前行の数値を引用する ＜＜シャープモード＞＞
				//		[entryNumber setString:[formulaNumbers lastObject]];
				//		// ↓ vCalcing
				//	} else {
						// 演算子が無い
						// 回答する
						[entryOperator setString:OP_ANS];
						[entryNumber setString:[self zAnswerDrum]]; 
						break;
				//	}
					// ↓ vCalcing
				}
				// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				[self vCalcing:OP_ANS];
				break;
				
			case KeyTAG_PLUS: // [+]
				[self vEnterOperator:OP_ADD]; break;
			case KeyTAG_MINUS: // [-]
				[self vEnterOperator:OP_SUB]; break;
			case KeyTAG_MULTI: // [×]
				[self vEnterOperator:OP_MULT]; break;
			case KeyTAG_DIVID: // [÷]
				[self vEnterOperator:OP_DIVI]; break;

			case KeyTAG_GT: { // [GT] Ground Total: 1ドラムの全[=]回答値の合計
				// まず[=]と同様の処理をする。その後、[GT]処理する
				if ([entryOperator hasPrefix:OP_START]) { 
					// 前行が[>]であるとき
					break;  // 無効   ＜＜return;ダメ！すると@finallyを通らない＞＞
				}
				else if ([entryOperator hasPrefix:OP_ANS]) {
					// 前行が[=]であるとき
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// ↓ [GT]
				}
				else if ([entryNumber isEqualToString:@""]) { 
					[entryOperator setString:OP_ANS];
					[entryNumber setString:[self zAnswerDrum]]; 
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// ↓ [GT]
				}
				// [GT]
				char cNum[SBCD_PRECISION+100];
				char cAns[SBCD_PRECISION+100];
				//sprintf(cAns, "%s", (char *)[@"0" cStringUsingEncoding:NSASCIIStringEncoding]); 
				strcpy(cAns, (char *)[@"0" cStringUsingEncoding:NSASCIIStringEncoding]); 
				for (NSInteger iRow = 0; iRow < [formulaOperators count]; iRow++) 
				{	// 全行から[=]行を見つけて、その値を合計する
					if ([[formulaOperators objectAtIndex:iRow] hasPrefix:OP_ANS]) {
						// [=]回答値
						sprintf(cNum, "%s", (char *)[[formulaNumbers objectAtIndex:iRow] cStringUsingEncoding:NSASCIIStringEncoding]); 
						stringAddition( cAns, cAns, cNum ); // cAns = cAns + cNum
					}
				}
				//NSString *zAns; [zAns getCString:cNum maxLength:SBCD_PRECISION encoding:NSASCIIStringEncoding];
				NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
				[entryOperator setString:OP_GT]; // [>GT]
				[entryNumber setString:zAns];
				[entryUnit setString:@""];
				if (![zAns hasPrefix:@"@"]) { // !ERROR
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
				}
			} break;

				
				//---------------------------------------------[200]-[299] Functions
			case KeyTAG_AC: // [AC]
				[formulaOperators removeAllObjects];	[entryOperator setString:OP_START];
				[formulaNumbers removeAllObjects];		[entryNumber setString:@""];
				[formulaUnits removeAllObjects];		[entryUnit setString:@""];
				entryRow = 0;							[entryAnswer setString:@""];
				break;
				
			case KeyTAG_BS: { // [BS]
				if (0 < [entryUnit length]) {
					//[entryUnit deleteCharactersInRange:NSMakeRange([entryUnit length]-1, 1)]; // 末尾より1字削除
					[entryUnit setString:@""]; // Operatorと同様に一括クリアする
				}
				else if (0 < [entryNumber length]) {
					[entryNumber deleteCharactersInRange:NSMakeRange([entryNumber length]-1, 1)]; // 末尾より1字削除
				}
				else if (1 < [entryOperator length]) {
					[entryOperator substringToIndex:1]; // 演算子は消さない
				}
			} break;
		}
	}
	@finally { //*****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!
		[localPool release];
	}
}

- (BOOL)vNewLine:(NSString *)zNextOperator		// entryをarrayに追加し、entryを新規作成する
{
	if (DRUM_RECORDS-1 <= [formulaOperators count]) {  // 1ドラム最大行数制限
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Final answer", nil)
														message:NSLocalizedString(@"Final answer msg", nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		if (DRUM_RECORDS <= [formulaOperators count]) { // 最終行オーバー：entry行に[=]回答を表示する
			[entryOperator setString:OP_ANS];
			[entryNumber setString:[self zAnswerDrum]]; 
			return NO; // 最終行オーバーにつき拒否
		}
		// 最終行
	}
	
	// Operator: entryをarrayに追加し、entryを新規作成する
	assert( entryOperator != nil );
	[formulaOperators addObject:entryOperator];
	[entryOperator release];
	entryOperator = [[NSMutableString alloc] initWithString:zNextOperator];
	entryRow = [formulaOperators count];
	
	// Number: entryをarrayに追加し、entryを新規作成する
	assert( entryNumber != nil );
	[formulaNumbers addObject:entryNumber];
	[entryNumber release];
	entryNumber = [NSMutableString new];
	
	// Unit: entryをarrayに追加し、entryを新規作成する
	AzLOG(@"******************formulaUnits addObject:entryUnit=[%@]*****************", entryUnit);
	assert( entryUnit != nil );
	[formulaUnits addObject:entryUnit];
	[entryUnit release];
	entryUnit = [NSMutableString new];
	
	// entryAnswer は、addObjectしないのでクリアするだけ。
	[entryAnswer setString:@""];
	
	// formula へ addObject しているのはここだけ。 要素数は、必ず一致すること。
	// もし、ここでエラー発生したときは、「ドラム逆回転時の処理」で削除が適切に行われているか確認すること。
	assert( [formulaOperators count] == [formulaNumbers count] );
	assert( [formulaOperators count] == [formulaUnits count] );
	return YES;
}


//============================================================================================
// zOperator により改行が発生するときの処理
//============================================================================================
- (void)vEnterOperator:(NSString *)zOperator // [+][-][×][÷]
{
	if (0<[entryOperator length] && 0<[entryNumber length] && ![entryOperator hasPrefix:OP_ANS]) {
		// entryの演算子と数値が有効であるなら追加計算
		// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理する
		[self vCalcing:zOperator];
		return;
	}
	else if ([entryOperator hasPrefix:OP_START]) {
		// 開始行
		if ([zOperator isEqualToString:OP_SUB]) { 
			// [-] ならば値をマイナス値にする
			if ([entryNumber hasPrefix:OP_SUB]) {
				// 先頭が"-"ならば、先頭の"-"を削除する
				[entryNumber deleteCharactersInRange:NSMakeRange(0,1)];
			} else {
				// 先頭に"-"を挿入する　＜＜数値未定の場合、符号だけ先に入ることになる＞＞
				[entryNumber insertString:OP_SUB atIndex:0];
			}
		}
		[entryAnswer setString:@""]; // 回答クリア
		return;
	}
	else {
		[entryAnswer setString:[self zAnswerDrum]]; // ここまでの回答を演算子の前に表示する
		[entryOperator setString:zOperator];
		[entryNumber setString:@""]; // 数値クリア
	}
}


//============================================================================================
// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理する
//============================================================================================
- (void)vCalcing:(NSString *)zNextOperator
{
	if ([entryNumber length]<=0) {
		// 数値未定
		if (! [entryOperator hasPrefix:OP_START]) { // 開始行でない！ならば、演算子だけ変更して計算しない
			[entryOperator setString:zNextOperator];
		}
		return;
	}

	//AzLOG(@"********************************entryUnit=1=[%@]", entryUnit);
	// 新しい行を追加する
	if (![self vNewLine:zNextOperator]) return;

	if ([zNextOperator isEqualToString:OP_ANS]) { 
		// [=]が押されたならば、計算結果表示
		[entryNumber setString:[self zAnswerDrum]]; 
	} else {
		// ここまでの回答を演算子の前に表示する
		[entryAnswer setString:[self zAnswerDrum]]; 
	}
}


/*
 ドラム ⇒ 数式
 1000 - 20 % ⇒ 1000 - (1000 * 0.20)  　＜＜シャープ電卓方式
 1000 + 20 % ⇒ 1000 + (1000 * 0.20)  　＜＜シャープ電卓方式

*/
- (NSString *)zFormulaFromDrum	// ドラム ⇒ 数式
{
	// 現在行より前にある[=][GT]行の次から計算する　＜＜セクション単位に計算する
	if (entryRow <= 0 OR [formulaOperators count] < entryRow) return @"";

	// ドラム情報から計算文字列式を生成する
	NSString *zFormula = @"";  //[[NSString new] autorelease];  // 途中 return;で抜けているため。
	
	//-------------------------------------------------localPool BEGIN >>> @finaly release
	NSAutoreleasePool *autoPool = [NSAutoreleasePool new];
	@try {
		NSInteger iRowStart = 0; // 最初から
		if (2 <= entryRow) {
			if ([formulaOperators count] <= entryRow) {
				iRowStart = [formulaOperators count] - 1;
			} else {
				iRowStart = entryRow;
			}
			for ( ; 0 < iRowStart; iRowStart--) {
				if ([[formulaOperators objectAtIndex:iRowStart] hasPrefix:OP_ANS]	// 直前の[=]の次にする
					OR [[formulaOperators objectAtIndex:iRowStart] hasPrefix:OP_GT]) {	// 直前の[>GT]の次にする
					iRowStart++;
					break;
				}
			}
		}
		// 計算対象範囲は、iRowStart 〜 iRowEnd まで
		NSInteger iRowEnd = entryRow;
		if ([formulaOperators count] <= iRowEnd) {
			iRowEnd = [formulaOperators count] - 1;
		}
		AzLOG(@"zAnswerDrum: Drum Row[ %d >>> %d ]", iRowStart, iRowEnd);
		if (iRowEnd < iRowStart) {
			@throw @"iRowEnd < iRowStart";
		}
		assert(iRowStart <= iRowEnd);
		
		for (NSInteger idx = iRowStart; idx <= iRowEnd; idx++) 
		{
			// 演算子部
			NSString *zOpe = @"";
			if ([[formulaOperators objectAtIndex:idx] hasPrefix:OP_START]) { // 開始行
				// 開始行の演算子には[>]が入っている。その右に入る可能性があるのは今の所、[√]だけ。
				if (1 < [[formulaOperators objectAtIndex:idx] length]) {
					zOpe = [[formulaOperators objectAtIndex:idx] substringFromIndex:1]; // OP_STARTより後の文字 [√]
				}
			} else {
				zOpe = [formulaOperators objectAtIndex:idx];
			}
			//AzLOG(@"--zOpe=%@", zOpe);
			
			// 数値部 ＆ 単位部
			AzLOG(@"******************(%d)[%@]*****************", idx, [formulaUnits objectAtIndex:idx]);
			if ([[formulaUnits objectAtIndex:idx] isEqualToString:NUM_PERC]) {
				if ([[formulaOperators objectAtIndex:idx] hasPrefix:OP_ADD]) {
					// ＋％増　＜＜シャープ式： a[+]b[%] = aのb%増＞＞
					zFormula = [zFormula stringByAppendingFormat:@"*(1+(%@*0.01))", 
								[formulaNumbers objectAtIndex:idx]];
				}
				else if ([[formulaOperators objectAtIndex:idx] hasPrefix:OP_SUB]) {
					// ー％減　＜＜シャープ式： a[-]b[%] = aのb%減＞＞
					zFormula = [zFormula stringByAppendingFormat:@"*(1-(%@*0.01))", 
								[formulaNumbers objectAtIndex:idx]];
				}
				else {
					zFormula = [zFormula stringByAppendingFormat:@"%@(%@*0.01)", // 1/100
								zOpe, [formulaNumbers objectAtIndex:idx]];
				}
			} 
			else if ([[formulaUnits objectAtIndex:idx] isEqualToString:NUM_PERM]) {
				zFormula = [zFormula stringByAppendingFormat:@"%@(%@*0.001)", // 1/1000 
							zOpe, [formulaNumbers objectAtIndex:idx]];
			} 
			else {
				zFormula = [zFormula stringByAppendingFormat:@"%@ %@ ", 
							zOpe, [formulaNumbers objectAtIndex:idx]];
			}
			//AzLOG(@"--zFormula=%@", zFormula);
		}
		// 数値と演算子の間のスペースはあってもなくても大丈夫
		// localPoolが解放される前に確保しておく
		[zFormula retain];
	}
	@catch (NSException * errEx) {
		NSLog(@"zDrumFormula:Exception: %@: %@\n", [errEx name], [errEx reason]);
		zFormula = nil;
	}
	@catch (NSString *msg) {
		NSLog(@"zDrumFormula:@throw: %@\n", msg);
		zFormula = nil;
	}
	@finally {
		[autoPool release];
	}
	NSLog(@"zFormula=%@", zFormula);
	return [zFormula autorelease];
}

int levelOperator( NSString *zOpe )  // 演算子の優先順位
{
	if ([zOpe isEqualToString:@"*"] || [zOpe isEqualToString:@"/"]) {
		return 1;
	}
	else if ([zOpe isEqualToString:@"+"] || [zOpe isEqualToString:@"-"]) {
		return 2;
	}
	return 99;
}

/*
 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation)
 "5 + 4 - 3"	⇒ "5 4 3 - +"
 "5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
 "(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 "T ( 5 + 2 )" ⇒ "5 2 + T"
 
 "1000 + 5%" ⇒ "(1000 * 1.05)" ⇒ "1000 1.05 *"		＜＜1000の5%増：税込み＞＞　シャープ式
 "1000 - 5%" ⇒ "(1000 / 1.05)" ⇒ "1000 1.05 /"		＜＜1000の5%減：税抜き＞＞　シャープ式
 
 "1000 * √2" ⇒ "1000 * (√2)" ⇒ "1000 1.4142 *"		＜＜ルート対応
 */
- (NSString *)zAnswerFromFormula:(NSString *)zFormula	// 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	AzLOG(@"zFormula=%@", zFormula);
	if ([zFormula length]<2) return nil;
	
	NSMutableArray *maStack = [NSMutableArray new];	// - Stack Method
	NSMutableArray *maRpn = [NSMutableArray new]; // 逆ポーランド記法結果
	NSString *zAnswer = nil;
	
	//-------------------------------------------------localPool BEGIN >>> @finaly release
	NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
	@try {
		// 数式整理
		NSString *zTemp = [zFormula stringByReplacingOccurrencesOfString:@" " withString:@""]; // [ ]スペース除去
		NSString *zFlag = nil;
		if ([zTemp hasPrefix:@"-"] || [zTemp hasPrefix:@"+"]) {		// 先頭が[-]や[+]ならば符号として処理する
			zFlag = [zTemp substringToIndex:1]; // 先頭の1字
			zTemp = [zTemp substringFromIndex:1]; // 先頭の1字を除く
		}
		// マイナス「符号」⇒ "s"
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×-" withString:@"×s"];  
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷-" withString:@"÷s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+-" withString:@"+s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"--" withString:@"-s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(-" withString:@"(s"];
		// 残った "-" は「演算子」なので " - " にする	"-("  ")-"
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-" withString:@" - "];  
		// "s" を "-" にする
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"s" withString:@"-"];
		
		// 演算子の両側にスペース挿入
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"*"	withString:@" * "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"/"	withString:@" / "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_MULT withString:@" * "]; // "×"半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_DIVI withString:@" / "]; // "÷"半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:NUM_ROOT withString:@" √ "]; // 前後スペース挿入
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+"	withString:@" + "]; // [-]は演算子ではない
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"("	withString:@" ( "];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@")"	withString:@" ) "];
		
		if (zFlag) {
			zTemp = [zFlag stringByAppendingString:zTemp]; // 先頭に符号を付ける
		}
		// スペースで区切られたコンポーネント(部分文字列)を切り出す
		NSArray *arComp = [zTemp componentsSeparatedByString:@" "];
		NSLog(@"arComp[]=%@", arComp);
		
		NSInteger iCapLeft = 0;
		NSInteger iCapRight = 0;
		NSInteger iCntOperator = 0;	// 演算子の数　（関数は除外）
		NSInteger iCntNumber = 0;	// 数値の数
		NSString *zTokn;
		NSString *zz;
		
		
		for (int index = 0; index < [arComp count]; index++) 
		{
			zTokn = [arComp objectAtIndex:index];
			AzLOG(@"arComp[%d]='%@'", index, zTokn);
			
			if ([zTokn length] < 1 || [zTokn hasPrefix:@" "]) {
				// パス
			}
			else if ([zTokn doubleValue] != 0.0 || [zTokn hasSuffix:@"0"]) {		// 数値ならば
				iCntNumber++;
				[maRpn push:zTokn];
			}
			else if ([zTokn isEqualToString:@"√"]) {
				//[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
				[maStack push:zTokn]; // スタックPUSH
			}
			else if ([zTokn isEqualToString:@")"]) {	// "("までスタックから取り出してRPNへ追加、両括弧は破棄する
				iCapRight++;
				while (zz = [maStack pop]) {
					if ([zz isEqualToString:@"("]) break; // 両カッコは、破棄する
					[maRpn push:zz];
				}
			}
			else if ([zTokn isEqualToString:@"("]) {
				iCapLeft++;
				[maStack push:zTokn];
			}
			else {
				while (0 < [maStack count]) {
					//			 スタック最上位の演算子優先順位 ＜ トークンの演算子優先順位
					if (levelOperator([maStack lastObject]) <= levelOperator(zTokn)) {
						[maRpn push:[maStack pop]];  // スタックから取り出して、それをRPNへ追加
					} else {
						break;
					}
				}
				// スタックが空ならばトークンをスタックへ追加する
				iCntOperator++;
				[maStack push:zTokn];
			}
		}
		// スタックに残っているトークンを全て逆ポーランドPUSH
		while (zz = [maStack pop]) {
			[maRpn push:zz];
		}
		// 数値と演算子の数チェック
		if (iCntNumber < iCntOperator + 1) {
			@throw NSLocalizedString(@"Too many operators", nil); // 演算子が多すぎる
		}
		else if (iCntNumber > iCntOperator + 1) {
			@throw NSLocalizedString(@"Insufficient operator", nil); // 演算子が足らない
		}
		// 括弧チェック
		if (iCapLeft < iCapRight) {
			@throw NSLocalizedString(@"Closing parenthesis is excessive", nil); // 括弧が閉じ過ぎ
		}
		else if (iCapLeft > iCapRight) {
			@throw NSLocalizedString(@"Unclosed parenthesis", nil); // 括弧が閉じていない
		}
#ifdef AzDEBUG
		for (int index = 0; index < [maRpn count]; index++) 
		{
			AzLOG(@"maRpn[%d]='%@'", index, [maRpn objectAtIndex:index]);
		}
#endif
		
		//-------------------------------------------------------------------------------------
		// maRpn 逆ポーランド記法を計算する
		//-------------------------------------------------------------------------------------
		// スタック クリア
		[maStack removeAllObjects]; //iStackIdx = 0;
		
		NSString *zNum;  // 一時用
		char cNum1[SBCD_PRECISION+100];
		char cNum2[SBCD_PRECISION+100];
		char cAns[SBCD_PRECISION+100];
		
		for (int index = 0; index < [maRpn count]; index++) 
		{
			NSString *zTokn = [maRpn objectAtIndex:index];
			
			if ([zTokn isEqualToString:@"√"]) {
				if (1 <= [maStack count]) {
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					// 倍精度実数演算で近似値を求める
					double d = [zNum doubleValue];
					if (d < 0) return NSLocalizedString(@"@Complex", nil); // 虚数(複素数)になる
					d = sqrt( d );
					zNum = [NSString stringWithFormat:@"%.9f", d];
					strcpy(cAns, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					for (int i=0; i<10; i++) 
					{
						stringDivision( cNum2, cNum1, cAns );	// N2 = N1 / A
						stringAddition( cAns, cAns, cNum2 );	// A = A + N2
						
						stringDivision( cNum2, cAns, (char *)"2\0" );	// N2 = A / 2
						stringSubtract( cAns, cAns, cNum2 );	// A = A - N2
						
						stringMultiply( cNum2, cAns, cAns );	// N2 = A * A
						stringSubtract( cNum2, cNum1, cNum2 );	// N2 = N1 - N2
						
						zNum = [NSString stringWithCString:(char *)cNum2 encoding:NSASCIIStringEncoding];
						if (fabs([zNum doubleValue]) < 0.0001) break; // OK
					}
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					AzLOG(@"-[√]- zAns=%@", zAns);
					if ([zAns hasPrefix:@"@"]) @throw zAns; // ERROR
					[maStack push:zAns];	// スタックPUSH
				}
			}
			else if ([zTokn isEqualToString:@"*"]) {
				if (2 <= [maStack count]) {
					// N2
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum2=%s", cNum2);
					// N1
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum1=%s", cNum1);
					//----------------------------
					stringMultiply( cAns, cNum1, cNum2 );
					AzLOG(@"BCD> cAns=%s", cAns);
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					AzLOG(@"-[*]- zAns=%@", zAns);
					if ([zAns hasPrefix:@"@"]) @throw zAns; // ERROR
					[maStack push:zAns];	// スタックPUSH
				}
			}
			else if ([zTokn isEqualToString:@"/"]) {
				if (2 <= [maStack count]) {
					// N2
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum2=%s", cNum2);
					// N1
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum1=%s", cNum1);
					//----------------------------
					stringDivision( cAns, cNum1, cNum2 );
					AzLOG(@"BCD> cAns=%s", cAns);
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					AzLOG(@"-[/]- zAns=%@", zAns);
					if ([zAns hasPrefix:@"@"]) {
						if ([zAns hasPrefix:@"@0"]) {
							@throw NSLocalizedString(@"@Divide by zero", nil);
						}
					}
					[maStack push:zAns];	// スタックPUSH
				}
			}
			else if ([zTokn isEqualToString:@"-"]) {
				if (1 <= [maStack count]) {
					// N2
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum2=%s", cNum2);
					// N1
					if (1 <= [maStack count]) {
						zNum = [maStack pop]; // スタックからPOP
						strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
						AzLOG(@"BCD> cNum1=%s", cNum1);
					} else {
						strcpy(cNum1, (char *)"0.0\0"); 
					}
					//----------------------------
					stringSubtract( cAns, cNum1, cNum2 );
					AzLOG(@"BCD> cAns=%s", cAns);
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					AzLOG(@"-[-]- zAns=%@", zAns);
					if ([zAns hasPrefix:@"@"]) @throw zAns; // ERROR
					[maStack push:zAns];	// スタックPUSH
				}
			}
			else if ([zTokn isEqualToString:@"+"]) {
				if (1 <= [maStack count]) {
					// N2
					zNum = [maStack pop]; // スタックからPOP
					strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					AzLOG(@"BCD> cNum2=%s", cNum2);
					// N1
					if (1 <= [maStack count]) {
						zNum = [maStack pop]; // スタックからPOP
						strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
						AzLOG(@"BCD> cNum1=%s", cNum1);
					} else {
						strcpy(cNum1, (char *)"0.0\0"); 
					}
					//----------------------------
					stringAddition( cAns, cNum1, cNum2 );
					AzLOG(@"BCD> stringAddition() cAns=%s", cAns);
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					AzLOG(@"-[+]- zAns=%@", zAns);
					if ([zAns hasPrefix:@"@"]) @throw zAns; // ERROR
					[maStack push:zAns];	// スタックPUSH
				}
			}
			else {
				// 数値
				[maStack push:zTokn];	// 数値をスタックPUSH
			}
		}
		
		// スタックに残った最後が答え
		if ([maStack count] == 1) {
			zNum = [maStack pop]; // スタックからPOP
			AzLOG(@"Ans: zNum = %@", zNum);
			// PRECISION Overflow check
			int iIntLen;
			NSRange rg = [zNum rangeOfString:NUM_DECI];
			if (rg.location != NSNotFound) {
				iIntLen = rg.location;
			} else {
				iIntLen = [zNum length];
			}
			if ([zNum hasPrefix:OP_SUB]) iIntLen--;
			if (PRECISION < iIntLen) {
				@throw NSLocalizedString(@"@Overflow", nil);
			}
			// 丸め処理
			strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
			stringRounding( cAns, cNum1, PRECISION, MiSegDecimal, MiSegRound );
			AzLOG(@"BCD> stringRounding() cAns=%s", cAns);
			zAnswer = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
			[zAnswer retain];
		}
		else {
			@throw @"[maStack count] != 1";
		}
	}
	@catch (NSException * errEx) {
		NSLog(@"Calc:Exception: %@: %@\n", [errEx name], [errEx reason]);
		zAnswer = nil;
	}
	@catch (NSString *msg) {
		NSLog(@"Calc:@throw: %@\n", msg);
		zAnswer = nil;
	}
	@finally {
		[autoPool release];
		//-------------------------------------------------localPool END
		[maRpn release];
		[maStack release];
	}
	return [zAnswer autorelease];
}

- (NSString *)zAnswerDrum	// ドラム ⇒ 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	NSString *zFormula = [self zFormulaFromDrum]; // autorelease
	if (0 < [zFormula length]) {
		return [self zAnswerFromFormula:zFormula]; // autorelease
	}
	return nil;
}


- (NSInteger)iNumLength:(NSString *)zNum
{
	// [-][.] を取り除く
	NSString *z = [zNum stringByReplacingOccurrencesOfString:OP_SUB withString:@""];
	z = [z stringByReplacingOccurrencesOfString:NUM_DECI withString:@""];
	return [z length];
}


@end

