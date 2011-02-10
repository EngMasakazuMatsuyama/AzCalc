//
//  Drum.mm　＜＜＜BCD.cpp関数を利用しているため.mmにする必要がある＞＞＞
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#import "Drum.h"
#include "SBCD.h"  // BCD固定小数点演算 ＜＜この.cpp関数を利用するファイルの拡張子は .m ⇒ .mm にすること＞＞



@interface Drum (PrivateMethods)
- (BOOL)vNewLine:(NSString *)zNextOperator;	// entryをarrayに追加し、entryを新規作成する
- (void)vEnterOperator:(NSString *)zOperator;
- (void)vCalcing:(NSString *)zNextOperator;
- (NSString *)zformulaToRpnCalc;
- (NSInteger)iNumLength:(NSString *)zNum;
@end

@implementation Drum

@synthesize formulaOperators, formulaNumbers;
@synthesize entryOperator, entryNumber, entryRow;
@synthesize dMemory;


- (void)dealloc 
{
	[entryNumber release];
	[entryOperator release];
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
		
		entryOperator = [[NSMutableString alloc] initWithString:OP_START];
		entryNumber = [NSMutableString new];
		
		entryRow = 0;
		dMemory = 0.0;
		
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
	MiSegRound = (NSInteger)[defaults integerForKey:GUD_Round];
	MiSegReverseDrum = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];

	if (DECIMAL_Float <= MiSegDecimal) MiSegDecimal = PRECISION; // [F]小数桁制限なし
}


- (NSInteger)count
{
	return [formulaOperators count];
}


- (void)entryKeyTag:(NSInteger)iKeyTag option:(NSString *)zOption  // キー入力処理
{
	AzLOG(@"entryKeyTag: (%d) %@", iKeyTag, zOption);
	
	// これ以降、localPool管理エリア
	NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
	// 以後、return;使用禁止！すると@finallyを通らず、localPoolが解放されない。
	
	@try {
		switch (iKeyTag) {
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
				
			case 16: // [.]小数点
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
				
			case 17: // [00]
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
				
			case 18: // [000]
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
				
			case 20: // [=] ============================================================================
				if ([entryOperator isEqualToString:OP_ANS]) { // 前行も[=]であるとき
					// [=]が繰り返された場合、直前と同じ計算を繰り返す ＜＜シャープモード＞＞
					if ([[formulaOperators lastObject] isEqualToString:OP_START]) { // 前行が[>]であるとき
						break;  // 直前が開始行なので無効   ＜＜return;ダメ！すると@finallyを通らない＞＞
					}
					// 直前の式をEntryにセット
					[entryOperator setString:[formulaOperators lastObject]];
					if ([entryOperator length] <= 0) {
						[entryOperator setString:OP_ADD]; // 直前の演算子が無いとき(最上行)、"+"にする
					}
					[entryNumber setString:[formulaNumbers lastObject]];
				}
				else if ([entryOperator isEqualToString:OP_START]) { // 前行が[>]であるとき
					break;  // 無効   ＜＜return;ダメ！すると@finallyを通らない＞＞
				}
				else if (![entryOperator isEqualToString:@""] 
						 && [entryNumber length]<=0) { // 上以外の演算子が入っており、数値未定 のとき
					[entryOperator setString:OP_ANS];
					// entry行に、この[=]が入るので、数値部に計算結果を入れる
					[entryNumber setString:[self zformulaToRpnCalc]]; 
					break;
				}
				// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				[self vCalcing:OP_ANS];
				break;
				
			case 21: // [+]
				[self vEnterOperator:OP_ADD]; break;
			case 22: // [-]
				[self vEnterOperator:OP_SUB]; break;
			case 23: // [×]
				[self vEnterOperator:OP_MULT]; break;
			case 24: // [÷]
				[self vEnterOperator:OP_DIVI]; break;
				
			case 100: // [AC]
				[formulaOperators removeAllObjects];	[entryOperator setString:OP_START];
				[formulaNumbers removeAllObjects];	[entryNumber setString:@""];
				entryRow = 0;
				break;
				
			case 101: { // [BS]
				int iLen = [entryNumber length];
				if (0 < iLen) {
					[entryNumber deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; // 末尾より1字削除
				}
				else if (![entryOperator isEqualToString:OP_START]) {
					// 開始行でなければ、演算子までクリア
					[entryOperator setString:@""];
				}
			} break;
				
			case 102: // [+/-]
				if ([entryNumber doubleValue] < 0) {
					// 先頭の"-"を削除する
					[entryNumber deleteCharactersInRange:NSMakeRange(0,1)];
				} 
				else if (0 < [entryNumber doubleValue]) {
					// 先頭に"-"を挿入する
					[entryNumber insertString:OP_SUB atIndex:0];
				}
				break;
				
			case 103: { // [MRC]
				AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
				if (appDelegate.dMemory == [entryNumber doubleValue]) {
					appDelegate.dMemory = 0.0; // Clear
				} 
				else if (appDelegate.dMemory != 0.0) {
					if ([entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
						if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					}
					[entryNumber setString:[NSString stringWithFormat:FLOAT_FORMAT, appDelegate.dMemory]];
					// 末尾の0を取り除く
					while ([entryNumber hasSuffix:NUM_0]) { // 末尾が[0]ならば
						int iLen = [entryNumber length];
						if (iLen <= 0) break;
						[entryNumber deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; // 末尾より1字削除
					}
					if ([entryNumber hasSuffix:NUM_DECI]) { // さらに末尾が[.]小数点ならば
						int iLen = [entryNumber length];
						if (0<iLen) [entryNumber deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; // 末尾より1字削除
					}
					AzLOG(@"DEBUG: [MRC] entryNumber=[%@]",entryNumber);
					if ([entryOperator isEqualToString:OP_ANS]) {
						[entryOperator setString:@""];
					}
				}
			} break;
				
			case 104: // [M-]
			case 105: // [M+]
				AzLOG(@"entryOperator=[%@]", entryOperator);
				if ([entryOperator isEqualToString:OP_ANS] && [entryNumber doubleValue]!=0.0) {
					// OK : entryNumber ⇒ dMemoru
				} else if ([entryOperator isEqualToString:@""] OR [entryOperator isEqualToString:OP_START]) {
						// [][>]であれば、OK : entryNumber ⇒ dMemoru
				} else {
					if (![entryOperator isEqualToString:OP_ANS] && [entryNumber doubleValue]!=0.0) {
						// 演算中　entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
						[self vCalcing:OP_ANS];
					} else {
						// 計算処理する
						[entryOperator setString:OP_ANS];
						// entry行に、この[=]が入るので、数値部に計算結果を入れる
						[entryNumber setString:[self zformulaToRpnCalc]]; 
					}
				}
				// 0でなければそれを Ｍ−＋ する
				if ([entryNumber doubleValue] != 0.0) {
					AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
					if (iKeyTag==104) {
						appDelegate.dMemory -= [entryNumber doubleValue]; // [M-]
					} else {
						appDelegate.dMemory += [entryNumber doubleValue]; // [M+]
					}
				}
				break;
				
			default:
				break;
		}
	}
/*	@catch (NSException *exception) {
		NSString *name = [exception name];
		NSLog(@"Exception name: %@", name);
		NSLog(@"Exception reason: %@", [exception reason]);
		if ([name isEqualToString:NSRangeException]) {
			NSLog(@"Exception was caught successfully.");
		} else {
			[exception raise];
		}
	}*/
	@finally {
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
			[entryNumber setString:[self zformulaToRpnCalc]]; 
			return NO; // 最終行オーバーにつき拒否
		}
		// 最終行
	}

	// Operator: entryをarrayに追加し、entryを新規作成する
	[formulaOperators addObject:entryOperator];
	[entryOperator release];
	entryOperator = [[NSMutableString alloc] initWithString:zNextOperator];
	entryRow = [formulaOperators count];
	
	// Number: entryをarrayに追加し、entryを新規作成する
	[formulaNumbers addObject:entryNumber];
	[entryNumber release];
	entryNumber = [NSMutableString new];
	
	return YES;
}


//============================================================================================
// zOperator により改行が発生するときの処理
//============================================================================================
- (void)vEnterOperator:(NSString *)zOperator
{
	if ([entryNumber length] <= 0 OR [entryOperator isEqualToString:OP_ANS]) {
		// 数値未定 または [=]表示されているとき
		[entryNumber setString:@""]; // [= Num]表示を消すため
		
		if ([entryOperator isEqualToString:OP_START]) {
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
		}
		else {
			[entryOperator setString:zOperator];
		}
		return;
	}
	
	if ([entryOperator length] <= 0) {
		// 演算子未定
		[entryOperator setString:zOperator];
		return;
	}
	
	assert(0<[entryOperator length] && 0<[entryNumber length]);
	// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
	[self vCalcing:zOperator];
}


//============================================================================================
// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
//============================================================================================
- (void)vCalcing:(NSString *)zNextOperator
{
	BOOL bStart = [entryOperator isEqualToString:OP_START]; // YES=計算セクション開始行
	
	if ([entryNumber length]<=0) {
		// 数値未定
		if (!bStart) { // 開始行でない！ならば、演算子だけ変更して計算しない
			[entryOperator setString:zNextOperator];
		}
		return;
	}

/*	// Operator: entryをarrayに追加し、entryを新規作成する
	[formulaOperators addObject:entryOperator];
	[entryOperator release];
	entryOperator = [[NSMutableString alloc] initWithString:zNextOperator];
	entryRow = [formulaOperators count];
	
	// Number: entryをarrayに追加し、entryを新規作成する
	[formulaNumbers addObject:entryNumber];
	[entryNumber release];
	entryNumber = [NSMutableString new];
 */
	// 新しい行を追加する
	if (![self vNewLine:zNextOperator]) return;
	
	if (!bStart && [zNextOperator isEqualToString:OP_ANS]) { 
		// 開始行でなく [=]が押されたならば、計算結果表示
		[entryNumber setString:[self zformulaToRpnCalc]]; 
	}
}


/*
 計算式		⇒　逆ポーランド記法
 "5 + 4 - 3"	⇒ "5 4 3 - +"
 "5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
 "(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 "T ( 5 + 2 )" ⇒ "5 2 + T"
 */
- (NSString *)zformulaToRpnCalc	// 計算式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	// NSAutoreleasePool管理は呼び出し側（親）で処理すること。
	
	NSString *zAnswer = nil; //[[NSString new] autorelease]; // 戻り値になる
	
	// 現在行より前にある[=]行の次から計算する　＜＜セクション単位に計算する
	if (entryRow <= 0 OR [formulaOperators count] < entryRow) return @"";
	
	NSInteger iRowStart = 0; // 最初から
	if (2 <= entryRow) {
		if ([formulaOperators count] <= entryRow) {
			iRowStart = [formulaOperators count] - 1;
		} else {
			iRowStart = entryRow;
		}
		for ( ; 0 < iRowStart; iRowStart--) {
			if ([[formulaOperators objectAtIndex:iRowStart] isEqualToString:OP_ANS]) { // 直前の[=]の次にする
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
	AzLOG(@"zformulaToRpnCalc: Drum Row[ %d >>> %d ]", iRowStart, iRowEnd);
	assert(iRowStart <= iRowEnd);
	
	NSString *zTemp = nil; //[[NSString new] autorelease];  // 途中 return;で抜けているため。
	if ([[formulaOperators objectAtIndex:iRowStart] isEqualToString:OP_SUB]) {
		//zTemp = [zTemp stringByAppendingFormat:@"%@%@ ", OP_SUB, [formulaNumbers objectAtIndex:iRowStart]];
		zTemp = [NSString stringWithFormat:@"%@%@ ", OP_SUB, [formulaNumbers objectAtIndex:iRowStart]];
	} else {
		//zTemp = [zTemp stringByAppendingFormat:@"%@ ", [formulaNumbers objectAtIndex:iRowStart]];
		zTemp = [NSString stringWithFormat:@"%@ ", [formulaNumbers objectAtIndex:iRowStart]];
	}
	
	for (NSInteger i = iRowStart+1; i <= iRowEnd; i++) {
		zTemp = [zTemp stringByAppendingFormat:@"%@ %@ ", [formulaOperators objectAtIndex:i], 
				 [formulaNumbers objectAtIndex:i]];
	}
	
	zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_MULT withString:@" * "]; // 半角文字化
	zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_DIVI withString:@" / "]; // 半角文字化
	
	
	// スペースで区切られたコンポーネント(部分文字列)を切り出す
	NSArray *arComp = [zTemp componentsSeparatedByString:@" "];
	
	NSInteger iCapLeft = 0;
	NSInteger iCapRight = 0;
	NSInteger iCntOperator = 0;	// 演算子の数　（関数は除外）
	NSInteger iCntNumber = 0;	// 数値の数
	//NSInteger iDecimalPlace = 0;  // 小数点位置
	
	NSMutableArray *maStack = [[NSMutableArray new] autorelease];  // 途中 return;で抜けているため。
	NSInteger iStackIdx = 0;
	// 逆ポーランド記法結果
	NSMutableArray *maRpn = [[NSMutableArray new] autorelease];  // 途中 return;で抜けているため。
	
	for (int index = 0; index < [arComp count]; index++) 
	{
		NSString *zTokn = [arComp objectAtIndex:index];
		AzLOG(@"arComp[%d]='%@'", index, zTokn);
		
		if ([zTokn isEqualToString:@""] OR [zTokn isEqualToString:@" "]) {
			// スペースならばパス
		}
		else if ([zTokn isEqualToString:@"T"] 
				 OR [zTokn isEqualToString:@"N"] 
				 OR [zTokn isEqualToString:@"R"] 
				 OR [zTokn isEqualToString:@"√"]) {
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
		else if ([zTokn isEqualToString:@"*"] OR [zTokn isEqualToString:@"/"]) {
			iCntOperator++;
			if (MiSegCalcMethod == 0) {
				// (0)加算式
				if (0 < iStackIdx) {
					NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタック最上位のトークン
					[maRpn addObject:zz]; // 逆ポーランドへPUSH
					[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				}
			}
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
		else if ([zTokn isEqualToString:@"+"] OR [zTokn isEqualToString:OP_SUB]) {
			iCntOperator++;
			if (MiSegCalcMethod == 0) {
				// (0)加算式
				if (0 < iStackIdx) {
					NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタック最上位のトークン
					[maRpn addObject:zz]; // 逆ポーランドへPUSH
					[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				}
			} else {
				// (1)公式：+- より ×÷ を優先する
				while (0 < iStackIdx) {
					NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタック最上位のトークン
					if ([zz isEqualToString:@"*"] OR [zz isEqualToString:@"/"]) {
						[maRpn addObject:zz]; // 逆ポーランドへPUSH
						[maStack removeLastObject]; iStackIdx--; // スタックからPOP
					} else {
						break;
					}
				}
			}
			[maStack addObject:zTokn];  iStackIdx++; // スタックへPUSH
		}
		else if ([zTokn isEqualToString:@"("]) {
			iCapLeft++;
			[maStack addObject:zTokn];  iStackIdx++; // スタックへPUSH
		}
		else if ([zTokn isEqualToString:@")"]) {
			iCapRight++;
			while (0 < iStackIdx) {
				NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタックからPOP
				[maStack removeLastObject]; iStackIdx--; // スタックPOP
				if ([zz isEqualToString:@"("]) break; // 両カッコは、maRpnには不要
				[maRpn addObject:zz]; // 逆ポーランドPUSH
			}
		}
		else { // 数字である
			iCntNumber++;
			[maRpn addObject:zTokn]; // 逆ポーランドPUSH
		}
	}
	
	// 数値と演算子の数チェック
	if (iCntNumber < iCntOperator + 1) {
		zAnswer = NSLocalizedString(@"Too many operators", nil); // 演算子が多すぎる
	} else if (iCntNumber > iCntOperator + 1) {
		zAnswer = NSLocalizedString(@"Insufficient operator", nil); // 演算子が足らない
	}
	// 括弧チェック
	if (iCapLeft < iCapRight) {
		zAnswer = NSLocalizedString(@"Closing parenthesis is excessive", nil); // 括弧が閉じ過ぎ
	} else if (iCapLeft > iCapRight) {
		zAnswer = NSLocalizedString(@"Unclosed parenthesis", nil); // 括弧が閉じていない
	}
	if (0 < [zAnswer length]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to compute", nil)
														message:zAnswer
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return @""; // ERROR
	}
	
	// スタックに残っているトークンを全て逆ポーランドPUSH
	while (0 < iStackIdx) {
		NSString *zz = [maStack objectAtIndex:--iStackIdx]; // スタックからPOP  この後、PUSHすること無いので削除処理をしていない
		[maRpn addObject:zz]; // 逆ポーランドへPUSH
	}
#ifdef AzDEBUG
	for (int index = 0; index < [maRpn count]; index++) 
	{
		AzLOG(@"maRpn[%d]='%@'", index, [maRpn objectAtIndex:index]);
	}
#endif
	
	// スタック クリア
	[maStack removeAllObjects]; iStackIdx = 0;

	//-------------------------------------------------------------------------------------
	//-------------------------------------------------------------------------------------
	// maRpn 逆ポーランド記法を計算する
	NSString *zNum;  // 一時用
	double	d1; //, d2;  // double型の最大有効桁数16
	//MPA mp1, mp2, mpAns;
	//char cAns[512];
	char cNum1[SBCD_PRECISION+100];
	char cNum2[SBCD_PRECISION+100];
	char cAns[SBCD_PRECISION+100];
	
	for (int index = 0; index < [maRpn count]; index++) 
	{
		NSString *zTokn = [maRpn objectAtIndex:index];
		
		if ([zTokn isEqualToString:@"R"]) {
			if (1 <= iStackIdx) {
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				//[maStack addObject:[NSString stringWithFormat:FLOAT_FORMAT, round(d1)]];  iStackIdx++; // スタックPUSH
				[maStack addObject:[NSNumber numberWithDouble:round(d1)]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"√"]) {
			if (1 <= iStackIdx) {
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				//[maStack addObject:[NSString stringWithFormat:FLOAT_FORMAT, sqrt(d1)]];  iStackIdx++; // スタックPUSH
				[maStack addObject:[NSNumber numberWithDouble:sqrt(d1)]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"*"]) {
			if (2 <= iStackIdx) {
				// N2
				zNum = [maStack objectAtIndex:iStackIdx-1];
				strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum2=%s", cNum2);
				// N1
				zNum = [maStack objectAtIndex:iStackIdx-1];
				strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum1=%s", cNum1);
				//----------------------------
				stringMultiply( cAns, cNum1, cNum2 );
				AzLOG(@"BCD> cAns=%s", cAns);
				NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
				AzLOG(@"-[*]- zAns=%@", zAns);
				if ([zAns hasPrefix:@"@"]) return zAns; // ERROR
				[maStack addObject:zAns];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"/"]) {
			if (2 <= iStackIdx) {
				// N2
				zNum = [maStack objectAtIndex:iStackIdx-1];
				strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum2=%s", cNum2);
				// N1
				zNum = [maStack objectAtIndex:iStackIdx-1];
				strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum1=%s", cNum1);
				//----------------------------
				stringDivision( cAns, cNum1, cNum2 );
				AzLOG(@"BCD> cAns=%s", cAns);
				NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
				AzLOG(@"-[/]- zAns=%@", zAns);
				if ([zAns hasPrefix:@"@"]) {
					if ([zAns hasPrefix:@"@0"]) return NSLocalizedString(@"@Divide by zero", nil);
					return zAns; // ERROR
				}
				[maStack addObject:zAns];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"-"]) {
			if (1 <= iStackIdx) {
				// N2
				zNum = [maStack objectAtIndex:iStackIdx-1];
				strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum2=%s", cNum2);
				// N1
				if (1 <= iStackIdx) {
					zNum = [maStack objectAtIndex:iStackIdx-1];
					strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					[maStack removeLastObject]; iStackIdx--; // スタックからPOP
					AzLOG(@"BCD> cNum1=%s", cNum1);
				} else {
					strcpy(cNum1, "0.0"); 
				}
				//----------------------------
				stringSubtract( cAns, cNum1, cNum2 );
				AzLOG(@"BCD> cAns=%s", cAns);
				NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
				AzLOG(@"-[-]- zAns=%@", zAns);
				if ([zAns hasPrefix:@"@"]) return zAns; // ERROR
				[maStack addObject:zAns];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"+"]) {
			if (1 <= iStackIdx) {
				// N2
				zNum = [maStack objectAtIndex:iStackIdx-1];
				//strcpy(cNum2, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				sprintf(cNum2, "%s", (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
				[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				AzLOG(@"BCD> cNum2=%s", cNum2);
				// N1
				if (1 <= iStackIdx) {
					zNum = [maStack objectAtIndex:iStackIdx-1];
					//strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					sprintf(cNum1, "%s", (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
					[maStack removeLastObject]; iStackIdx--; // スタックからPOP
					AzLOG(@"BCD> cNum1=%s", cNum1);
				} else {
					//zNum = @"0.0";
					strcpy(cNum1, (char *)"0.0"); 
				}
				//----------------------------
				stringAddition( cAns, cNum1, cNum2 );
				AzLOG(@"BCD> stringAddition() cAns=%s", cAns);
				NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
				AzLOG(@"-[+]- zAns=%@", zAns);
				if ([zAns hasPrefix:@"@"]) return zAns; // ERROR
				[maStack addObject:zAns];  iStackIdx++; // スタックPUSH
			}
		}
		else {
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
	}
	
	// スタックに残った最後が答え
	if (iStackIdx == 1) {
		zNum = [maStack objectAtIndex:iStackIdx-1];
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
			return NSLocalizedString(@"@Overflow", nil);
		}
		// 丸め処理
		strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
		stringRounding( cAns, cNum1, PRECISION, MiSegDecimal, MiSegRound );
		AzLOG(@"BCD> stringRounding() cAns=%s", cAns);
		zAnswer = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
	}
	else {
		AzLOG(@"zformulaToRpnCalc:ERROR: iStackIdx != 1");
		zAnswer = NSLocalizedString(@"It is difficult", nil);
	}
	return zAnswer;
}

- (NSInteger)iNumLength:(NSString *)zNum
{
	// [-][.] を取り除く
	NSString *z = [zNum stringByReplacingOccurrencesOfString:OP_SUB withString:@""];
	z = [z stringByReplacingOccurrencesOfString:NUM_DECI withString:@""];
	return [z length];
}

@end

