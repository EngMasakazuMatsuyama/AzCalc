//
//  KeyButton.h
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

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

#define KeyTAG_AC				200	// [AC]
#define KeyTAG_BS				201	// [BS]
#define KeyTAG_AddTAX			210	// [+Tax]
#define KeyTAG_SubTAX			211	// [-Tax]
#define KeyTAG_STANDARD_End		299

#define KeyTAG_MEMORY_Start		300
#define KeyTAG_MCLEAR			300
#define KeyTAG_MCOPY			301
#define KeyTAG_MPASTE			302
#define KeyTAG_M_PLUS			311	// [M+]
#define KeyTAG_M_MINUS			312	// [M-]
#define KeyTAG_M_MULTI			313	// [M×]
#define KeyTAG_M_DIVID			314	// [M÷]
#define KeyTAG_MEMORY_End		399

#define KeyTAG_MSTORE_Start		400
#define KeyTAG_MSTROE_End		499

#define KeyTAG_UNIT_Start		1000
#define KeyTAG_UNIT_End			2999


//----------------------------------------------------Alpha
#define KeyALPHA_DEFAULT_ON		0.8	// 標準ボタン
#define KeyALPHA_DEFAULT_OFF	0.2	// 無機能ボタン
#define KeyALPHA_MSTORE_ON		0.8	// メモリ値あり
#define KeyALPHA_MSTORE_OFF		0.5	// メモリ値なし


@interface KeyButton : UIButton
{
	NSInteger	iPage;
	NSInteger	iCol;
	NSInteger	iRow;
	NSInteger	iColorNo;
	float		fFontSize;
	BOOL		bDirty;		// YES=キー配置変更あり ⇒ 保存が必要
}

@property (nonatomic, assign) NSInteger		iPage;
@property (nonatomic, assign) NSInteger		iCol;
@property (nonatomic, assign) NSInteger		iRow;
@property (nonatomic, assign) NSInteger		iColorNo;
@property (nonatomic, assign) float			fFontSize;
@property (nonatomic, assign) BOOL			bDirty;

- (KeyButton *)initWithFrame:(CGRect)frame;

@end
