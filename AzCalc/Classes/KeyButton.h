//
//  KeyButton.h
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


#define KeyUNIT_DELIMIT			@";"	// "SI基本単位;変換式;逆変換式"

//---------------------------------------------------------Tag
//----------AzKeyMaster.plist の Tag 定義と一致させること。
#define KeyTAG_STANDARD_Start	  0
#define KeyTAG_DECIMAL			 16	// [.]小数点
#define KeyTAG_00				 17	// [00]
#define KeyTAG_000				 18	// [000]
#define KeyTAG_SIGN				 20	// [+/-]
#define KeyTAG_PERC				 30	// [%]
#define KeyTAG_PERM				 31	// [‰]パーミル
#define KeyTAG_ROOT				 32	// [√]
#define KeyTAG_LEFT				 33 // [(]
#define KeyTAG_RIGHT			 34 // [)]


#define KeyTAG_ANSWER			100	// [=]回答
#define KeyTAG_PLUS				101	// [+]
#define KeyTAG_MINUS			102	// [-]
#define KeyTAG_MULTI			103	// [×]
#define KeyTAG_DIVID			104	// [÷]
#define KeyTAG_GT				105	// [GT] Ground Total

#define KeyTAG_AC				200	// [AC] All Clear
#define KeyTAG_BS				201	// [BS] Back Clear
#define KeyTAG_SC				202	// [SC] Section Clear
#define KeyTAG_AddTAX			210	// [+Tax]
#define KeyTAG_SubTAX			211	// [-Tax]
#define KeyTAG_STANDARD_End		299

#define KeyTAG_MEMORY_Start		300
#define KeyTAG_MCLEAR			300	// [MClear]
#define KeyTAG_MCOPY			301	// [Memory]
#define KeyTAG_MPASTE			302	// [Paste] ibBuMemory
#define KeyTAG_M_PLUS			311	// [M+]
#define KeyTAG_M_MINUS			312	// [M-]
#define KeyTAG_M_MULTI			313	// [M×]
#define KeyTAG_M_DIVID			314	// [M÷]
#define KeyTAG_MEMORY_End		399

#define KeyTAG_MSTORE_Start		400
#define KeyTAG_MSTROE_End		499

#define KeyTAG_UNIT_Start		1000 //-----------------SI基本単位換算
#define KeyTAG_UNIT_m			1000 // [m]				1m
#define KeyTAG_UNIT_cm			1001 // [cm]			0.01m
#define KeyTAG_UNIT_mm			1002 // [mm]			0.001m
#define KeyTAG_UNIT_km			1003 // [km]			1000m
#define KeyTAG_UNIT_Adm			1010 // [Adm]	海里		1852m
#define KeyTAG_UNIT_yard		1011 // [yd]	ヤード	0.9144m
#define KeyTAG_UNIT_foot		1012 // [ft]	フィート	0.3048m
#define KeyTAG_UNIT_inch		1013 // [in]	インチ	0.254m
#define KeyTAG_UNIT_mile		1014 // [mi]	マイル	1609.344m
#define KeyTAG_UNIT_SHAKU		1015 // [尺]		曲尺		0.303m
#define KeyTAG_UNIT_SUNN		1016 // [寸]		曲寸		0.0303m
#define KeyTAG_UNIT_RI			1017 // [里]		里		3927m

#define KeyTAG_UNIT_kg			1100 // [kg]			1kg
#define KeyTAG_UNIT_g			1101 // [g]				0.001kg = 1000mg
#define KeyTAG_UNIT_mg			1102 // [mg]			0.00001kg = 0.001g
#define KeyTAG_UNIT_t			1103 // [t]		トン		1000kg
#define KeyTAG_UNIT_kt			1110 // [kt]	カラット	0.0002kg
#define KeyTAG_UNIT_ozav		1111 // [oz] オンス常用	0.028349523125kg
#define KeyTAG_UNIT_lbav		1112 // [lb] ポンド常用	0.45359237kg
#define KeyTAG_UNIT_KANN		1113 // [貫]				3.75kg
#define KeyTAG_UNIT_MONN		1114 // [匁]				0.00375kg

#define KeyTAG_UNIT_m2			1200 // [㎡]				1㎡
#define KeyTAG_UNIT_cm2			1201 // [c㎡]			0.0001㎡
#define KeyTAG_UNIT_are			1202 // [a]		アール	100㎡
#define KeyTAG_UNIT_ha			1203 // [ha]	㌶		10000㎡
#define KeyTAG_UNIT_km2			1204 // [k㎡]			1000000㎡
#define KeyTAG_UNIT_acre		1210 // [ac]	エーカー	4046.8564224㎡
#define KeyTAG_UNIT_sqft		1211 // [sqft]	平方ft	0.09290304㎡
#define KeyTAG_UNIT_sqin		1212 // [sqin]	平方in	0.00064516㎡
#define KeyTAG_UNIT_TUBO		1213 // [坪]				3.305785㎡
#define KeyTAG_UNIT_UNE			1214 // [畝]				99.17355㎡
#define KeyTAG_UNIT_TAN			1215 // [反]				991.7355㎡

#define KeyTAG_UNIT_m3			1300 // [㎥]				1㎥
#define KeyTAG_UNIT_cm3			1301 // [c㎡]			0.000001㎡
#define KeyTAG_UNIT_L			1302 // [L]		リットル	0.001㎡
#define KeyTAG_UNIT_dL			1303 // [dL]	デシL	0.0001㎡
#define KeyTAG_UNIT_mL			1304 // [mL]	ミリL	0.00001㎡
#define KeyTAG_UNIT_cc			1305 // [cc]			0.00001㎡
#define KeyTAG_UNIT_cuin		1310 // [cuin]	立方in	0.0016387064㎡
#define KeyTAG_UNIT_cuft		1311 // [cuft]	立方ft	0.028316846592㎡
#define KeyTAG_UNIT_galus		1312 // [galus]	ガロン	0.003785411784㎡
#define KeyTAG_UNIT_bbl			1313 // [bbl] バレル石油	1.58987294928㎡
#define KeyTAG_UNIT_MASU		1314 // [升]				0.0018039㎡
#define KeyTAG_UNIT_GOU			1315 // [合]				0.00018039㎡
#define KeyTAG_UNIT_TOU			1316 // [斗]				0.018039㎡

#define KeyTAG_UNIT_rad			1400 // [rad]			1rad
#define KeyTAG_UNIT_rDO			1401 // [°]		度		=PI/180rad
#define KeyTAG_UNIT_rMI			1402 // [']		分		=度/60rad
#define KeyTAG_UNIT_rSE			1403 // ["]		秒		=度/3600rad

#define KeyTAG_UNIT_K			1500 // [K]		ケルビン	1K
#define KeyTAG_UNIT_C			1501 // [°C]	摂氏		X+273.15K
#define KeyTAG_UNIT_F			1502 // [°F]	華氏		(X+459.67)/1.8K

#define KeyTAG_UNIT_s			1600 // [s]		秒		1s
#define KeyTAG_UNIT_ms			1601 // [ms]	ミリ秒	0.001s
#define KeyTAG_UNIT_min			1602 // [min]	分		60s
#define KeyTAG_UNIT_h			1603 // [h]		時		3600s
#define KeyTAG_UNIT_d			1604 // [d]		日		86400s
#define KeyTAG_UNIT_wk			1605 // [wk]	週		604800s

#define KeyTAG_UNIT_End			2999


//----------------------------------------------------Alpha
#define KeyALPHA_DEFAULT_ON		0.8	// 標準ボタン
#define KeyALPHA_DEFAULT_OFF	0.2	// 無機能ボタン
#define KeyALPHA_MSTORE_ON		0.8	// メモリ値あり
#define KeyALPHA_MSTORE_OFF		0.5	// メモリ値なし


@interface KeyButton : UIButton
{
	NSString	*RzUnit;

	NSInteger	iPage;
	NSInteger	iCol;
	NSInteger	iRow;
	NSInteger	iColorNo;
	float		fFontSize;
	BOOL		bDirty;		// YES=キー配置変更あり ⇒ 保存が必要
}

@property (nonatomic, retain) NSString		*RzUnit;

@property (nonatomic, assign) NSInteger		iPage;
@property (nonatomic, assign) NSInteger		iCol;
@property (nonatomic, assign) NSInteger		iRow;
@property (nonatomic, assign) NSInteger		iColorNo;
@property (nonatomic, assign) float			fFontSize;
@property (nonatomic, assign) BOOL			bDirty;

- (KeyButton *)initWithFrame:(CGRect)frame;

@end
