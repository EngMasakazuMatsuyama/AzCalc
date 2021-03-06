/*
 *
 *
 * char1バイト1桁ＢＣＤ型　10進演算ライブラリ
 *
 *
 */
#ifndef _SBCD_H_
#define _SBCD_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define SBCD_PRECISION	60		// 有効桁数（必ず偶数値にすること）
								// 60 = ((PRECISION * 2) * 2)  「偶数丸め」するためには小数以下2倍の桁数が必要
								//					* 2) これは、内部計算をアプリ有効桁数(PRECISION)の2倍とするため
								//						 * 2) さらにこれは、「偶数丸め」するため。小数以下2倍の桁数が必要

typedef struct {
	bool minus;			// false=(+) true=(-)
#ifdef DEBUG
	int	prove1;			// デバッグ用プローブ PROVE1_VAL をセットして適時チェックしメモリ破壊されていないか確認する
#endif
	char digit[SBCD_PRECISION+1];	// BCD保持値 (0x00)〜(0x09)
#ifdef DEBUG
	int	prove2;			// デバッグ用プローブ PROVE1_VAL をセットして適時チェックしメモリ破壊されていないか確認する
#endif
} SBCD;

#ifdef DEBUG
#define	PROVE1_VAL	-11
#define	PROVE2_VAL	-33
#endif

/*NG*[1.0.4]
#define	SBCD_GROUP_SEPARATOR				','	// [,]
#define	SBCD_GROUP_SEPARATOR_NS		@","	// NSString@定義

#define	SBCD_DECIMAL_SEPARATOR			'.'	// [.]
#define	SBCD_DECIMAL_SEPARATOR_NS	@"."	// NSString@定義
*/
/* Fix[1.0.4]
	GROUP_SEPARATORを [.] にしたとき、両方ともDECIMAL_SEPARATORになる不具合発覚
	(原因)DECIMAL_SEPARATORの内部記号に[.]を使っていたため
	(対応) 内部記号を下記の通り、表示記号に無い記号にした。
				stringFormatter()にて内部記号を表示記号に置換している。
*/
#define	SBCD_GROUP_SEPARATOR				';'	// [;]セミコロン	（表示に無い記号にすること）
#define	SBCD_GROUP_SEPARATOR_NS		@";"	// NSString@定義

#define	SBCD_DECIMAL_SEPARATOR			':'	// [:]コロン（表示に無い記号にすること）
#define	SBCD_DECIMAL_SEPARATOR_NS	@":"	// NSString@定義


//----------------------------------------------- *strAnswer[SBCD_PRECISION+1 以上] 確保して渡すこと。
// strAnswer に答えが書き込まれます。 よって、strAnswer を次の strNum1やstrNum2 に使うことができます。
// strNum1,strNum1 は、Read Only (変更されません）
// 四則演算
void stringAddition( char *strAnswer, char *strNum1, char *strNum2 );
void stringSubtract( char *strAnswer, char *strNum1, char *strNum2 );
void stringMultiply( char *strAnswer, char *strNum1, char *strNum2 );
void stringDivision( char *strAnswer, char *strNum1, char *strNum2 );

// 丸め  iPrecision	= 有効桁数（整数部と小数部を合わせた最大桁数。符号や小数点は含まない）
//		iDecimal	= 小数桁数（小数部の最大桁数）[ 0 〜 iPrecision ]
//xx		iType		= 丸め方法 (0)RM (1)RZ:切捨 (2)5/4 (3)5/5 (4)6/5 (5)RI:切上 (6)RP		[1.0.5]以前
//		iType		= 丸め方法 (0)RM (1)RZ:切捨 (2)6/5 (3)5/5 (4)5/4 (5)RI:切上 (6)RP		[1.0.6]以降
void stringRounding( char *strAnswer, char *strNum, int iPrecision, int iDecimal, int iType );


void formatterGroupingSeparator( NSString *zGroupSeparator );	// Default:@","
void formatterGroupingType( int iGroupType );					// Default:0
void formatterDecimalSeparator( NSString *zDecimalSeparator );	// Default:@"."
//void formatterDecimalZeroCut( bool bZeroCut );
NSString *stringFormatter( NSString *strAzNum, BOOL bZeroCut );
NSString *stringAzNum( NSString *zNum );

NSString *getFormatterDecimalSeparator( void );

#endif





