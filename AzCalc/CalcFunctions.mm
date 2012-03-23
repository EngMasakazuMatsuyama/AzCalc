//
//  CalcFunctions.m
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "CalcFunctions.h"


#pragma mark - Stack method

//[0.3]-----------------------------------------------------NSMutableArray Stack Method
@interface NSMutableArray (StackAdditions)
- (void)push:(id)obj;
- (id)pop;
@end

@implementation NSMutableArray (StackAdditions)
- (void)push:(id)obj
{
	@synchronized(self){
		[self addObject:obj];
	}
}

- (id)pop
{
	@synchronized(self){
		//id lastObject = [[[self lastObject] retain] autorelease];
		id lastObject = [self lastObject];
		if (lastObject) {
			//[[lastObject retain] autorelease];
			[self removeLastObject];
		}
		return lastObject;	// nil if [self count] == 0
	}
}
@end
//----------------------------------------------------------NSMutableArray Stack Method



static NSInteger  MiSegCalcMethod;
static NSInteger  MiSegDecimal;
static NSInteger  MiSegRound;


#pragma mark -
@implementation CalcFunctions

int levelOperator( NSString *zOpe )  // 演算子の優先順位
{
	if ([zOpe isEqualToString:@"*"] || [zOpe isEqualToString:@"/"]) { // この優先付けでは、有理化はできない。
		return 1;
	}
	else if ([zOpe isEqualToString:@"+"] || [zOpe isEqualToString:@"-"]) {
		if (MiSegCalcMethod==0) return 1; // 電卓方式につき四則同順
		return 2;
	}
	return 3; // "(" ")" その他の演算子
}

+ (void)setCalcMethod:(NSInteger)i {
	MiSegCalcMethod = i;	// (0)Calculator  (1)Formula
}

+ (void)setDecimal:(NSInteger)i {
	MiSegDecimal = i;
}

+ (void)setRound:(NSInteger)i {
	MiSegRound = i;
}

+ (NSString *)zFormulaFilter:(NSString *)zForm      // 数式許可文字だけにするフィルタ
{
	const NSString *zList = @"0123456789. +-×÷*/()";  // 数式入力許可文字
    NSString *z, *zOuts = @"";
    NSRange rg;
    for (NSInteger i=0; i<[zForm length]; i++)
    {
        z = [zForm substringWithRange:NSMakeRange(i, 1)];
        rg = [zList rangeOfString:z];
        if (rg.length==1) {
            // 許可文字
            zOuts = [zOuts stringByAppendingString:z];
        }
    }
    return zOuts;
}

/*
 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation)
 "5 + 4 - 3"	⇒ "5 4 3 - +"
 "5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
 "(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 "T ( 5 + 2 )" ⇒ "5 2 + T"
 
 "1000 + 5%" ⇒ "1000 * (100 + 5) / 100"	＜＜1000の5%増：税込み＞＞　シャープ式
 "1000 - 5%" ⇒ "1000 * 100 / (100 + 5)"	＜＜1000の5%減：税抜き＞＞　シャープ式
 
 "1000 * √2" ⇒ "1000 * (√2)" ⇒ "1000 1.4142 *"		＜＜ルート対応
 */
+ (NSString *)zAnswerFromFormula:(NSString *)zFormula	// 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	AzLOG(@"zAnswerFromFormula: zFormula=%@", zFormula);
	if ([zFormula length]<=0) {
		return @""; // nilにすると、戻り値を使った setString:で落ちる
	}
	if ([zFormula length]<=2) { // 式を構成できない
		return zFormula;
	}
	if (FORMULA_MAX_LENGTH < [zFormula length]) {
		return  @"@Game Over =";  // 先頭を@にすると stringFormatter() で変換されずに@以降が返されてドラムに表示される
	}
	
	NSMutableArray *maStack = [[NSMutableArray alloc] init];	// - Stack Method
	NSMutableArray *maRpn = [[NSMutableArray alloc] init]; // 逆ポーランド記法結果
	NSString *zAnswer = @"";  // nilにすると、戻り値を使った setString:で落ちる
	
	//-------------------------------------------------localPool BEGIN >>> @finaly release
	//NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
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
		
		// プラス「符号」⇒ ""
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×+" withString:@"×"];  
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷+" withString:@"÷"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-+" withString:@"-"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(+" withString:@"("];

		// 演算子の両側にスペース挿入
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"*"	withString:@" * "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"/"	withString:@" / "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_MULT withString:@" * "]; // "×"半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_DIVI withString:@" / "]; // "÷"半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:OP_ROOT withString:@" √ "]; // 前後スペース挿入
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
				[maStack push:zTokn]; // スタックPUSH
			}
			else if ([zTokn isEqualToString:@")"]) {
				iCapRight++;
				while ((zz = [maStack pop])) {	// "("までスタックから取り出してRPNへ追加、両括弧は破棄する
					if ([zz isEqualToString:@"("]) {
						break; // 両カッコは、破棄する
					}
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
					NSLog(@"+++++[maStack lastObject]=(%@) <= (%@)", [maStack lastObject], zTokn);
					if (levelOperator([maStack lastObject]) <= levelOperator(zTokn)) {
						NSLog(@"+++++ YES");
						zz = [maStack pop];
						[maRpn push:zz];  // スタックから取り出して、それをRPNへ追加
					} else {
						NSLog(@"+++++ NO");
						break;
					}
				}
				// スタックが空ならばトークンをスタックへ追加する
				iCntOperator++;
				[maStack push:zTokn];
			}
		}
		// スタックに残っているトークンを全て逆ポーランドPUSH
		while ((zz = [maStack pop])) {
			[maRpn push:zz];
		}
		// 数値と演算子の数チェック
		if (iCntNumber < iCntOperator + 1) {	// 先頭の @ が無ければ、桁区切り処理されてしまう。
			@throw NSLocalizedString(@"@Excess Operator",nil);		// @演算子過多
		}
		else if (iCntNumber > iCntOperator + 1) {
			@throw NSLocalizedString(@"@Lack Operator",nil); // @演算子不足
		}
		// 括弧チェック
		if (iCapLeft < iCapRight) {
			@throw NSLocalizedString(@"@Excess Closing",nil); // @閉じ過ぎ
		}
		else if (iCapLeft > iCapRight) {
			@throw NSLocalizedString(@"@Unclosed",nil);		// @閉じていない
		}
		
		NSLog(@"***maRpn=%@\n", maRpn);
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
					if (d < 0) return @"@Complex"; // 虚数(複素数)になる
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
							@throw NSLocalizedString(@"@Divide by zero",nil);
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
				//@throw @"@Overflow";  // 先頭を@にすると stringFormatter() で変換されずに@以降が返されてドラムに表示される
				@throw NSLocalizedString(@"@Overflow",nil);
			}
			// 丸め処理
			strcpy(cNum1, (char *)[zNum cStringUsingEncoding:NSASCIIStringEncoding]); 
			stringRounding( cAns, cNum1, PRECISION, MiSegDecimal, MiSegRound );
			AzLOG(@"BCD> stringRounding() cAns=%s", cAns);
			zAnswer = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
			//[zAnswer retain]; // retainCount=1
		}
		else {
			@throw @"@ERROR1";  //@"[maStack count] != 1";
		}
	}
	@catch (NSException * errEx) {
		NSLog(@"Calc:Exception: %@: %@\n", [errEx name], [errEx reason]);
		zAnswer = @"";  // nilにすると、戻り値を使った setString:で落ちる
	}
	@catch (NSString *msg) {
		NSLog(@"Calc:@throw: %@\n", msg);
		zAnswer = msg; //@"";  // nilにすると、戻り値を使った setString:で落ちる
	}
	@finally {
		//[autoPool release];
		//-------------------------------------------------localPool END
		maRpn = nil;
		maStack = nil;
	}
	//if ([zAnswer retainCount]==1) 
	//	[zAnswer autorelease];  // @""ならば不要だから
	return zAnswer;
}



@end
