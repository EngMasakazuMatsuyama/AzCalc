//
//  Drum.mm　＜＜＜BCD.cpp関数を利用しているため.mmにする必要がある＞＞＞
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "CalcFunctions.h"
#import "AzCalcAppDelegate.h"
#import "Drum.h"
#import "AzCalcViewController.h"
#import "KeyButton.h"



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
	MfTaxRate = 1.0 + [defaults floatForKey:GUD_TaxRate] / 100.0; // 1 + 消費税率%/100
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
					// UNIT Reset
					AzCalcAppDelegate *app = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
					[app.viewController  GvKeyUnitGroupSI:nil]; // 全UNITリセット
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
					[entryUnit setString:UNI_PERC];
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				else {
					[entryUnit setString:UNI_PERC];
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
				}
				[entryUnit setString:UNI_PERML];
				[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				break;
			case KeyTAG_ROOT: // [√]ルート
				if ([entryOperator hasPrefix:OP_ANS] && 0 < [entryNumber length]) {
					// [=]回答行で[√]を押したとき、改行して式を表示する   entryNumberは「Az数値文字列」である
					NSString *zNum = [NSString stringWithString:entryNumber]; // copy autolease
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// 新セクション
					[entryOperator appendString:OP_ROOT]; // 演算子の末尾へ
					[entryNumber setString:zNum]; // Az数値文字列をセット
					[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				}
				else {
					// 演算子後部に[√]を追加して計算式の一部にする
					if (![entryOperator hasSuffix:OP_ROOT]) {
						[entryOperator appendString:OP_ROOT]; // 演算子の末尾へ
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
					// 演算子が無い
					// 回答する
					[entryOperator setString:OP_ANS];
					[entryNumber setString:[self zAnswerDrum]]; 
					break;
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
			case KeyTAG_AC: { // [AC]
				[formulaOperators removeAllObjects];	[entryOperator setString:OP_START];
				[formulaNumbers removeAllObjects];		[entryNumber setString:@""];
				[formulaUnits removeAllObjects];		[entryUnit setString:@""];
				entryRow = 0;							[entryAnswer setString:@""];
				// UNIT Reset
				AzCalcAppDelegate *app = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
				[app.viewController  GvKeyUnitGroupSI:nil]; // 全UNITリセット
			}	break;
				
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
			}	break;

			case KeyTAG_SC: { // [SC] Section Clear：ドラムでは1行クリア
				if ([entryOperator hasPrefix:OP_START]==NO) { // OP_START ならば消さないこと
					[entryOperator setString:@""];
				}
				[entryNumber setString:@""];
				[entryUnit setString:@""];
				[entryAnswer setString:@""];
			}	break;

			case KeyTAG_AddTAX: // [+Tax] 税込み
			case KeyTAG_SubTAX: // [-Tax] 税抜き
				if ([entryNumber length]<=0) break; // 数値なし無効
				if ([entryOperator hasPrefix:OP_ANS]) {
					// [=]回答行である場合、改行して結果を表示する
					NSString *zNum = [NSString stringWithString:entryNumber]; // copy autolease
					if (![self vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
					// 新セクション
					[entryNumber setString:zNum]; // Az数値文字列をセット
				}
				if (iKeyTag==KeyTAG_AddTAX) {
					[entryUnit setString:UNI_AddTAX];
				} else {
					[entryUnit setString:UNI_SubTAX];
				}
				[self vCalcing:OP_ANS]; // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
				break;
		}
	}
	@finally { //*****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!
		[localPool release];
	}
}


- (void)entryUnitKey:(KeyButton *)keybu  // 単位キー処理
{
	if ([keybu.RzUnit length]<=0) return;
	
	// これ以降、localPool管理エリア
	//NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
	@try {
		[entryUnit setString:keybu.titleLabel.text]; // 単位表示
		[entryUnit appendString:KeyUNIT_DELIMIT];	// ;
		[entryUnit appendString:keybu.RzUnit];		// SI基本単位;への変換式;戻す式
		NSLog(@"entryUnit=%@", entryUnit);
	}
	@finally { //*****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!
		//[localPool release];
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

	NSString *zUnitSI = nil;
	if (0<[entryUnit length]) {
		// UNIT  SI基本単位変換
		NSArray *arUnit = [entryUnit componentsSeparatedByString:KeyUNIT_DELIMIT]; 
		if (1 < [arUnit count]) {
			zUnitSI = [arUnit objectAtIndex:1]; // (0)表示単位　(1)SI基本単位　(2)変換式　(3)逆変換式
			AzCalcAppDelegate *app = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
			[app.viewController  GvKeyUnitGroupSI:zUnitSI];
		}
	}
	
	//AzLOG(@"********************************entryUnit=1=[%@]", entryUnit);
	// 新しい行を追加する
	if (![self vNewLine:zNextOperator]) return; // NO=行数オーバーで追加できなかった。
	
	if ([zNextOperator isEqualToString:OP_ANS]) { 
		// [=]が押されたならば、計算結果表示
		[entryNumber setString:[self zAnswerDrum]]; 
		
		zUnitSI = [self zUnitSiFromDrum];
		if (zUnitSI) {
			[entryUnit setString:zUnitSI]; // UNIT利用中ならばSI基本単位を表示する
		}
	}
	else {
		// ここまでの回答を演算子の前に表示する
		[entryAnswer setString:[self zAnswerDrum]]; 
	}
}


/*
 ドラム ⇒ 数式
 1000 - 20 % ⇒ 1000 - (1000 * 0.20)  　＜＜シャープ電卓方式
 1000 + 20 % ⇒ 1000 + (1000 * 0.20)  　＜＜シャープ電卓方式

*/
- (NSString *)stringFormula	// ドラム ⇒ ibTvFormula数式
{
	// 再計算
	NSString *zFormula = [self zFormulaFromDrum];
	if (0 < [zFormula length]) {
		if (0 < [entryOperator length] && ![entryOperator hasPrefix:OP_ANS] ) {	//[=]を含めないようにする
			zFormula = [NSString stringWithFormat:@"%@%@%@", zFormula, entryOperator, entryNumber];
		} 
		return zFormula;
	}
	else if (0 < [entryOperator length]) {
		if ([entryOperator hasPrefix:OP_START]) { // 開始行
			if (1 < [entryOperator length]) {
				// 開始行の演算子には[>]が入っている。その右に入る可能性があるのは今の所、[√]だけ。
				return [NSString stringWithFormat:@"%@%@", [entryOperator substringFromIndex:1], entryNumber];
			}
		}
		return entryNumber;
	}
	else if (0 < [entryNumber length]) {
		return entryNumber;
	}
	return @"";
}

- (NSString *)zUnitSiFromDrum	// 現在のドラムで使われているUNIT-SI基本単位
{
	// Entry行だけの場合、nil
	if (entryRow <= 0 OR [formulaOperators count] < entryRow) return nil;

	NSString *zUnitSI = nil;
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
		NSString *zUni;
		for (NSInteger idx = iRowStart; idx <= iRowEnd; idx++) 
		{
			zUni = [formulaUnits objectAtIndex:idx];
			if (zUni) {
				// UNIT  SI基本単位変換
				NSArray *arUnit = [zUni componentsSeparatedByString:KeyUNIT_DELIMIT]; 
				if (1 < [arUnit count]) {
					zUnitSI = [arUnit objectAtIndex:1]; // (0)表示単位　(1)SI基本単位　(2)変換式　(3)逆変換式
					break;
				}
			}
		}
	}
	@catch (NSException * errEx) {
		NSLog(@"zFormulaFromDrum:Exception: %@: %@\n", [errEx name], [errEx reason]);
	}
	@catch (NSString *msg) {
		NSLog(@"zFormulaFromDrum:@throw: %@\n", msg);
	}
	return zUnitSI;
}

- (NSString *)zFormulaFromDrum	// ドラム ⇒ 数式
{
	// 現在行より前にある[=][GT]行の次から計算する　＜＜セクション単位に計算する
	if (entryRow <= 0 OR [formulaOperators count] < entryRow) return @"";

	// ドラム情報から計算文字列式を生成する
	NSString *zFormula = @"";
	
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
		
		NSString *zOpe, *zNum, *zUni, *zUnitFormat;
		NSRange rg;
		for (NSInteger idx = iRowStart; idx <= iRowEnd; idx++) 
		{
			zOpe = [formulaOperators objectAtIndex:idx];
			// stringFormatter(小数末尾のZero除去) さらに stringAzNum(区切記号を除去)
			zNum = stringAzNum(stringFormatter([formulaNumbers objectAtIndex:idx], YES));
			zUni = [formulaUnits objectAtIndex:idx];

			// 演算子部
			if ([zOpe hasPrefix:OP_START]) { // 開始行
				// 開始行の演算子には[>]が入っている。その右に入る可能性があるのは今の所、[√]だけ。
				if (1 < [zOpe length]) {
					zOpe = [zOpe substringFromIndex:1]; // OP_STARTより後の文字 [√]
				} else {
					zOpe = @"";
				}
			}
			//AzLOG(@"--zOpe=%@", zOpe);
			
			// 数値部 ＆ 単位部
			AzLOG(@"******************(%d)[%@]*****************", idx, zUni);
			if (zUni==nil || [zUni length]<=0) {
				zFormula = [zFormula stringByAppendingFormat:@"%@%@", zOpe, zNum];
			}
			else if ([zUni isEqualToString:UNI_PERC]) {
				if ([zOpe hasPrefix:OP_ADD]) {
					// ＋％増　＜＜シャープ式： a[+]b[%] = aのb%増し「税込」と同じ＞＞ 100+5% = 100*(1+5/100) = 105
					zFormula = [zFormula stringByAppendingFormat:@"×(1+(%@÷100))", zNum];
				}
				else if ([zOpe hasPrefix:OP_SUB]) {
					// ー％減　＜＜シャープ式： a[-]b[%] = aのb%引き「税抜」と違う！＞＞ 100-5% = 100*(1-5/100) = 95
					zFormula = [zFormula stringByAppendingFormat:@"×(1-(%@÷100))", zNum];
				}
				else {
					zFormula = [zFormula stringByAppendingFormat:@"%@(%@÷100)", zOpe, zNum];	// 1/100
				}
			} 
			else if ([zUni isEqualToString:UNI_PERML]) {
				if ([zOpe hasPrefix:OP_ADD]) {
					// ＋‰増　＜＜シャープ式： a[+]b[‰] = aのb%増し＞＞
					zFormula = [zFormula stringByAppendingFormat:@"×(1+(%@÷1000))", zNum];
				}
				else if ([zOpe hasPrefix:OP_SUB]) {
					// ー‰減　＜＜シャープ式： a[-]b[‰] = aのb%引き＞＞
					zFormula = [zFormula stringByAppendingFormat:@"×(1-(%@÷1000))", zNum];
				}
				else {
					zFormula = [zFormula stringByAppendingFormat:@"%@(%@÷1000)", zOpe, zNum];	// 1/1000 
				}
			} 
			else if ([zUni isEqualToString:UNI_AddTAX]) {
				zFormula = [zFormula stringByAppendingFormat:@"%@×%.3f", zNum, MfTaxRate];
			} 
			else if ([zUni isEqualToString:UNI_SubTAX]) {
				zFormula = [zFormula stringByAppendingFormat:@"%@÷%.3f", zNum, MfTaxRate]; 
			} 
			else {
				// UNIT  SI基本単位変換
				NSArray *arUnit = [zUni componentsSeparatedByString:KeyUNIT_DELIMIT]; 
				if (2 < [arUnit count]) {
					zUnitFormat = [arUnit objectAtIndex:2]; // (0)表示単位 (1)SI基本単位　(2)変換式　(3)逆変換式
					zFormula = [zFormula stringByAppendingString:zOpe];
					zFormula = [zFormula stringByAppendingFormat:zUnitFormat, zNum];
				}
			}
			
			//AzLOG(@"--zFormula=%@", zFormula);
		}
		// 数値と演算子の間のスペースはあってもなくても大丈夫
		// localPoolが解放される前に確保しておく
		[zFormula retain];	// retainCount=1
	}
	@catch (NSException * errEx) {
		NSLog(@"zFormulaFromDrum:Exception: %@: %@\n", [errEx name], [errEx reason]);
		zFormula = @"";  // nilにすると、戻り値を使った setString:で落ちる
	}
	@catch (NSString *msg) {
		NSLog(@"zFormulaFromDrum:@throw: %@\n", msg);
		zFormula = @"";  // nilにすると、戻り値を使った setString:で落ちる
	}
	@finally {
		[autoPool release];
	}
	NSLog(@"zFormulaFromDrum: zFormula=%@", zFormula);
	if ([zFormula retainCount]==1)
		[zFormula autorelease];  // @""ならば不要だから
	return zFormula;
}

- (NSString *)zAnswerDrum	// ドラム ⇒ 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	NSString *zFormula = [self zFormulaFromDrum]; // autorelease
	if (0 < [zFormula length]) {
		return [CalcFunctions zAnswerFromFormula:zFormula]; // autorelease
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

