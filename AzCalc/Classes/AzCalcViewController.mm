//
//  AzCalcViewController.m
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#import	"Drum.h"
#import "AzCalcViewController.h"
#import "SettingVC.h"
#import "OptionVC.h"
#import "InformationVC.h"
#include "SBCD.h"  // BCD固定小数点演算 ＜＜この.cpp関数を利用するファイルの拡張子は .m ⇒ .mm にすること＞＞
#import "KeyButton.h"

#define	DRUMS_MAX				5		// この数のDrumsオブジェクトを常に生成する
#define	PICKER_COMPONENT_WiMIN	40		// 1コンポーネントの表示最小幅

#define DRUM_LEFT_OFFSET		11.0	// ドラム左側の余白（右側も同じになるようにする）
#define DRUM_GAP				 2.0	// ドラム幅指定との差

#define ROWOFFSET				2
#define DECIMALMAX				12
#define GOLDENPER				1.618	// 黄金比

#define MINUS_SIGN				@"−"	// Unicode[2212] 表示用文字　[002D]より大きくするため




//================================================================================AzCalcViewController
@interface AzCalcViewController (PrivateMethods)
- (void)vDrumButtonDisplay;
- (void)ibBuMemoryDisplay;
//- (void)vButtonDrag:(KeyButton *)button;
//- (void)vButtonDragUp:(KeyButton *)button;
- (void)vPadKeysDisplay;
- (void)vKeyboardPage:(NSInteger)iPage;
- (void)vKeyboardPage1Alook0;
- (void)vDrumButtonTouchUp:(UIButton *)button;
- (void)vDrumButtonDragEnter:(UIButton *)button;
- (void)iAdOn;
- (void)iAdOff;
@end

@implementation AzCalcViewController

/* IB(nib)利用時には通らない
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/* IB(nib)利用時には通らない
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)dealloc 
{
	//[maMemorys release];
	[aPadKeyButtons release];
	[aKeyMaster release];
	[aDrumButtons release];
	[aDrums release];

    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // 途中 return で抜けないこと！！！

	//========================================================== Upper ==============
	// ScrollUpper  (0)Pickerドラム  (1)TextView数式
	CGRect rect = ibScrollUpper.frame;
	ibScrollUpper.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height); 
	ibScrollUpper.scrollsToTop = NO;
	rect.origin.x = 0; //rect.size.width * MiScrollViewPage;
	[ibScrollUpper scrollRectToVisible:rect animated:NO]; // 初期ページ(1)にする

	//-----------------------------------------------------(0)ドラム ページ
	if (aDrumButtons) {
		[aDrumButtons release];	// viewDidUnloadされた後、ここを通る
		aDrumButtons = nil;
	}
	NSMutableArray *maButtons = [NSMutableArray new];
	// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
	for (int i=0; i<DRUMS_MAX; i++) {
		// ドラム切り替えボタン(透明)をaddSubView
		UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
		bu.tag = i;
#ifdef AzMAKE_SPLASHFACE
		bu.alpha = 0.0;	// これで非表示状態になる
		//bu.hidden = YES;   vDrumButtonDisplayで変更しているため効果なし
#else
		bu.alpha = 0.3; // 半透明 (0.0)透明にするとクリック検出されなくなる
		[bu addTarget:self action:@selector(vDrumButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
#endif
		[maButtons addObject:bu];
		//[self.view addSubview:bu];
		[ibScrollUpper addSubview:bu];
		//[bu release];
	}
	aDrumButtons = [[NSArray alloc] initWithArray:maButtons];	
	[maButtons release];
	[self.view bringSubviewToFront:ibBuMemory];		// ibBuMemory を最後の bu よりも上にする
	[self.view bringSubviewToFront:ibScrollLower];	// さらに ibScrollLower を ibBuMemory の上にする
	
	if (!aDrums) {
		// Drumオブジェクトは、SubViewではないので、最初に1度だけ生成し、viewDidUnloadでは破棄しない。
		NSMutableArray *maDrums	= [NSMutableArray new];
		// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
		for (int i=0; i<DRUMS_MAX; i++) {
			// ドラムインスタンス生成
			Drum *drum = [Drum new];
			[maDrums addObject:drum];
			[drum release];
		}
		aDrums = [[NSArray alloc] initWithArray:maDrums];		
		[maDrums release];
		
		entryComponent = 0;
		bDramRevers = NO;
		bZoomEntryComponent = NO;
	}

	// IBコントロールの初期化
	ibPicker.delegate = self;
	ibPicker.dataSource = self;
	ibPicker.showsSelectionIndicator = NO;
	
	// iAd
	CGRect theBannerFrame = self.view.frame;
	theBannerFrame.origin.y = -52;  // viewの外へ出す
	ibADBannerView.frame = theBannerFrame;	
	//[self iAdOff];
	bADbannerIsVisible = NO;
	bADbannerFirstTime = YES;

	//-----------------------------------------------------(1)数式 ページ
	// UITextView
	
	
	
	
	
	
	

	//========================================================== Lower ==============
	
	if (700 < self.view.frame.size.height) { // iPad
		iKeyPages = 3;
		iKeyCols = 7;	iKeyOffsetCol = 0; // AzdicKeys.plist C 開始位置
		iKeyRows = 7;	iKeyOffsetRow = 0;
		fKeyGap = 3.0;
		fKeyFontZoom = 1.5;
		//
		[self vPadKeysDisplay]; // iPad専用 メモリー20キー配置 および 回転処理
	} else { // iPhone
		iKeyPages = 3;
		iKeyCols = 5;	iKeyOffsetCol = 1; // AzdicKeys.plist C 開始位置
		iKeyRows = 5;	iKeyOffsetRow = 1;
		fKeyGap = 0.5;
		fKeyFontZoom = 1.0;
	}

	// ScrollLower 	(0)Memorys (1〜)Buttons
	MiScrollViewPage = 1; // DEFAULT PAGE
	rect = ibScrollLower.frame;
	ibScrollLower.contentSize = CGSizeMake(rect.size.width * iKeyPages, rect.size.height); 
	ibScrollLower.scrollsToTop = NO;
	rect.origin.x = rect.size.width * MiScrollViewPage;
	[ibScrollLower scrollRectToVisible:rect animated:NO]; // 初期ページ(1)にする

#ifdef AzMAKE_SPLASHFACE
	ibPicker.alpha = 0.7;
	ibBuMemory.hidden = YES;
	ibLbEntry.hidden = YES;
	ibADBannerView.hidden = YES;
	ibBuSetting.hidden = YES;
	ibBuInformation.hidden = YES;
	NSDictionary *dicKeys = [NSDictionary new];
#else
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	// standardUserDefaults からキー配置読み込む
	NSDictionary *dicKeys = [userDef objectForKey:GUD_KeyboardSet];
	if (dicKeys==nil) {
		// AzKeySet.plistからキー配置読み込む
		NSString *zKeySetFile;
		if (700 < self.view.frame.size.height) { // iPad
			zKeySetFile = [[NSBundle mainBundle] pathForResource:@"AzKeySet-iPad" ofType:@"plist"];
		} else {
			zKeySetFile = [[NSBundle mainBundle] pathForResource:@"AzKeySet" ofType:@"plist"];
		}
		//AzLOG(@"OfFile:zKeySetFile=%@", zKeySetFile);
		dicKeys = [[NSDictionary alloc] initWithContentsOfFile:zKeySetFile];	// 後で release している
		if (dicKeys==nil) {
			AzLOG(@"ERROR: AzKeySet.plist not Open");
			exit(-1);
		}
	}	
#endif
	
	// ibPickerは、画面左下を基点にしている。
	//float fYtop = 0;  //ibPicker.frame.size.height + 20;
	//float fYbot = ibScrollLower.frame.size.height; // self.view.frame.size.height;
	
	// ボタンの縦横比を「黄金率」にして余白をGapにする
	fKeyWidGap = 0;
	fKeyHeiGap = 0;
	fKeyWidth = ibScrollLower.frame.size.width / iKeyCols;  // 均等割り
	fKeyHeight = ibScrollLower.frame.size.height / iKeyRows; 
	float ff = (fKeyWidth - fKeyGap*2) / GOLDENPER;
	if (ff < fKeyHeight) {
		fKeyHeiGap = (fKeyHeight - ff) / 2.0;
		fKeyWidGap = fKeyGap;
	} else {
		ff = (fKeyHeight - fKeyGap*2) / GOLDENPER;
		if (ff < fKeyWidth) {
			fKeyWidGap = (fKeyWidth - ff) / 2.0;
			fKeyHeiGap = fKeyGap;
		} else {
			fKeyWidGap = fKeyGap;
			fKeyHeiGap = fKeyGap;
		}
	}
	fKeyWidth -= (fKeyWidGap * 2);
	fKeyHeight -= (fKeyHeiGap * 2);
	
	// subViewsで取得できる配列には、以下のaddSubViewした順（縦書きで左から右）に収められている。
	// UIButtonのみaddSubViewすること！ それを前提に後処理しているため。
	
	for (int page=0; page<iKeyPages; page++ ) 
	{
		float fx = ibScrollLower.frame.size.width * page + fKeyWidGap;
		for (int col=0; col<iKeyCols && col<100; col++ ) 
		{
			float fy = fKeyHeiGap;
			//KeyButton *buPrev = nil;	// タテ結合処理：直上ボタン
			for (int row=0; row<iKeyRows && row<100; row++ ) 
			{
				KeyButton *bu = [[KeyButton alloc] initWithFrame:CGRectMake(fx,fy, fKeyWidth,fKeyHeight)];
				//bu.contentMode = UIViewContentModeScaleToFill;
				//bu.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);  変化なしだった。
				[bu setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
				[bu setBackgroundImage:[UIImage imageNamed:@"Icon-DrumPush.png"] forState:UIControlStateHighlighted];
				bu.iPage = page;
				bu.iCol = iKeyOffsetCol + col;
				bu.iRow = iKeyOffsetRow + row;
				bu.bDirty = NO;
				NSString *zPCR = [[NSString alloc] initWithFormat:@"P%dC%dR%d", (int)bu.iPage, (int)bu.iCol, (int)bu.iRow];
				NSDictionary *dicKey = [dicKeys objectForKey:zPCR];
				if (dicKey) {
					//NSDictionary *dicMaster = nil;
					bu.tag = [[dicKey objectForKey:@"Tag"] integerValue]; // Function No.
					
					NSString *strText = [dicKey objectForKey:@"Text"];
					NSNumber *numSize = [dicKey objectForKey:@"Size"];
					NSNumber *numColor = [dicKey objectForKey:@"Color"];
					NSNumber *numAlpha = [dicKey objectForKey:@"Alpha"];
					
					if (strText==nil OR numSize==nil OR numAlpha==nil OR numColor==nil) {
						// AzKeyMaster 引用
						if (aKeyMaster==nil) { // AzKeyMaster.plistからマスターキー一覧読み込む
							NSString *zFile = [[NSBundle mainBundle] pathForResource:@"AzKeyMaster" ofType:@"plist"];
							aKeyMaster = [[NSArray alloc] initWithContentsOfFile:zFile];
							if (aKeyMaster==nil) {
								AzLOG(@"ERROR: AzKeyMaster.plist not Open");
								exit(-1);
							}
						}
						for (NSArray *aComponent in aKeyMaster) {
							for (NSDictionary *dic in aComponent) {
								if ([[dic objectForKey:@"Tag"] integerValue] == bu.tag) {
									strText = [dic objectForKey:@"Text"];
									numSize = [dic objectForKey:@"Size"];
									numColor = [dic objectForKey:@"Color"];
									numAlpha = [dic objectForKey:@"Alpha"];
								}
							}
						}
					}

					if (strText==nil) strText = @" "; // Space1
					[bu setTitle:strText forState:UIControlStateNormal];

					if (numSize) {
						bu.fFontSize = [numSize floatValue];
					} else {
						bu.fFontSize = 20;
					}
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:fKeyFontZoom * bu.fFontSize];
					
					if (numColor) {
						bu.iColorNo = [numColor integerValue];
						switch (bu.iColorNo) {
							case 1:	[bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];	break;
							case 2:	[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];	break;
							case 3:	[bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];	break;
							default:[bu setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];	break;
						}
					} else {
						bu.iColorNo = 1; // BLACK
						[bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
					}
					
					if (numAlpha) {
						bu.alpha = [numAlpha floatValue];
					} else {
						bu.alpha = KeyALPHA_DEFAULT_ON;
					}
					
				} else {
					bu.tag = -1; // Function No.
					//bu.titleLabel.text = @" "; // = nill ダメ  Space1
					[bu setTitle:@" " forState:UIControlStateNormal]; // = nill ダメ  Space1
					bu.alpha = KeyALPHA_DEFAULT_OFF;
				}
				
				//bu.contentMode = UIViewContentModeBottomLeft; // ibPickerは、画面左下を基点にしている。
				// 上と右のマージンが自動調整されるように。つまり、左下基点になる。
				bu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin; 
				[bu addTarget:self action:@selector(ibButton:) forControlEvents:UIControlEventTouchUpInside];
				//[bu addTarget:self action:@selector(vButtonDrag:) forControlEvents:UIControlEventTouchDragExit];
				//[bu addTarget:self action:@selector(vButtonDragUp:) forControlEvents:UIControlEventTouchUpOutside];

				// タテヨコ連結処理は、viewWillAppearで処理されるので、ここでは不要

				[ibScrollLower addSubview:bu];
				[bu release]; // init だから
				[zPCR release];
				
				fy += (fKeyHeight + fKeyHeiGap*2);
			}
			fx += (fKeyWidth + fKeyWidGap*2);
		}
	}
	//arrayKeys = [[NSArray alloc] initWithArray:maKeys];	
	//[maKeys release];
	[dicKeys release];

	if (aKeyMaster) {
		[aKeyMaster release];
		aKeyMaster = nil;
	}

	// Memory Display ドラム下部に隠しておく
	ibBuMemory.hidden = NO;
	CGRect rc = ibBuMemory.frame;
	rc.origin.y = ibPicker.frame.origin.y + ibPicker.frame.size.height;
	ibBuMemory.frame = rc;
	//
	//[self vMemoryLoad]; このviewDidLoad後、applicationDidBecomeActiveがコールされるため不要。

	if (ibADBannerView) {
		[self.view bringSubviewToFront:ibADBannerView]; // iAdをaDrumButtonsより上にする
	}
	
	[pool release]; // autorelease
}

// 裏画面(非表示)状態のときにメモリ不足が発生するとコールされるので、viewDidLoadで生成したOBJを解放する
- (void)viewDidUnload
{
    [super viewDidUnload];
	// IB(xib)で生成されたOBJは自動的に解放＆再生成されるので触れないこと。
	
	[aPadKeyButtons release];	aPadKeyButtons = nil;
	[aDrumButtons release];		aDrumButtons = nil;
	
	// aDrums は、SubViewではないから破棄しない。
	
	// この後、viewDidLoadがコールされて、改めてOBJ生成される
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // 途中 return で抜けないこと！！！

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Setting
#ifdef AzMAKE_SPLASHFACE
	MiSegDrums = 1; // Default.png ドラム数
#else
	MiSegDrums = 1 + (NSInteger)[defaults integerForKey:GUD_Drums];	// ドラム数 ＜＜セグメント値に +1 している＞＞
#endif
	if (DRUMS_MAX < MiSegDrums) MiSegDrums = DRUMS_MAX;  // 生成数を超えないように
	MiSegCalcMethod = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
	MiSegDecimal = (NSInteger)[defaults integerForKey:GUD_Decimal];
	if (DECIMAL_Float <= MiSegDecimal) MiSegDecimal = PRECISION; // [F]小数桁制限なし
	MiSegRound = (NSInteger)[defaults integerForKey:GUD_Round];
	MiSegReverseDrum = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];
	// Option
	switch ((NSInteger)[defaults integerForKey:GUD_GroupingSeparator]) {
		case 0:
			formatterGroupingSeparator( @"," );
			break;
		case 1:
			formatterGroupingSeparator( @"'" ); // [']0x27 アポストロフィー (シングルクオート)
			break;
		case 2:
			formatterGroupingSeparator( @" " );
			break;
		case 3:
			formatterGroupingSeparator( @"." );
			break;
		default: // (0)
			formatterGroupingSeparator( @" " );
			break;
	}

	//formatterGroupingSize( (int)[defaults integerForKey:GUD_GroupingSize] );				// Default[3]
	formatterGroupingType( (int)[defaults integerForKey:GUD_GroupingType] );				// Default[3]
	
	id obj = [ibScrollLower viewWithTag:KeyTAG_DECIMAL]; // (KeyTAG_DECIMAL)[.]小数点
	if (obj && [obj isMemberOfClass:[KeyButton class]]) {
		KeyButton *bu = (KeyButton *)obj;
		switch ((NSInteger)[defaults integerForKey:GUD_DecimalSeparator]) {
			case 0:
				//bu.titleLabel.text = これでは、一時的にしか書き変わらない。
				[bu setTitle:@"." forState:UIControlStateNormal];
				break;
			case 1:
				[bu setTitle:@"·" forState:UIControlStateNormal]; // ミドル・ドット（middle dot）
				break;
			case 2:
				[bu setTitle:@"," forState:UIControlStateNormal];
				break;
			default: // (0)
				[bu setTitle:@"." forState:UIControlStateNormal];
				break;
		}
		formatterDecimalSeparator( bu.titleLabel.text ); // 参照はOK
	}
	
	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.bChangeKeyboard) {
		// キーレイアウト変更モード
		if (aKeyMaster==nil) {
			// AzKeyMaster.plistからマスターキー一覧読み込む
			NSString *zFile = [[NSBundle mainBundle] pathForResource:@"AzKeyMaster" ofType:@"plist"];
			aKeyMaster = [[NSArray alloc] initWithContentsOfFile:zFile];
			if (aKeyMaster==nil) {
				AzLOG(@"ERROR: AzKeyMaster.plist not Open");
				exit(-1);
			}
			buChangeKey = nil;
		}

		for (UIButton *bu in aDrumButtons) {
			bu.hidden = YES;
		}
		
		ibBuMemory.hidden = YES;
		ibLbEntry.hidden = YES;
		ibPicker.showsSelectionIndicator = YES;
		[ibPicker reloadAllComponents];
		// 全ドラム選択行を0にする
		for (int i=0; i<[aKeyMaster count]; i++) {
			[ibPicker selectRow:0 inComponent:i animated:NO];
		}
		 
		// キー再表示：連結されたキーがあれば独立させる
		NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
		for (id obj in [aKeys reverseObjectEnumerator]) {  // 最後にaddSubViewしたのが先頭[0]になるから逆順で
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				// 連結されたボタンを全て最小独立表示する
				if (bu.frame.size.width != fKeyWidth OR bu.frame.size.height != fKeyHeight) {
					CGRect rc = bu.frame;
					rc.size.width = fKeyWidth;
					rc.size.height = fKeyHeight;
					bu.frame = rc;
				}
				if (bu.hidden) {
					bu.hidden = NO;
				}
#ifdef xxxxxAzDEBUGxxxxxxxx		
				// DEBUG: AzKeyMasterの修正を反映させる
				for (NSArray *aComponent in aKeyMaster) {
					for (NSDictionary *dic in aComponent) {
						if ([[dic objectForKey:@"Tag"] integerValue] == bu.tag) {
							// Dirty
							bu.bDirty = YES; // 変更あり ⇒ 要保存
							// Tag
							bu.tag = [[dic objectForKey:@"Tag"] integerValue];
							if (bu.tag != -1) { // Nothing Space
								// Text
								[bu setTitle:[dic objectForKey:@"Text"] forState:UIControlStateNormal];
								// Color
								bu.iColorNo = [[dic objectForKey:@"Color"] integerValue];
								switch (bu.iColorNo) {
									case 1:	[bu setTitleColor:[UIColor blackColor]	forState:UIControlStateNormal];	break;
									case 2:	[bu setTitleColor:[UIColor redColor]	forState:UIControlStateNormal];	break;
									case 3:	[bu setTitleColor:[UIColor blueColor]	forState:UIControlStateNormal];	break;
									default:[bu setTitleColor:[UIColor clearColor]	forState:UIControlStateNormal];	break;
								}
								// Size
								float fSize = [[dic objectForKey:@"Size"] floatValue]; 
								bu.fFontSize = fSize; 
								if (700 < self.view.frame.size.height) fSize *= 1.5; // iPadやや拡大
								bu.titleLabel.font = [UIFont boldSystemFontOfSize:fSize];
								// Alpha
								bu.alpha = [[dic objectForKey:@"Alpha"] floatValue];
							}
							break;
						}
					}
				}
#endif
			}
		}
		[self iAdOff];
	} 
	else {
		// ドラタク通常モード
		if (aKeyMaster) {
			[aKeyMaster release];
			aKeyMaster = nil;
		}
		ibBuMemory.hidden = NO;
		ibLbEntry.hidden = NO;
		ibPicker.showsSelectionIndicator = NO;
		
		// reSetting
		for (Drum *drum in aDrums) {
			[drum reSetting];
		}
		
		// 表示ドラム数(component数)が変わったときの処理
		if (MiSegDrums != ibPicker.numberOfComponents) {
			if (MiSegDrums <= entryComponent) { // entryComponentが表示ドラムを超えないように補正する
				entryComponent = MiSegDrums - 1;
			}
			// [ibPicker reloadAllComponents];  vDrumButtonDisplay内で呼び出している
		}
		
		// Entryセル表示
		[self vDrumButtonDisplay];
		// [M]ラベル表示
		[self ibBuMemoryDisplay];

		// キー再表示
		NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
		// タテ連結処理
		for (id obj in [aKeys reverseObjectEnumerator]) {  // 最後にaddSubViewしたのが先頭[0]になるから逆順で
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				if (bu.tag!=-1 && bu.hidden == NO) { // 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する
					// タテ連結処理
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu2 = (KeyButton *)obj;
							if (bu.iPage == bu2.iPage) {
								if (bu.iCol < bu2.iCol) break; // 次の列になれば終了
								if (bu2.hidden == NO && bu != bu2
									&& bu.iCol == bu2.iCol
									&& bu.iRow < bu2.iRow)
								{	// 同列 ＆ 下行 ならば タテ連結
									if (bu.tag != bu2.tag) break; // 下行のTab違えば即終了
									CGRect rc = bu.frame;
									rc.size.height = CGRectGetMaxY(bu2.frame) - rc.origin.y;
									bu.frame = rc;
									// 非表示にする
									bu2.hidden = YES;
								}
							}
						}
					}
				}
			}
		}

		// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
		for (id obj in [aKeys reverseObjectEnumerator]) {  // 最後にaddSubViewしたのが先頭[0]になるから逆順で
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				if (bu.tag!=-1 && bu.hidden == NO) { // 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する
					// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu2 = (KeyButton *)obj;
							if (bu.iPage == bu2.iPage) {
								//if (bu.iRow < bu2.iRow) break; タテ方向に走査するため継続
								if (bu2.hidden == NO && bu != bu2 
									&& bu.iRow == bu2.iRow 
									&& bu.iCol < bu2.iCol)
								{	// 同行 ＆ 右列 ならば ヨコ結合
									if (bu.tag != bu2.tag) break; // 右列のTab違えば即終了
									if (bu.frame.size.height != bu2.frame.size.height) break; // 右列の高さが違えば即終了
									CGRect rc = bu.frame;
									rc.size.width = CGRectGetMaxX(bu2.frame) - rc.origin.x;
									bu.frame = rc;
									// 非表示にする
									bu2.hidden = YES;
								}
							}
						}
					}
				}
			}
		}
		//[self iAdOn];
		//[self.view becomeFirstResponder];
	}

	[pool release];
}

- (void)viewDidAppear:(BOOL)animated // 画面表示された後にコールされる
{
	[super viewDidAppear:animated];
	if (buChangeKey) {
		//buChangeKey.backgroundColor = [UIColor clearColor]; // 前選択を戻す
		// 復帰
		[buChangeKey setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
		buChangeKey = nil;
	}
}

- (void)viewWillDisappear:(BOOL)animated // 非表示になる直前にコールされる
{
	[super viewWillDisappear:animated];
	
	if (buChangeKey) {
		//buChangeKey.backgroundColor = [UIColor clearColor]; // 前選択を戻す
		// 復帰
		[buChangeKey setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
		buChangeKey = nil;
	}
}

/*
- (void)viewDidDisappear:(BOOL)animated // 非表示になった後にコールされる
{
	[super viewDidDisappear:animated];
}
*/

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (700 < self.view.frame.size.height) return YES; // iPad
	return NO;
}

//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation: ＜＜OS 3.0以降は非推奨×××
// 回転の開始前にコールされる。 ＜＜OS 3.0以降の推奨＞＞
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration

// 回転アニメーションの開始直前に呼ばれる。 この直前の配置から、ここでの配置までの移動がアニメーション表示される。
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	if (self.view.frame.size.height < 700) return; // iPhone

	// iPad専用 メモリー20キー配置 および 回転処理
	[self vPadKeysDisplay]; 

	// aDrumButtons
	[self vDrumButtonDisplay];
	
	// ibBuMemory：定位置(隠れる位置)に、後で改めて ibBuMemoryDisplay する
	CGRect rc = ibBuMemory.frame;
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		// ヨコ ⇒ W1024 H768-20 縦20行1列表示
		rc.origin.y = 768 - ibScrollLower.frame.size.height;
	} else {
		// タテ ⇒ W768 H1024-20 縦7行3列表示
		rc.origin.y = 1024 - ibScrollLower.frame.size.height;
	}
	ibBuMemory.frame = rc;
	[self ibBuMemoryDisplay]; // 改めて表示
}

/*
// 回転が完了したときにコールされる。
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	if (self.view.frame.size.height < 700) return; // iPhone
}
*/


// Entryセル表示：entryComponentの位置にibLbEntryActiveを表示する
- (void)vDrumButtonDisplay
{
	assert(0 <= MiSegDrums);
	//float fWid = self.view.frame.size.width - DRUM_LEFT_OFFSET*2;
	float fWid = ibPicker.frame.size.width - DRUM_LEFT_OFFSET*2;
	float fWiMin, fWiMax;
	if (bZoomEntryComponent) {  // entryComponentを拡大する
		fWiMin = PICKER_COMPONENT_WiMIN; // 1コンポーネントの表示最小幅
		fWiMax = fWid - ((PICKER_COMPONENT_WiMIN + DRUM_GAP) * (MiSegDrums-1));
	} else {
		fWiMin = (fWid / MiSegDrums) - DRUM_GAP;
		fWiMax = fWiMin; // 均等
	}
	float fX = DRUM_LEFT_OFFSET + 4.0;
	float fY = ibPicker.frame.origin.y;
	int i = 0;
	for ( ; i<MiSegDrums ; i++) {
		UIButton *bu = [aDrumButtons objectAtIndex:i];
		bu.hidden = NO;
		if (i == entryComponent) {
			bu.frame = CGRectMake(fX,fY+155, fWiMax-6,28); // 選択中
			bu.backgroundColor = [UIColor greenColor];
			// Next
			fX += (fWiMax + DRUM_GAP);
		} else {
			bu.frame = CGRectMake(fX,fY, fWiMin-6,fY+ibPicker.frame.size.height);  // 非選択時
			//bu.backgroundColor = [UIColor yellowColor];  //DEBUG
			bu.backgroundColor = [UIColor clearColor];
			// Next
			fX += (fWiMin + DRUM_GAP);
		}
	}
	for ( ; i<DRUMS_MAX ; i++) {
		UIButton *bu = [aDrumButtons objectAtIndex:i];
		bu.hidden = YES;
	}
	[ibPicker reloadAllComponents];
}

// [M]ラベル表示
- (void)ibBuMemoryDisplay
{
	NSString *zNumPaste = stringAzNum([UIPasteboard generalPasteboard].string); // Az数値文字列化する
	if (0 < [zNumPaste length]) 
	{	// ペーストボードに数値がある
		NSString *zTitle;
		if (KeyTAG_MSTORE_Start <= ibBuMemory.tag) {
			zTitle = [NSString stringWithFormat:@"M%d  %@", 
				   (int)ibBuMemory.tag - KeyTAG_MSTORE_Start,
				   stringFormatter(zNumPaste, YES)];
		} else {
			ibBuMemory.tag = 0; // Clear
			zTitle = [NSString stringWithFormat:@"PB  %@",  // Pasteboardより
				   stringFormatter(zNumPaste, YES)];
		}
		[ibBuMemory setTitle:zTitle forState:UIControlStateNormal];
		// ボタンを出現させる
		CGRect rc = ibBuMemory.frame;
		rc.origin.y = ibScrollLower.frame.origin.y; // 定位置：ibScrollLowerの裏に隠れている
		// 文字数からボタンの幅を調整する
		CGSize sz = [zTitle sizeWithFont:ibBuMemory.titleLabel.font];
		AzLOG(@"sizeWithFont = W%f, H%f", sz.width, sz.height);
		rc.size.width = sz.width + 20;
		if (260 < rc.size.width) rc.size.width = 260; // Over
		rc.origin.x = (ibPicker.frame.size.width - rc.size.width) / 2.0;
//		if (ibBuMemory.frame.origin.y < ibScrollLower.frame.origin.y) return; // 既に出現している
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// アニメ終了時の位置をセット
		rc.origin.y -= (ibBuMemory.frame.size.height + 1.0); // 出現位置
		ibBuMemory.frame = rc;
	} 
	else {
		if (ibScrollLower.frame.origin.y <= ibBuMemory.frame.origin.y) return; // 既に隠れている
		// ボタンをibScrollLowerの裏に隠す
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// アニメ終了時の位置をセット
		CGRect rc = ibBuMemory.frame;
		rc.origin.y = ibScrollLower.frame.origin.y; // 定位置：ibScrollLowerの裏に隠れている
		ibBuMemory.frame = rc;
	}
	// アニメ開始
	[UIView commitAnimations];
}

- (void)vDrumButtonTap1Clear
{
	bDrumButtonTap1 = NO;
}

- (void)vDrumButtonTouchUp:(UIButton *)button
{
	if (aKeyMaster) {
		// キーレイアウト変更モード
		return;
	}

	// ダブルタップ式
	if (bDrumButtonTap1) {
		bDrumButtonTap1 = NO;
		// Second (Double) Tapping：ドラム幅の拡大／均等を切り替える
		if (entryComponent == button.tag) {
			// ドラム幅を拡大する
			bZoomEntryComponent = !bZoomEntryComponent;  // 拡大／均等トグル式
		}
	} else {
		// First Tapping
		bDrumButtonTap1 = YES;
		[self performSelector:@selector(vDrumButtonTap1Clear) withObject:nil afterDelay:0.5f]; // 0.5秒後にクリアする
	}
/*
	// シングルタップ式
	if (entryComponent == button.tag) {
		// ドラム幅を拡大する
		bZoomEntryComponent = !bZoomEntryComponent;  // 拡大／均等トグル式
	}
*/

	BOOL bTouchAction = NO;
	if (entryComponent != button.tag) {
		entryComponent = button.tag;	// ドラム切り替え
		bZoomEntryComponent = NO;  // 均等サイズに戻す
		bTouchAction = YES;
	}
	
	// 以下の処理をしないと pickerView が再描画されない。
	NSInteger iDrums = MiSegDrums;
	MiSegDrums = 0;
	[ibPicker reloadAllComponents];
	MiSegDrums = iDrums;
	// ibPicker は、以下のアニメーションに対応しない。

	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	// アニメ終了時の位置をセット
	
	// Entryセル表示　＜＜この中でpickerView再描画
	[self vDrumButtonDisplay];

	// アニメ開始
	[UIView commitAnimations];

/*上のとおりアニメ式にした。	
	if (bTouchAction) {
		NSInteger iRow = [ibPicker selectedRowInComponent:entryComponent];
		[ibPicker selectRow:iRow+1 inComponent:entryComponent animated:NO]; // 1行びっくらポン
		[ibPicker selectRow:iRow inComponent:entryComponent animated:YES];
	}*/
}

- (void)vDrumButtonDragEnter:(UIButton *)button;
{
	AzLOG(@"vDrumButtonDragEnter: button.tag=%d", (int)button.tag);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)ibBuMemory:(UIButton *)button
{
	// [Paste]
	KeyButton *kb = [[KeyButton alloc] initWithFrame:CGRectZero];
	kb.tag = KeyTAG_MPASTE; // [Paste]
	[kb setTitle:@"Paste" forState:UIControlStateNormal];
	[self ibButton:kb]; // Paste処理させる
	[kb release];
}

- (IBAction)ibBuSetting:(UIButton *)button
{
	if (aKeyMaster) {
		//
		// AzKeySet.plistからキー配置を読み込む
		NSString *zKeySetFile;
		if (700 < self.view.frame.size.height) { // iPad
			zKeySetFile = [[NSBundle mainBundle] pathForResource:@"AzKeySet-iPad" ofType:@"plist"];
		} else {
			zKeySetFile = [[NSBundle mainBundle] pathForResource:@"AzKeySet" ofType:@"plist"];
		}
		NSMutableDictionary *mdKeySet = [[NSMutableDictionary alloc] initWithContentsOfFile:zKeySetFile];
		if (mdKeySet==nil) {
			AzLOG(@"ERROR: AzKeySet.plist not Open");
			exit(-1);
		}
		BOOL bSave = NO;
		// bu.bDirty == YES だけ更新する
		NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
		for (id obj in aKeys) {
			//AzLOG(@"aKeys:obj class=%@", [[obj class] description]); // "KeyButton" が得られる
			assert([obj isMemberOfClass:[KeyButton class]]);
			KeyButton *bu = (KeyButton *)obj;
			if (bu.bDirty) {
				NSString *zPCR = [[NSString alloc] initWithFormat:@"P%dC%dR%d", (int)bu.iPage, (int)bu.iCol, (int)bu.iRow];
				NSMutableDictionary *dic = [mdKeySet objectForKey:zPCR];
				if (dic) {
					[dic setValue:[NSNumber numberWithInteger:bu.tag]		forKey:@"Tag"];
					[dic setValue:bu.titleLabel.text						forKey:@"Text"];
					[dic setValue:[NSNumber numberWithFloat:bu.fFontSize]	forKey:@"Size"];
					[dic setValue:[NSNumber numberWithFloat:bu.alpha]		forKey:@"Alpha"];
					[dic setValue:[NSNumber numberWithInteger:bu.iColorNo]	forKey:@"Color"];
				} else {
					dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						   [NSNumber numberWithInteger:bu.tag],		@"Tag",
						   bu.titleLabel.text,						@"Text",
						   [NSNumber numberWithFloat:bu.fFontSize],	@"Size",
						   [NSNumber numberWithFloat:bu.alpha],		@"Alpha",
						   [NSNumber numberWithInteger:bu.iColorNo],@"Color", nil];
					[mdKeySet setObject:dic forKey:zPCR];
					[dic release];
				}
				[zPCR release];
				bSave = YES;
			}
		}		
		if (bSave && mdKeySet) {
			/*	// キーレイアウト変更モード：AzKeySet.plistへ保存する
			 AzLOG(@"writeToFile:zKeySetFile=%@", zKeySetFile);
			 //AzLOG(@"mdKeySet:%@", [mdKeySet description]);
			 if ([mdKeySet writeToFile:zKeySetFile atomically:YES] != YES) {
			 AzLOG(@"writeToFile = NO");
			 }
			 [mdKeySet release];*/

			// standardUserDefaults へ保存する　＜＜アプリがアップデートされても保持される＞＞
			NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
			[userDef setObject:mdKeySet forKey:GUD_KeyboardSet];
			if ([userDef synchronize] != YES) { // file write
				AzLOG(@"GUD_KeyboardSet synchronize: ERROR");
			}
			[mdKeySet release];	mdKeySet = nil;
		}
	}

	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ibSettingVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;  // 水平回転
												// UIModalTransitionStylePartialCurl; // めくれ上がる（計算式表示に使う）
	//appDelegate.ibInformationVC.view.hidden = YES;
	//appDelegate.ibSettingVC.view.hidden = NO;
	//appDelegate.ibOptionVC.view.hidden = YES;
	[self presentModalViewController:appDelegate.ibSettingVC animated:YES];
}

- (IBAction)ibBuInformation:(UIButton *)button
{
	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ibInformationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//appDelegate.ibInformationVC.view.hidden = NO;
	//appDelegate.ibSettingVC.view.hidden = YES;
	//appDelegate.ibOptionVC.view.hidden = YES;
	[self presentModalViewController:appDelegate.ibInformationVC animated:YES];
}

/*
// MARK: iAd 広告表示を閉じて元に戻る前に呼ばれる
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	AzLOG(@"===== bannerViewActionDidFinish =====");
	banner.hidden = YES;	// 一度見れば非表示にする
}
*/


//------------------------------------------------------------------------------------
//-----------------------------------------------------------Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	if (aKeyMaster) {
		return [aKeyMaster count];
	}
	
	assert(MiSegDrums <= DRUMS_MAX);
	return MiSegDrums;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (aKeyMaster) {
		return [[aKeyMaster objectAtIndex:component] count]; 
	}

	Drum *dm = [aDrums objectAtIndex:component];
	return ROWOFFSET + [dm count] + 1;  // (ROWOFFSET)タイトル行 + Drum(array行数) + 1(entry行)
}


// 幅
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//float fWid = self.view.frame.size.width - DRUM_LEFT_OFFSET*2; // DRUM_LEFT_OFFSET*2 = ドラム左右余白
	float fWid = ibPicker.frame.size.width - DRUM_LEFT_OFFSET*2; // DRUM_LEFT_OFFSET*2 = ドラム左右余白

	if (aKeyMaster) {
		return (fWid / [aKeyMaster count]) - DRUM_GAP;
	}

	if (bZoomEntryComponent) {
		if (component == entryComponent) {  // entryComponentを拡大する
			return fWid - ((PICKER_COMPONENT_WiMIN + DRUM_GAP) * (MiSegDrums-1));
		} else {
			return PICKER_COMPONENT_WiMIN; // 1コンポーネントの表示最小幅
		}
	}
	return (fWid / MiSegDrums) - DRUM_GAP; // 均等
}


// 高さ
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	if (aKeyMaster) {
		return 40;
	}
	return 30;
}

/*  viewForRow:と共用はできない！
- (NSString *)pickerView:(UIPickerView *)pickerView 
			 titleForRow:(NSInteger)row 
			forComponent:(NSInteger)component
{
	return nil;
}
*/

- (UIView *)pickerView:(UIPickerView *)pickerView 
			viewForRow:(NSInteger)row 
		  forComponent:(NSInteger)component
		   reusingView:(UIView *)reView
{
	UIView *vi = reView;  // Viewが再利用されるため
	UILabel *lb = nil;
	CGSize sz = [pickerView rowSizeForComponent:component];

	if (aKeyMaster) { // キーボード変更モード
		if (vi == nil) {
			vi = [[[UIView alloc] initWithFrame:CGRectMake(0,0,sz.width,sz.height)] autorelease];
			// lb addSubview
			lb = [[UILabel alloc] initWithFrame:CGRectMake(5,0,sz.width-10,sz.height)];
			lb.tag = 981;
			lb.backgroundColor = [UIColor clearColor];
			lb.adjustsFontSizeToFitWidth = YES;
			lb.minimumFontSize = 6;
			lb.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			[vi addSubview:lb]; [lb release];
		} else {
			// vi再利用可能なとき
			lb = (UILabel *)[vi viewWithTag:981];
		}

		lb.textAlignment = UITextAlignmentCenter;
		lb.backgroundColor = [UIColor clearColor];
		
		lb.textColor = [UIColor blackColor];
		lb.font = [UIFont boldSystemFontOfSize:30];
		lb.text = [[[aKeyMaster objectAtIndex:component] objectAtIndex:row] objectForKey:@"Text"];
		
		return vi;
	}
	
	// ドラタク通常モード
	assert(component < MiSegDrums);
	if (vi == nil) {
		vi = [[[UIView alloc] initWithFrame:CGRectMake(0,0,sz.width,30)] autorelease];
		// addSubview
		lb = [[UILabel alloc] initWithFrame:CGRectMake(5,0,sz.width-10,30)];
		lb.tag = 991;
		lb.backgroundColor = [UIColor clearColor];
		lb.adjustsFontSizeToFitWidth = YES;
		lb.minimumFontSize = 6;
		lb.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		[vi addSubview:lb]; [lb release];
	}
	if (lb == nil) {
		lb = (UILabel *)[vi viewWithTag:991];
	}
	
	NSInteger iRow = row - ROWOFFSET; // タイトル行を空けるため
	if (iRow < 0) {
		if (component==0) {
			switch (iRow) {
				case -2:
					lb.textAlignment = UITextAlignmentLeft;
					lb.font = [UIFont systemFontOfSize:20];
					lb.text =  NSLocalizedString(@"Drum Calculator",nil);
					break;
				case -1:
					lb.textAlignment = UITextAlignmentLeft;
					lb.font = [UIFont systemFontOfSize:14];
					lb.text =  NSLocalizedString(@"Azukid",nil);
					break;
				default:
					lb.text =  @"";
					break;
			}
		} else {
			lb.text =  @"";
		}
	}
	else {
		Drum *drum = [aDrums objectAtIndex:component];
		lb.textAlignment = UITextAlignmentRight;
		
		if (iRow < [drum count]) {			// drum.formula 表示
			NSString *zOpe = [drum.formulaOperators objectAtIndex:iRow]; // 計算セクション開始行では常に" "スペース
			if ([zOpe hasPrefix:OP_START]) {
#ifndef AzDEBUG
				if ([zOpe length]<=1) {
					zOpe = @"";  // 開始行の記号は非表示
				} else {
					zOpe = [zOpe substringFromIndex:1]; // OP_STARTより後の文字 [√]
				}
#endif
			} else if ([zOpe hasPrefix:OP_SUB]) {  // Unicode[002D]
				zOpe = MINUS_SIGN; // Unicode[2212]
			}
			if ([[drum.formulaNumbers objectAtIndex:iRow] length] <= 0) {
				lb.textColor = [UIColor blackColor];
				lb.font = [UIFont systemFontOfSize:30];
				//lb.text = [NSString stringWithFormat:@"%@ ", zOpe];
				lb.text = [NSString stringWithFormat:@"%@", zOpe];
			} 
			else {
				double dNum = [[drum.formulaNumbers objectAtIndex:iRow] doubleValue];
				if (dNum < 0) {
					lb.textColor = [UIColor redColor];
				} else {
					lb.textColor = [UIColor blackColor];
				}
				lb.font = [UIFont systemFontOfSize:30];
				//lb.text = [NSString stringWithFormat:@"%@ %@%@", zOpe, 
				lb.text = [NSString stringWithFormat:@"%@%@%@", zOpe, 
						   stringFormatter([drum.formulaNumbers objectAtIndex:iRow], YES),
						   [drum.formulaUnits objectAtIndex:iRow]];
			}
		} else {			// drum.entry 表示
			NSString *zOpe = drum.entryOperator;
			if ([zOpe hasPrefix:OP_START]) {
				if ([zOpe length]<=1) {
					zOpe = @"";  // 開始行の記号は非表示
				} else {
					zOpe = [zOpe substringFromIndex:1]; // OP_STARTより後の文字 [√]
				}
			} else if ([zOpe hasPrefix:OP_SUB]) {  // Unicode[002D]
				//zOpe = MINUS_SIGN; // Unicode[2212]
				// 演算子（OP_SUB=Unicode[002D]）を表示文字（MINUS_SIGN=Unicode[002D]）に置換する
				zOpe = [zOpe stringByReplacingOccurrencesOfString:OP_SUB withString:MINUS_SIGN];
			}
			if ([drum.entryNumber length] <= 0) {
				lb.textColor = [UIColor blackColor];
				lb.font = [UIFont systemFontOfSize:30];
				lb.text = [NSString stringWithFormat:@"%@%@ ", 
						   stringFormatter(drum.entryAnswer, YES), zOpe]; // 回答＆演算子
			} 
			else if ([drum.entryNumber hasPrefix:@"@"]) {
				// 先頭が"@"ならば以降の文字列をそのまま表示する（エラーメッセージ表示）
				lb.textColor = [UIColor blackColor];
				lb.font = [UIFont systemFontOfSize:26];
				lb.text = [drum.entryNumber substringFromIndex:1];
			} 
			else {
				double dNum = [drum.entryNumber doubleValue];
				if (dNum < 0) {
					lb.textColor = [UIColor redColor];
				} else {
					lb.textColor = [UIColor blackColor];
				}
				lb.font = [UIFont systemFontOfSize:30];
				if ([drum.entryOperator isEqualToString:OP_ANS]) {
					lb.text = [NSString stringWithFormat:@"%@%@%@",
							   zOpe, 
							   stringFormatter(drum.entryNumber, YES),
							   drum.entryUnit];
				} else {
					lb.text = [NSString stringWithFormat:@"%@%@%@",
							   zOpe, 
							   stringFormatter(drum.entryNumber, NO), // NO:入力どおり表示するため
							   drum.entryUnit];
				}
			}
		}
	}
	return vi;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (aKeyMaster) { // キーボード変更モード
		// 他リセット
		for (int i=0; i<[aKeyMaster count]; i++) {
			if (i != component) {
				[ibPicker selectRow:0 inComponent:i animated:YES];
			}
		}
		return;
	}
	
	Drum *drum = [aDrums objectAtIndex:component];
	if ([drum count] <= row) {
		bDramRevers = NO;	// NO=「ドラム逆転やりなおしモード」を一時無効にする
	} else {
		bDramRevers = YES;	// YES=「ドラム逆転やりなおしモード」を許可
		drum.entryRow = row;
	}
}
/*
- (void)vButtonDrag:(KeyButton *)button
{
	AzLOG(@"----------vButtonDrag");
}

- (void)vButtonDragUp:(KeyButton *)button
{
	AzLOG(@"-----------------vButtonDragUp");
}
*/

- (IBAction)ibButton:(KeyButton *)button   // 全ボタンを割り当てている
{
	BOOL bDrumRefresh = YES; // =YES:ドラムを再表示する  =NO:[Copy]後などドラムを動かしたくないとき
	
	if (aKeyMaster) {
		// キーレイアウト変更モード // ドラム選択中のキーを割り当てる
		int iComponent = 0;
		int iRow = 0;  // 見出し行
		for (int i=0; i<[aKeyMaster count]; i++) {
			iRow = [ibPicker selectedRowInComponent:i];
			if (0 < iRow) {
				iComponent = i;
				break;
			}
		}
		if (iComponent==0 && iRow==0) { // ドラム選択が無い場合、押したキーの選択にする
			int iComp = 0;
			for (NSArray *aComponent in aKeyMaster) {
				int iDict = 0;
				for (NSDictionary *dic in aComponent) {
					if ([[dic objectForKey:@"Tag"] integerValue] == button.tag) {
						[ibPicker selectRow:iDict inComponent:iComp animated:YES];
						// 他リセット
						for (int i=0; i<[aKeyMaster count]; i++) {
							if (i != iComp) [ibPicker selectRow:0 inComponent:i animated:YES];
						} break;
					} iDict++;
				} iComp++;
			} 
			return;
		}
		// iRow==0 ならば .tag=(-1)未定義になる
		NSDictionary *dic = [[aKeyMaster objectAtIndex:iComponent] objectAtIndex:iRow];
		if (dic==nil) return;
		// Tag
		button.tag = [[dic objectForKey:@"Tag"] integerValue];
		if (button.tag == -1) { // Nothing Space
			button.bDirty = YES; // 変更あり ⇒ 保存される
			// Text
			[button setTitle:@"" forState:UIControlStateNormal];
			// Color
			button.iColorNo = 0;
			//button.titleLabel.textColor = [UIColor clearColor];
			[button setTitleColor:[UIColor clearColor]	forState:UIControlStateNormal];
			// Size
			button.fFontSize = 5;
			button.titleLabel.font = [UIFont boldSystemFontOfSize:5];
			// Alpha
			button.alpha = [[dic objectForKey:@"Alpha"] floatValue];
		} else {
			button.bDirty = YES; // 変更あり ⇒ 保存される
			// Text
			[button setTitle:[dic objectForKey:@"Text"] forState:UIControlStateNormal];
			// Color
			button.iColorNo = [[dic objectForKey:@"Color"] integerValue];
			switch (button.iColorNo) {
				case 1:	[button setTitleColor:[UIColor blackColor]	forState:UIControlStateNormal];	break;
				case 2:	[button setTitleColor:[UIColor redColor]	forState:UIControlStateNormal];	break;
				case 3:	[button setTitleColor:[UIColor blueColor]	forState:UIControlStateNormal];	break;
				default:[button setTitleColor:[UIColor clearColor]	forState:UIControlStateNormal];	break;
			}
			// Size
			float fSize = [[dic objectForKey:@"Size"] floatValue]; 
			button.fFontSize = fSize; 
			if (700 < self.view.frame.size.height) fSize *= 1.5; // iPadやや拡大
			button.titleLabel.font = [UIFont boldSystemFontOfSize:fSize];
			// Alpha
			button.alpha = [[dic objectForKey:@"Alpha"] floatValue];
		}
		return;
	}

	//-----------------------------------ここから、ドラタク通常モード処理
/*	if (button.tag < 0) {
		[self vKeyboardPage:1]; // キー1ページへ
		return;
	}*/
	
	// ドラム逆回転時の処理
	NSString *zCopyNumber = nil; // 遡って数値を[Copy]するのに備えて保持する
	Drum *drum = [aDrums objectAtIndex:entryComponent];
	if (MiSegReverseDrum==1 && bDramRevers) {
		//bDramRevers = NO;  [Copy]後、遡った行が維持されるようにリマークした
		NSInteger iRow = [ibPicker selectedRowInComponent:entryComponent]; // 現在の選択行
		if (0 <= iRow && iRow < [drum count]) 
		{	// ドラム逆回転やりなおしモード ⇒ formulaとentryを選択行まで戻す
			// 遡った行の数値を「数値文字化」して copy autorelese object として保持する。
			zCopyNumber = stringAzNum([drum.formulaNumbers objectAtIndex:iRow]);
			//
			switch (button.tag) {
				case KeyTAG_ANSWER:	// [=]
				case KeyTAG_PLUS:	// [+]
				case KeyTAG_MINUS:	// [-]
				case KeyTAG_MULTI:	// [×]
				case KeyTAG_DIVID:	// [÷]
					// 上記の演算子ボタンがが押されたときだけ、遡った行以降の範囲削除
					if ([[drum.formulaOperators objectAtIndex:iRow] hasPrefix:OP_START]) {
						[drum.entryOperator setString:OP_START];
					} else {
						[drum.entryOperator setString:@""];
					}
					//
					NSRange range = NSMakeRange(iRow, [drum count] - iRow);
					[drum.formulaOperators removeObjectsInRange:range];
					[drum.formulaNumbers removeObjectsInRange:range];		
					[drum.formulaUnits removeObjectsInRange:range]; //BugFix!これが抜けていたために[Drum vNewLine]にてassertエラー発生した。
					// entry値クリア
					[drum.entryNumber setString:@""]; 
					[drum.entryAnswer setString:@""]; 
					break;
			}
		}
	}
	
	// entry行より下が選択されても、通常通りentry行入力にする。 
	// [=]の後に数値キー入力すると改行(新セクション)になる。
	
	// キー入力処理   先に if (button.tag < 0) return; 処理済み
	if (button.tag <= KeyTAG_STANDARD_End) { //[KeyTAG_STANDARD_Start-KeyTAG_STANDARD_End]---------Standard Keys
		[drum entryKeyTag:button.tag keyButton:button];
	} 
	else if (button.tag <= KeyTAG_MEMORY_End) { //[KeyTAG_MEMORY_Start-KeyTAG_MEMORY_End]----------Memory Keys
		switch (button.tag) {
			case KeyTAG_MCLEAR: // [MClear]
				if (0 < [[UIPasteboard generalPasteboard].string length]) {
					[UIPasteboard generalPasteboard].string = @"";
				} 
				else if (![drum.entryOperator hasPrefix:OP_ANS]) { // [=]でない
					[drum.entryNumber setString:@""];
				}
				if (KeyTAG_MSTORE_Start <= ibBuMemory.tag && ibBuMemory.tag <= KeyTAG_MSTROE_End) {
					// MemoryKey へ登録する
					NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu = (KeyButton *)obj;
							if (bu.tag == ibBuMemory.tag) {
								//bu.titleLabel.text = [NSString stringWithFormat:@"M%d", (int)(bu.tag - 350)];
								[bu setTitle:[NSString stringWithFormat:@"M%d", (int)(bu.tag - KeyTAG_MSTORE_Start)]
									forState:UIControlStateNormal];
								bu.alpha = KeyALPHA_MSTORE_OFF; // Memory nothing
								//2個以上連結しているため最後まで調べて全て更新する
							}
						}
					}
					if (aPadKeyButtons) { // iPad専用メモリーもクリアする
						for (KeyButton *bu in aPadKeyButtons) {
							if (bu.tag == ibBuMemory.tag) {
								[bu setTitle:[NSString stringWithFormat:@"M%d", (int)(bu.tag - KeyTAG_MSTORE_Start)]
									forState:UIControlStateNormal];
								bu.alpha = KeyALPHA_MSTORE_OFF; // Memory nothing
								//break; 同じキーが複数割り当てられている可能性があるので最後までいく
							}
						}
					} else {
						[self vKeyboardPage1Alook0]; // iPhoneのときだけ「しゃくる」
					}
					ibBuMemory.tag = 0; // MClear
				}
				break;
				
			case KeyTAG_MCOPY: // [Copy]  ＜＜同じ値を続けて登録することも可とした＞＞
				if (0 < [zCopyNumber length]) {
					// ドラムを逆回転させた行の数値 zCopyNumber が有効ならば優先コピー
					[UIPasteboard generalPasteboard].string = stringFormatter(zCopyNumber, YES);
					bDrumRefresh = NO; // =NO:[Copy]後などドラムを動かしたくないとき
				}
				else if (0 < [drum.entryNumber length]) {
					// entry値をコピーする　　＜＜stringFormatterを通すため、Mutable ⇒ NSString 変換が必要＞＞
					NSString *zNum = stringFormatter([NSString stringWithString:drum.entryNumber], YES);
					[UIPasteboard generalPasteboard].string = zNum;
				}
				else break;
				//
				if (0 < [[UIPasteboard generalPasteboard].string length]) {
					// [UIPasteboard generalPasteboard].string を 未使用メモリーKey へ登録する
					ibBuMemory.tag = 0; // MClear
					NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
					NSInteger iSavedTag = (-1);

					if (aPadKeyButtons) { // iPad専用メモリー優先にセットする　＜＜たいていiPhoneメモリ数より多いから＞＞
						for (KeyButton *bu in aPadKeyButtons) {
							if ([bu.titleLabel.text hasPrefix:@"M"]) { // 未使用メモリを探す
								iSavedTag = bu.tag;  // 未使用メモリ発見
								// アニメーション
								{
									CGRect rcEnd = bu.frame; // 最終位置
									UIButton *buEntry = [aDrumButtons objectAtIndex:entryComponent];
									CGRect rc = buEntry.frame; // 開始位置
									rc.origin.x += (rc.size.width - bu.frame.size.width);
									bu.frame = rc;
									// アニメ準備
									[UIView beginAnimations:nil context:NULL];
									[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
									[UIView setAnimationDuration:0.7];
									// アニメ終了時の位置をセット
									bu.frame = rcEnd;
									// アニメ開始
									[UIView commitAnimations];
								}
								break;
							}
						}
					}
					
					if (iSavedTag < 0) { // iPad専用メモリーになければKeybord上を探す
						for (NSInteger iTag=KeyTAG_MSTORE_Start; iTag<=KeyTAG_MSTROE_End && iSavedTag<0; iTag++) {
							for (id obj in aKeys) {
								if ([obj isMemberOfClass:[KeyButton class]]) {
									KeyButton *bu = (KeyButton *)obj;
									if (bu.tag == iTag) {
										if ([bu.titleLabel.text hasPrefix:@"M"]) {
											iSavedTag = bu.tag;  // 未使用メモリ発見
											break;
										}
									}
								}
							}
						}
					}
					if (iSavedTag < 0) {
						AzLOG(@"Memory Key Fill.");
						break;
					}
					// コピー先を記録
					ibBuMemory.tag = iSavedTag; // コピー完了
					// 未使用メモリにコピーする
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu = (KeyButton *)obj;
							if (bu.tag == iSavedTag) {
								[bu setTitle:[UIPasteboard generalPasteboard].string
									forState:UIControlStateNormal];
								bu.alpha = KeyALPHA_MSTORE_ON; // Memory OK
								//break; 2個以上連結しているため最後まで調べて全て更新する
							}
						}
					}
					if (aPadKeyButtons) { // iPad専用メモリーにセットする
						for (KeyButton *bu in aPadKeyButtons) {
							if (bu.tag == iSavedTag) {
								[bu setTitle:[UIPasteboard generalPasteboard].string
									forState:UIControlStateNormal];
								bu.alpha = KeyALPHA_MSTORE_ON; // Memory OK
								//break; 2個以上連結しているため最後まで調べて全て更新する
							}
						}
					} else {
						[self vKeyboardPage1Alook0]; // iPhoneのときだけ「しゃくる」
					}
				}
				break;
				
			case KeyTAG_MPASTE: { // [Paste]　　＜＜ibBuMemoryから呼び出しているので.tagの変更に注意＞＞
				if ([drum.entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
					if (![drum vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
				}
				NSString *str = stringAzNum([UIPasteboard generalPasteboard].string);
				[drum.entryNumber setString:str]; // Az数値文字列をセット
				// アニメーション不要
			}	break;
				
			case KeyTAG_M_PLUS: // [M+]
			case KeyTAG_M_MINUS: // [M-]
			case KeyTAG_M_MULTI: // [M×]
			case KeyTAG_M_DIVID: // [M÷]
				AzLOG(@"entryOperator=[%@]", drum.entryOperator);
				if (0 < [zCopyNumber length]) {
					// ドラムを逆回転させた行の数値 zCopyNumber が有効
					bDrumRefresh = NO; // =NO:[Copy]後などドラムを動かしたくないとき
				}
				else if ([drum.entryOperator isEqualToString:OP_ANS] && [drum.entryNumber doubleValue]!=0.0) {
					// OK : entryNumber
					zCopyNumber = [NSString stringWithString:drum.entryNumber];
				}
				else if ([drum.entryOperator isEqualToString:@""] OR [drum.entryOperator isEqualToString:OP_START]) {
					// [][>]であれば、OK : entryNumber
					zCopyNumber = [NSString stringWithString:drum.entryNumber];
				}
				else {
					if (![drum.entryOperator isEqualToString:OP_ANS] && [drum.entryNumber doubleValue]!=0.0) {
						// 演算中　entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
						[drum vCalcing:OP_ANS];
					} else {
						// 計算処理する
						[drum.entryOperator setString:OP_ANS];
						// entry行に、この[=]が入るので、数値部に計算結果を入れる
						[drum.entryNumber setString:[drum zAnswerDrum]]; 
					}
					zCopyNumber = [NSString stringWithString:drum.entryNumber];
				}
				// 0でなければそれを Ｍ−＋ する
				//if ([drum.entryNumber doubleValue] != 0.0) {
				if ([zCopyNumber doubleValue] != 0.0) 
				{
					NSString *zMem = stringAzNum([UIPasteboard generalPasteboard].string);
					char cNum1[SBCD_PRECISION+100];
					char cNum2[SBCD_PRECISION+100];
					char cAns[SBCD_PRECISION+100];
					sprintf(cNum1, "%s", (char *)[zMem cStringUsingEncoding:NSASCIIStringEncoding]); 
					sprintf(cNum2, "%s", (char *)[zCopyNumber cStringUsingEncoding:NSASCIIStringEncoding]); 
					switch (button.tag) {
						case KeyTAG_M_PLUS: // [M+]
							stringAddition( cAns, cNum1, cNum2 );
							break;
						case KeyTAG_M_MINUS: // [M-]
							stringSubtract( cAns, cNum1, cNum2 );
							break;
						case KeyTAG_M_MULTI: // [M×]
							stringMultiply( cAns, cNum1, cNum2 );
							break;
						case KeyTAG_M_DIVID: // [M÷]
							stringDivision( cAns, cNum1, cNum2 );
							break;
						default:
							exit(-1); // iKeyTag 番号まちがい
							break;
					}
					NSString *zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
					if ([zAns hasPrefix:@"@"]) {
						if ([zAns hasPrefix:@"@0"]) {
							[UIPasteboard generalPasteboard].string = NSLocalizedString(@"@Divide by zero", nil);
						} else {
							[UIPasteboard generalPasteboard].string = zAns; // ERROR
						}
					} 
					else {
						// 丸め処理
						char cNum[SBCD_PRECISION+100];
						char cAns[SBCD_PRECISION+100];
						strcpy(cNum, (char *)[zAns cStringUsingEncoding:NSASCIIStringEncoding]); 
						stringRounding( cAns, cNum, PRECISION, MiSegDecimal, MiSegRound );
						AzLOG(@"BCD> stringRounding() cAns=%s", cAns);
						zAns = [NSString stringWithCString:(char *)cAns encoding:NSASCIIStringEncoding];
						// ペーストボードへ
						[UIPasteboard generalPasteboard].string = stringFormatter(zAns, YES);
						if (KeyTAG_MSTORE_Start <= ibBuMemory.tag && ibBuMemory.tag <= KeyTAG_MSTROE_End) {
							// MemoryKey へ登録する
							if (aPadKeyButtons) { // iPad専用メモリー優先にセットする　＜＜たいていiPhoneメモリ数より多いから＞＞
								for (KeyButton *bu in aPadKeyButtons) {
									if (bu.tag == ibBuMemory.tag) {
										[bu setTitle:[UIPasteboard generalPasteboard].string
											forState:UIControlStateNormal];
										//2個以上連結しているため最後まで調べて全て更新する
									}
								}
							}
							NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
							for (id obj in aKeys) {
								if ([obj isMemberOfClass:[KeyButton class]]) {
									KeyButton *bu = (KeyButton *)obj;
									if (bu.tag == ibBuMemory.tag) {
										[bu setTitle:[UIPasteboard generalPasteboard].string
											forState:UIControlStateNormal];
										//2個以上連結しているため最後まで調べて全て更新する
									}
								}
							}
						}
					}
				}
				break;
		}
	}
	else if (button.tag <= KeyTAG_MSTROE_End) { //[KeyTAG_MSTORE_Start-KeyTAG_MSTROE_End]-------Memory STORE Keys
		if (button && ![button.titleLabel.text hasPrefix:@"M"]) {
			// "M"でない。 メモリ値有効 ⇒ ペーストボードへ
			[UIPasteboard generalPasteboard].string = button.titleLabel.text;
			ibBuMemory.tag = button.tag;
			// [Paste]
			if ([drum.entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
				// entryをarrayに追加し、entryを新規作成する
				if ([drum vNewLine:OP_START]==NO) return; // ERROR
			}
			NSString *str = stringAzNum([UIPasteboard generalPasteboard].string);
			[drum.entryNumber setString:str]; // Az数値文字列をセット
			// アニメーション：他のボタン同様にentryに際してはアニメなし
		}
	}
/*	else if (KeyTAG_UNIT_Start <= button.tag) { //[KeyTAG_UNIT_Start-KeyTAG_UNIT_End]--------------Unit Keys
		if (button.tag <= 1099) { // [1000-1099]/100=(10)長さ
			
		}
		else if (button.tag <= 1199) { // [1100-1199]/100=(11)面積
			
		}
		else if (button.tag <= 1299) { // [1200-1299]/100=(12)体積
			
		}
		else if (button.tag <= 1399) { // [1300-1399]/100=(13)質量
			
		}
		else if (button.tag <= 1499) { // [1400-1499]/100=(14)角度
			
		}
		else if (button.tag <= 1599) { // [1500-1599]/100=(15)時間
			
		}
		else if (button.tag <= 1699) { // [1600-1699]/100=(16)速度
			
		}
		else if (button.tag <= 1799) { // [1700-1799]/100=(17)温度
			
		}
	}*/

/*Option選択にするか改めて検討	
	// 常にキーボードの1ページを表示する
	[self vKeyboardPage:1]; // キー1ページへ
*/
	if (bDrumRefresh) { // ドラム再表示
		[ibPicker reloadComponent:entryComponent];
		[ibPicker selectRow:[drum count] inComponent:entryComponent animated:YES];
	}
	// [M]ラベル表示
	[self ibBuMemoryDisplay];

	// iAd
	if (NSClassFromString(@"ADBannerView")) {
		if (button.tag==KeyTAG_AC) { // [AC]
			[self iAdOn];
		} else {
			[self iAdOff];
		}
	}
}

- (void)vMemorySave
{	// [M]メモリボタンや[PB]ボタン を standardUserDefaults へ保存する
	NSMutableDictionary *mdMk = [NSMutableDictionary new];
	if (aPadKeyButtons) { // iPad専用メモリー優先　＜＜たいていiPhoneメモリ数より多いから＞＞
		for (KeyButton *bu in aPadKeyButtons) {
			//NSNumber *num = [NSNumber numberWithInteger:bu.tag];
			NSString *zTag = [NSString stringWithFormat:@"%ld", (long)bu.tag]; // forKey:文字列のみ
			if ([mdMk objectForKey:zTag]==nil) { // なければ追加、あればパス
				// Add
				[mdMk setObject:bu.titleLabel.text forKey:zTag];
			}
		}
	}
	// 主にiPhone 初期の0ページにあるメモリボタンを保存
	NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
	for (id obj in aKeys) {  // どこに配置されているか解らないので全て探す
		if ([obj isMemberOfClass:[KeyButton class]]) {
			KeyButton *bu = (KeyButton *)obj;
			if (KeyTAG_MSTORE_Start<=bu.tag && bu.tag<=KeyTAG_MSTROE_End) {
				NSString *zTag = [NSString stringWithFormat:@"%ld", (long)bu.tag];
				if ([mdMk objectForKey:zTag]==nil) { // なければ追加、あればパス
					// Add
					[mdMk setObject:bu.titleLabel.text forKey:zTag];
				}
			}
		}
	}
	// [PB]ペーストボード（画面中央に出入りする）ボタンを保存
	if (KeyTAG_MSTORE_Start <= ibBuMemory.tag) {
		[mdMk setObject:[NSNumber numberWithInteger:ibBuMemory.tag]  forKey:@"PB_TAG"];
		[mdMk setObject:[UIPasteboard generalPasteboard].string  forKey:@"PB_TEXT"];
	}
	// Keyboard ページ保存
	[mdMk setObject:[NSNumber numberWithInteger:MiScrollViewPage]  forKey:@"KB_PAGE"];
	
	// SAVE
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	[userDef setObject:mdMk forKey:GUD_KeyMemorys];
	//if ([userDef synchronize] != YES) { // file write
	//	AzLOG(@"GUD_KeyMemorys synchronize: ERROR");
	//}
	[mdMk release];	//mdMk = nil;
}

- (void)vMemoryLoad
{	// [M]メモリボタンや[PB]ボタン を standardUserDefaults から復帰させる
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	// standardUserDefaults からキー配置読み込む
	NSDictionary *dicMkeys = [userDef dictionaryForKey:GUD_KeyMemorys];
	NSString *str;
	str = [dicMkeys objectForKey:@"PB_TEXT"];
	if (str==nil OR ![str isEqualToString:[UIPasteboard generalPasteboard].string]) {
		// generalPasteboardの値を表示
		ibBuMemory.tag = 0;
		ibBuMemory.titleLabel.text = [NSString stringWithFormat:@"PB  %@", 
									  stringFormatter(stringAzNum([UIPasteboard generalPasteboard].string), YES)];
	}
	else {
		NSNumber *num = [dicMkeys objectForKey:@"PB_TAG"];
		if (num) {
			ibBuMemory.tag = [num integerValue];
			// [UIPasteboard generalPasteboard].string そのまま表示
		} else {
			ibBuMemory.tag = 0;
			[UIPasteboard generalPasteboard].string = @"";
		}
	}
	//
	if (aPadKeyButtons) { // iPad専用メモリー優先　＜＜たいていiPhoneメモリ数より多いから＞＞
		for (KeyButton *bu in aPadKeyButtons) {
			//NSNumber *num = [NSNumber numberWithInteger:bu.tag];
			NSString *zTag = [NSString stringWithFormat:@"%ld", (long)bu.tag]; // forKey:文字列のみ
			NSString *str = [dicMkeys objectForKey:zTag];
			if (str) {
				[bu setTitle:str forState:UIControlStateNormal];
				if ([str hasPrefix:@"M"]) {
					bu.alpha = KeyALPHA_MSTORE_OFF;
				} else {
					bu.alpha = KeyALPHA_MSTORE_ON;
				}
			}
		}
	}
	// 主にiPhone 初期の0ページにあるメモリボタンを保存
	NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
	for (id obj in aKeys) {  // どこに配置されているか解らないので全て探す
		if ([obj isMemberOfClass:[KeyButton class]]) {
			KeyButton *bu = (KeyButton *)obj;
			if (KeyTAG_MSTORE_Start<=bu.tag && bu.tag<=KeyTAG_MSTROE_End) {
				NSString *zTag = [NSString stringWithFormat:@"%ld", (long)bu.tag]; // forKey:文字列のみ
				NSString *str = [dicMkeys objectForKey:zTag];
				if (str) {
					[bu setTitle:str forState:UIControlStateNormal];
					if ([str hasPrefix:@"M"]) {
						bu.alpha = KeyALPHA_MSTORE_OFF;
					} else {
						bu.alpha = KeyALPHA_MSTORE_ON;
					}
				}
			}
		}
	}
	// ibBuMemory表示
	[self ibBuMemoryDisplay];
	// Keyboard ページ復帰
	{
		NSNumber *num = [dicMkeys objectForKey:@"KB_PAGE"];
		if (num && 0<=[num integerValue]) {
			MiScrollViewPage = [num integerValue];
			CGRect rc = ibScrollLower.frame;
			rc.origin.x = rc.size.width * MiScrollViewPage;
			[ibScrollLower scrollRectToVisible:rc animated:NO];
		} else {
			MiScrollViewPage = 1; // DEFAULT PAGE
		}
	}
}

// ibScrollLower DELEGATE:実際に画面が静止したときに呼ばれる
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    MiScrollViewPage = (NSInteger)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
}

- (void)vKeyboardPage:(NSInteger)iPage
{
	//if (ibScrollLower.frame.origin.x / ibScrollLower.frame.size.width == iPage) return; // 既にiPageである。
	CGRect rc = ibScrollLower.frame;
	rc.origin.x = rc.size.width * iPage;
	[ibScrollLower scrollRectToVisible:rc animated:YES];
}

- (void)vKeyboardPage1Alook0 // 1ページから0ページを「ちょっと見せる」アニメーション
{
	//AzLOG(@"ibScrollLower: x=%f w=%f", ibScrollLower.frame.origin.x, ibScrollLower.frame.size.width);
	//if (ibScrollLower.  .frame.origin.x / ibScrollLower.frame.size.width != 1) return; // 1ページ限定
	CGRect rc = ibScrollLower.frame;
	rc.origin.x = rc.size.width - 17; // 0Page方向へ「ちょっと見せる」だけ戻す
	[ibScrollLower scrollRectToVisible:rc animated:NO];
	rc.origin.x = rc.size.width * 1; // 1Pageに復帰
	[ibScrollLower scrollRectToVisible:rc animated:YES];
}

- (void)vPadKeysDisplay // iPad専用 メモリー20キー配置 および 回転処理
{
	assert(700 < self.view.frame.size.height); // iPad
	
	if (aPadKeyButtons==nil) {
		// 生成
		NSMutableArray *maBus = [NSMutableArray new];
		for (int i=0; i<15; i++) 
		{
			//UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
			KeyButton *bu = [[KeyButton alloc] initWithFrame:CGRectZero];
			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-DrumPush.png"] forState:UIControlStateHighlighted];
			bu.iPage = 9;
			bu.iCol = 0;
			bu.iRow = 0;
			bu.bDirty = NO;
			bu.alpha = KeyALPHA_MSTORE_OFF;
			bu.tag = KeyTAG_MSTORE_Start + 1 + i;
			[bu setTitle:[NSString stringWithFormat:@"M%d", (int)1+i] forState:UIControlStateNormal];
			bu.titleLabel.font = [UIFont boldSystemFontOfSize:26];
			[bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
			[bu addTarget:self action:@selector(ibButton:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:bu];
			[maBus addObject:bu];
		}
		aPadKeyButtons = [[NSArray alloc] initWithArray:maBus];
		[maBus release];
	}
	
	// 回転移動
	CGRect rc = CGRectMake(0,0, 256-8*2, 49.8-5*2);
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		// ヨコ ⇒ W254 H748 縦20行1列表示
		rc.origin.x = 768 + 8;
		rc.origin.y = 5;
		for (UIButton *bu in aPadKeyButtons) {
			bu.frame = rc;
			rc.origin.y += 49.8;
		}
	}
	else {
		// タテ ⇒ W768 H256 縦7行3列表示
		rc.origin.x = 8;
		rc.origin.y = 5;
		for (UIButton *bu in aPadKeyButtons) {
			bu.frame = rc;
			rc.origin.y += 49.8;
			if (250 < rc.origin.y) {
				rc.origin.x += 256;
				rc.origin.y = 5;
			}
		}
	}
}


- (void)vPickerRefresh
{
	[ibPicker reloadComponent:1]; // 1つ前になる？？
	[ibPicker reloadComponent:2];
}

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	//AzLOG(@"=== bannerViewDidLoadAd ===");
	bADbannerIsVisible = YES; // iAd取得成功（広告内容あり）
	
	if (bADbannerFirstTime) {  // 起動時に1回だけ表示するため
		bADbannerFirstTime = NO;
		[self iAdOn];
	}
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	AzLOG(@"=== didFailToReceiveAdWithError ===");
	bADbannerIsVisible = NO; // iAd取得失敗（広告内容なし）
	[self iAdOff];
}

- (void)iAdOn
{
	//AzLOG(@"=== iAdOn ===");
	if (!NSClassFromString(@"ADBannerView")) return;
	if (ibADBannerView==nil) return;
	if (bADbannerIsVisible==NO) return; // 内容ないので表示しない ＜＜しばらく後、内容が無くなっている場合もある＞＞
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:3.0];
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) { // ヨコ
	//	ibADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
	//	ibADBannerView.frame = CGRectMake(0, 320 - 32, 0,0);
	} else {
		ibADBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		ibADBannerView.frame = CGRectMake(0,0, 0,0);
	}

	[UIView commitAnimations];
}

- (void)iAdOff
{
	AzLOG(@"=== iAdOff ===");
	if (!NSClassFromString(@"ADBannerView")) return;
	if (ibADBannerView==nil) return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	CGRect theBannerFrame = self.view.frame;
	theBannerFrame.origin.y = -52;  // viewの外へ出す
	ibADBannerView.frame = theBannerFrame;	
	
	[UIView commitAnimations];
}


//----------------------------------------------------------------Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:ibScrollLower];
	AzLOG(@"---touchesBegan:(%f, %f)", po.x, po.y);
	
	
//	[self.nextResponder touchesBegan:touches withEvent:event]; // ibPickerへ受け流す
/*	CGPoint po = [[touches anyObject] locationInView:self.view];
	
	if (CGRectContainsPoint(ibPicker.frame, po)) { // ドラム内をタッチした
		assert(0 <= MiSegDrums);
		float fSpan = (ibPicker.frame.size.width - DRUM_LEFT_OFFSET*2) / (float)(1 + MiSegDrums);
		int iComponent = (int)floor((po.x - 14.0) / fSpan);
		if (iComponent < 0 OR MiSegDrums < iComponent) return;
		entryComponent = iComponent;
		// ドラムアクティブカーソル表示
		[self vDrumButtonDisplay];
		//
		NSInteger iRow = [ibPicker selectedRowInComponent:entryComponent];
		[ibPicker selectRow:iRow+1 inComponent:entryComponent animated:NO];
		[ibPicker selectRow:iRow inComponent:entryComponent animated:YES];
	}*/
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:ibScrollLower];
	AzLOG(@"---touchesMoved:(%f, %f)", po.x, po.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:ibScrollLower];
	AzLOG(@"---touchesEnded:(%f, %f)", po.x, po.y);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint po = [[touches anyObject] locationInView:ibScrollLower];
	AzLOG(@"--------------touchesCancelled:(%f, %f)", po.x, po.y);
}


@end








