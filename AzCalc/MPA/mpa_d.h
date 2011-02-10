/*		mpa_d.h		*/
#ifdef		_MPA

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
//#include <time.h>
//#include <values.h>
#include <float.h>

/*
 本ライブラリでサポートする多倍長の桁数は、NMPA、NMPA1、NMPA2、MMPA の定数で決定する。
 NMPA は、仮数部の int 型配列要素数である。 NMPA1、NMPA2、MMPA はコメントで示す計算式に従って定義する。
 （間違った値を指定したときの動作は保証できない。）
 
 int 型 を基本とするため、基数が 32768 であり、従って、１０進表示での有効桁数は、NMPA × log10（32768) となる。
 現ライブラリは、NMPA ＝ 100 としているので、１０進表示での有効桁数は、４５１桁となる。
 
 RADIXBITS 以下の定数は変更してはならない。
 また、unsigned int 及び unsigned long を、タイピング量低減のため、UINT 及び ULONG という型に再定義している。
 */

/*		これらを変更すれば、mak_vh.c にて "mpa_v.h" の自動生成が必要になる。
		NMPA1 = NMPA + 1
		NMPA2 = NMPA1 * 2
		MMPA  = NMPA1 * log10(RADIX) / 4      RADIX = 2 ^ RADIXBITS

		NMPA = 100 --> 451桁有効
		NMPA =  30 --> 135桁有効 ＜＜＜AzCalcで使用＞＞＞
 */
#define		NMPA		100	//30	// 100
#define		NMPA1		101	//31	// 101
#define		NMPA2		202	//62	// 202
#define		MMPA		114	//34	// 114	  // mak_vh.c にて "mpa_v.h" の自動生成のために使われる

#define		RADIXBITS	15
#define		RADIX		0x8000			/* = 2 ^ RADIXBITS */
#define		RADIX1		0x7fff			/* = RADIX - 1 */
#define		RADIX_2		16384			/* = RADIX / 2 */
#define		RADIX2		1073741824L		/* = RADIX ^ 2 */
#define		MAXEXP		16383
#define		MINEXP		-16384
#define		MAX_LONG	0x7FFFFFFFL
#define		MIN_LONG	0x80000000L
#define		MAX_K		180				/* < (sqrt(4 * RADIX + 1) - 1) * 0.5 */

typedef		unsigned int		UINT;
typedef		unsigned long		ULONG;
typedef		struct
			{
				int sign;	// =0(-)  =1(+)
				int exp;
				int zero;
				UINT num[NMPA1];
			}							MPA;

#endif
