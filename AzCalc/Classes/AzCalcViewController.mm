//
//  AzCalcViewController.m
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <TargetConditionals.h>  // TARGET_IPHONE_SIMULATOR のため
#import "Global.h"
#import "CalcFunctions.h"
#import "Drum.h"
#import "AzCalcViewController.h"
#import "SettingVC.h"
#import "OptionVC.h"
#import "InformationVC.h"
#import "KeyButton.h"


#define	DRUMS_MAX				5		// この数のDrumsオブジェクトを常に生成する
#define	PICKER_COMPONENT_WiMIN	40		// 1コンポーネントの表示最小幅

#define DRUM_LEFT_OFFSET		11.0	// ドラム左側の余白（右側も同じになるようにする）
#define DRUM_GAP				 2.0	// ドラム幅指定との差
#define DRUM_FONT_MAX			27.0	// 数式表示フォントサイズの最大
#define DRUM_FONT_MSG			24.0	// メッセージ表示フォントサイズ
#define DRUM_FONT_MIN			 6.0	// 数式表示フォントサイズの最小

#define ROWOFFSET				2
#define DECIMALMAX				12
#define GOLDENPER				1.618	// 黄金比

#define MINUS_SIGN				@"−"	// Unicode[2212] 表示用文字　[002D]より大きくするため
#define FORMULA_BLANK			@"〓 "	// Formula calc が空のとき表示するメッセージの先頭文字（判定に使用）

#define PAGES		100		// 2の倍数　＜＜瞬間移動！錯覚により、あまり大きくする必要が無くなった。


// Tags
//没//#define TAG_DrumButton_LABEL		109

/* Apple審査拒絶「仕様禁止メソッド」
@interface UIPickerView (Mute)
-(void) setSoundsEnabled:(BOOL)enabled;
@end
*/

//================================================================================AzCalcViewController
@interface AzCalcViewController (PrivateMethods)
- (void)MvDrumButtonShow;
- (void)MvMemoryShow;
- (void)MvFormulaBlankMessage:(BOOL)bBlank;
- (void)MvPadKeysShow;
- (void)MvKeyUnitGroupSI;
- (void)MvKeyUnitGroup:(KeyButton *)keyUnit;
- (void)MvKeyboardPage:(NSInteger)iPage;
- (void)MvDrumButtonTouchUp:(UIButton *)button;
- (void)MvDrumButtonDragEnter:(UIButton *)button;
- (void)MvSaveKeyView:(UIView*)keyView;
- (void)audioPlayer:(NSString*)filename;
@end

@implementation AzCalcViewController


#pragma mark - View dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease ---");
	ibScrollUpper.delegate = nil;
	ibPvDrum.delegate = nil;
	ibPvDrum.dataSource = nil;
	ibTvFormula.delegate = nil;
	
#ifdef GD_Ad_ENABLED
	NSLog(@"--- retainCount: RiAdBanner=%d", [RiAdBanner retainCount]);
	if (RiAdBanner) {
		[RiAdBanner cancelBannerViewAction];	// 停止
		RiAdBanner.delegate = nil;							// 解放メソッドを呼び出さないように　　　[0.4.1]メモリ不足時に落ちた原因
		[RiAdBanner removeFromSuperview];		// UIView解放		retainCount -1
		[RiAdBanner release], RiAdBanner = nil;	// alloc解放			retainCount -1
	}

	NSLog(@"--- retainCount: RiAdBanner=%d", [RiAdBanner retainCount]);
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;  //[0.4.20]受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		[RoAdMobView release], RoAdMobView = nil;
	}
#endif

	[RaPadKeyButtons release],	RaPadKeyButtons = nil;
	[RaKeyMaster release],			RaKeyMaster = nil;
	[RdicAllKeys release],				RdicAllKeys = nil;
	[RaDrumButtons release],		RaDrumButtons = nil;
	// RaDrums は破棄しない（ドラム記録を消さないため）deallocではreleaseすること。
	
	//[0.4.1]//"Received memory warning. Level=2" 回避するため一元化
	[RimgDrumButton release],	RimgDrumButton = nil;
	[RimgDrumPush release],		RimgDrumPush = nil;
	//不要//[mKeyView release], mKeyView = nil;
}

- (void)dealloc 
{
	NSLog(@"--- dealloc ---");
	[self unloadRelease];
	
	[mGvKeyUnitSI release];
	[mGvKeyUnitSi2 release];
	[mGvKeyUnitSi3 release];

	[RaDrums release];
    [super dealloc];
}

// MARK: 終了処理

- (void)viewWillDisappear:(BOOL)animated // 非表示になる直前にコールされる
{
	[super viewWillDisappear:animated];
	
	/*
	 if (buChangeKey) {
		//buChangeKey.backgroundColor = [UIColor clearColor]; // 前選択を戻す
		// 復帰
		[buChangeKey setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
		buChangeKey = nil;
	}*/
}

// 裏画面(非表示)状態のときにメモリ不足が発生するとコールされるので、viewDidLoadで生成したOBJを解放する
- (void)viewDidUnload
{
	NSLog(@"--- viewDidUnload ---");
	//NSLog(@"--- retainCount: RiAdBanner=%d", [RiAdBanner retainCount]);
	NSLog(@"--- retainCount: ibScrollLower=%d", [ibScrollLower retainCount]);
	
	[self unloadRelease];
	[super viewDidUnload];		// この後、viewDidLoadがコールされて、改めてOBJ生成される
}


#pragma mark - View lifecicle

- (void)drawKeyboard:(UIView*)view page:(NSInteger)page
{
	assert(view);
	//float fx = ibScrollLower.frame.size.width * page + fKeyWidGap;
	//float fx = ibScrollLower.frame.size.width * (1 + page) + fKeyWidGap;  // 先頭ブランクページを飛ばすため
	float fx = fKeyWidGap;
	for (int col=0; col<iKeyCols && col<100; col++ ) 
	{
		float fy = fKeyHeiGap;
		//KeyButton *buPrev = nil;	// タテ結合処理：直上ボタン
		for (int row=0; row<iKeyRows && row<100; row++ ) 
		{
			KeyButton *bu = [[KeyButton alloc] initWithFrame:CGRectMake(fx,fy, fKeyWidth,fKeyHeight)];
			[bu setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
			[bu setBackgroundImage:RimgDrumPush forState:UIControlStateHighlighted];
			bu.iPage = page;
			bu.iCol = iKeyOffsetCol + col;
			bu.iRow = iKeyOffsetRow + row;
			bu.bDirty = NO;
			NSString *zPCR = [[NSString alloc] initWithFormat:@"P%dC%dR%d", (int)bu.iPage, (int)bu.iCol, (int)bu.iRow];
			NSDictionary *dicKey = [RdicAllKeys objectForKey:zPCR];
			
			if (dicKey) {
				//NSDictionary *dicMaster = nil;
				bu.tag = [[dicKey objectForKey:@"Tag"] integerValue]; // Function No.

				NSString *strText = [dicKey objectForKey:@"Text"];
				NSNumber *numSize = [dicKey objectForKey:@"Size"];
				NSNumber *numColor = [dicKey objectForKey:@"Color"];
				NSNumber *numAlpha = [dicKey objectForKey:@"Alpha"];
				// UNIT
				NSString *strUnit = [dicKey objectForKey:@"Unit"];
				
				if (strText==nil 
					OR numSize==nil 
					OR numAlpha==nil 
					OR numColor==nil 
					OR strUnit==nil) 
				{	// 通常は通らない。　将来、Master属性が増えたときに通る可能性あり。
					// AzKeyMaster 引用
					if (RaKeyMaster==nil) { // AzKeyMaster.plistからマスターキー一覧読み込む
						NSString *zFile = [[NSBundle mainBundle] pathForResource:@"AzKeyMaster" ofType:@"plist"];
						RaKeyMaster = [[NSArray alloc] initWithContentsOfFile:zFile];
						if (RaKeyMaster==nil) {
							AzLOG(@"ERROR: AzKeyMaster.plist not Open");
							exit(-1);
						}
					}
					
					strText = nil;
					for (NSArray *aComponent in RaKeyMaster) {
						for (NSDictionary *dic in aComponent) {
							if ([[dic objectForKey:@"Tag"] integerValue] == bu.tag) {
								strText = [dic objectForKey:@"Text"];
								numSize = [dic objectForKey:@"Size"];
								numColor = [dic objectForKey:@"Color"];
								numAlpha = [dic objectForKey:@"Alpha"];
								strUnit = [dic objectForKey:@"Unit"];
								// 将来、属性が増えれば、ここへ追加することになる。
								break;
							}
						}
						if (strText) break; // レス向上のため
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
						case 4:	[bu setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];	break; // UNIT
						default:
							[bu setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];	
							bu.userInteractionEnabled = NO;	//.enabled=NOにすると薄い線が見える
							break;
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
				
				// UNIT
				if (bu.tag==1313) {	//Patch//[0.4.1]//bbl=1.58987294928㎥⇒NG⇒0.158987294928㎥
					bu.RzUnit = @"㎥;(#*0.158987294928);(#/0.158987294928)";
				} else if (bu.tag==1310) {	//Patch//[0.4.1]//cuin=0.016387064㎥⇒NG⇒0.000016387064㎥
					bu.RzUnit = @"㎥;(#*0.000016387064);(#/0.000016387064)";
				} else {
					bu.RzUnit = strUnit;
				}
			}
			else {
				bu.tag = -1; // Function No.
				//bu.titleLabel.text = @" "; // = nill ダメ  Space1
				[bu setTitle:@" " forState:UIControlStateNormal]; // = nill ダメ  Space1
#ifdef AzMAKE_SPLASHFACE
				bu.alpha = 0.4;
#else
				bu.alpha = KeyALPHA_DEFAULT_OFF;
#endif
			}
			
			// 上と右のマージンが自動調整されるように。つまり、左下基点になる。
			bu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin; 
			[bu addTarget:self action:@selector(ibButton:) forControlEvents:UIControlEventTouchUpInside];	
			// UIControlEventTouchDown OR UIControlEventTouchUpInside
			
			// タテヨコ連結処理は、viewWillAppearで処理されるので、ここでは不要
			
			//[ibScrollLower addSubview:bu];
			[view addSubview:bu];
			[bu release]; // init だから
			[zPCR release];
			
			fy += (fKeyHeight + fKeyHeiGap*2);
		}
		fx += (fKeyWidth + fKeyWidGap*2);
	}
	
	// ボタン生成後の「キー連結」処理

	//AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (mAppDelegate.bChangeKeyboard) {
		// キーレイアウト変更モード
		ibScrollUpper.scrollEnabled = NO; // レイアウト中は固定する
		if (RaKeyMaster==nil) {
			// AzKeyMaster.plistからマスターキー一覧読み込む
			NSString *zFile = [[NSBundle mainBundle] pathForResource:@"AzKeyMaster" ofType:@"plist"];
			RaKeyMaster = [[NSArray alloc] initWithContentsOfFile:zFile];
			if (RaKeyMaster==nil) {
				AzLOG(@"ERROR: AzKeyMaster.plist not Open");
				exit(-1);
			}
			//buChangeKey = nil;
		}
		
		for (UIButton *bu in RaDrumButtons) {
			bu.hidden = YES;
		}
		
		ibBuMemory.hidden = YES;
		ibLbEntry.hidden = YES;
		ibPvDrum.showsSelectionIndicator = YES;
		[ibPvDrum reloadAllComponents];
		// 全ドラム選択行を0にする
		for (int i=0; i<[RaKeyMaster count]; i++) {
			[ibPvDrum selectRow:0 inComponent:i animated:NO];
		}
		
		// キー再表示：連結されたキーがあれば独立させる
		//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
		NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
		for (id obj in aKeys) {
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				// 連結されたボタンを全て最小独立表示する  [0.3]右および下のボタンを生かすようになったため修正
				if (bu.frame.size.width != fKeyWidth OR bu.frame.size.height != fKeyHeight) {
					CGRect rc = bu.frame;
					rc.origin.x += (rc.size.width - fKeyWidth);		//[0.3]連結された右端のボタンになる
					rc.origin.y += (rc.size.height - fKeyHeight);	//[0.3]連結された下端のボタンになる
					rc.size.width = fKeyWidth;
					rc.size.height = fKeyHeight;
					bu.frame = rc;
				}
				if (bu.hidden) {
					bu.hidden = NO;
				}
				bu.userInteractionEnabled = YES; // 単位キーで無効にされている場合、解除するため
			}
		}
#ifdef GD_Ad_ENABLED
		// キーレイアウト変更モードでは常時ＯＦＦ
		[self MvShowAdApple:NO AdMob:NO];
#endif
	} 
	else {
		// ドラタク通常モード
		ibScrollUpper.scrollEnabled = YES;
		if (RaKeyMaster) {
			[RaKeyMaster release];
			RaKeyMaster = nil;
		}
		ibBuMemory.hidden = NO;
		ibLbEntry.hidden = NO;
		ibPvDrum.showsSelectionIndicator = NO;
		
		// reSetting
		for (Drum *drum in RaDrums) {
			[drum reSetting];
		}
		
		// 表示ドラム数(component数)が変わったときの処理
		if (MiSegDrums != ibPvDrum.numberOfComponents) {
			if (MiSegDrums <= entryComponent) { // entryComponentが表示ドラムを超えないように補正する
				entryComponent = MiSegDrums - 1;
			}
			// [ibPvDrum reloadAllComponents];  MvDrumButtonShow内で呼び出している
		}
		
		// Entryセル表示
		[self MvDrumButtonShow];
		// [M]ラベル表示
		[self MvMemoryShow];
		
		// キー再表示
		//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（上から下へかつ左から右）に収められている。
		NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（上から下へかつ左から右）に収められている。
		// タテ連結処理
		for (id obj in aKeys) {
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				if (bu.tag!=-1 && bu.hidden == NO) { // 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する
					// タテ連結処理
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu2 = (KeyButton *)obj;
							if (bu != bu2 
								&& bu.iPage == bu2.iPage // 同ページ内に限る
								&& bu.hidden == NO
								&& bu2.hidden == NO
								&& bu.iCol == bu2.iCol
								&& bu.iRow+1 == bu2.iRow) //[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正
							{	// 同列 ＆ 下行 ならば タテ連結
								if (bu.tag != bu2.tag) break; // 下行のTab違えば即終了
								if (bu.iCol != bu2.iCol) break;  // 列が違えば即終了
								/*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 ⇒ 右側を残して右隣(C+1)だけ比較するようにした。
								 CGRect rc = bu.frame;
								 rc.size.height = CGRectGetMaxY(bu2.frame) - rc.origin.y;
								 bu.frame = rc;
								 bu2.hidden = YES;
								 */
								CGRect rc = bu.frame; // タテ3連結以上に対応しているか確認すること。
								rc.size.height = CGRectGetMaxY(bu2.frame) - rc.origin.y;
								bu2.frame = rc;		// 下側ボタンを生かす。
								bu.hidden = YES;   // 上側ボタンを非表示にする
							}
						}
					}
				}
			}
		}
		
		// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
		for (id obj in aKeys) {
			if ([obj isMemberOfClass:[KeyButton class]]) {
				KeyButton *bu = (KeyButton *)obj;
				//NSLog(@"$$$$$ bu=[%@]", bu.titleLabel.text);
				if (bu.tag!=-1 && bu.hidden == NO) { // 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する
					// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
					for (id obj in aKeys) {
						if ([obj isMemberOfClass:[KeyButton class]]) {
							KeyButton *bu2 = (KeyButton *)obj;
							if (bu != bu2
								&& bu.iPage == bu2.iPage // 同ページ内に限る
								&& bu.hidden == NO
								&& bu2.hidden == NO 
								&& bu.iRow == bu2.iRow 
								&& bu.iCol+1 == bu2.iCol) //[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正
							{	// 同行 ＆ 右隣 ならば ヨコ結合
								if (bu.tag != bu2.tag) break; // 右列のTab違えば即終了
								if (bu.frame.size.height != bu2.frame.size.height) break; // 右列の高さが違えば即終了
								/*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 ⇒ 右側を残して右隣(C+1)だけ比較するようにした。
								 CGRect rc = bu.frame;
								 rc.size.width = CGRectGetMaxX(bu2.frame) - rc.origin.x;
								 bu.frame = rc;
								 bu2.hidden = YES;
								 */
								CGRect rc = bu.frame; // ヨコ3連結以上に対応しているか確認すること。
								rc.size.width = CGRectGetMaxX(bu2.frame) - rc.origin.x;
								bu2.frame = rc;		// 右側ボタンを生かす。
								bu.hidden = YES;   // 左側ボタンを非表示にする
							}
						}
					}
				}
			}
		}
		//[1.0.10]キーボードスクロール時、単位キーの有効／無効を「直前と同様に」セットする
		[self MvKeyUnitGroupSI];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	NSLog(@"--- viewDidLoad ---");
	NSLog(@"--- retainCount: ibScrollLower=%d", [ibScrollLower retainCount]);
    [super viewDidLoad];
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // 途中 return で抜けないこと！！！

	mAppDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

	// インストールやアップデート後、1度だけ処理する
	NSString *zNew = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString* zDef = [userDef valueForKey:@"DefVersion"];
	if (![zDef isEqualToString:zNew]) {
		if (zDef==nil || [zDef compare:@"1.0.6"]==NSOrderedAscending) { // ＜ "1.0.6"
			//[1.0.6] "5/4" と "6/5" の位置を入れ替えたことに対応するため。
			switch ((NSInteger)[userDef integerForKey:GUD_Round]) {
				case 2:
					[userDef setInteger:4 forKey:GUD_Round];
					break;
				case 4:
					[userDef setInteger:2 forKey:GUD_Round];
					break;
			}
		}
		[userDef setValue:zNew forKey:@"DefVersion"];
		MbInformationOpen = YES; // Informationを自動オープンする
	} else {
		MbInformationOpen = NO;
	}
	
	bPad = (700 < self.view.frame.size.height);
	
	// 背景テクスチャ・タイルペイント
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Tx-LzBack"]];

	//========================================================== Upper ==============
	// ScrollUpper  (0)Pickerドラム  (1)TextView数式
	ibScrollUpper.delegate = self;
	CGRect rect = ibScrollUpper.frame;
	ibScrollUpper.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height); 
	ibScrollUpper.scrollsToTop = NO;
	MiSvUpperPage = 0;
	rect.origin.x = rect.size.width * MiSvUpperPage;
	[ibScrollUpper scrollRectToVisible:rect animated:NO]; // 初期ページ(1)にする
	
	//ibScrollUpper.scrollEnabled = YES; //スクロール許可
	ibScrollUpper.bounces = NO; // 両端の跳ね返り

	//[1.0.8.2]　UITapGestureRecognizer対応 ＜＜iOS3.2以降
	ibScrollUpper.scrollEnabled = NO; //スクロール禁止
	ibScrollUpper.delaysContentTouches = NO; //スクロール操作検出のため0.5s先取中止 ⇒ これによりキーレスポンス向上する
	// セレクタを指定して、ジェスチャーリコジナイザーを生成する ＜＜iOS3.2以降対応
	// handleSwipeLeft:ハンドラ登録　　2本指で左へスワイプされた
	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpperSwipeLeft:)];
	swipe.numberOfTouchesRequired = 1; //2; //タッチの数、つまり指の本数
	swipe.direction = UISwipeGestureRecognizerDirectionLeft; //左
	[ibScrollUpper addGestureRecognizer:swipe];// スクロールビューに登録
	[swipe release];
	// handleSwipeRight:ハンドラ登録　　2本指で右へスワイプされた
	swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpperSwipeRight:)];
	swipe.numberOfTouchesRequired = 1; //2; //タッチの数、つまり指の本数
	swipe.direction = UISwipeGestureRecognizerDirectionRight; //右
	[ibScrollUpper addGestureRecognizer:swipe];// スクロールビューに登録
	[swipe release], swipe = nil;
	// 1指2タップ
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpper2Taps:)];
	tap.numberOfTouchesRequired =1; // 指数
	tap.numberOfTapsRequired = 2; // タップ数
	[ibPvDrum addGestureRecognizer:tap];
	[tap release], tap = nil;
	/*// 長押し
	UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpperLongPress:)];
	[ibPvDrum addGestureRecognizer:press];
	[press release], press = nil;*/

	//-----------------------------------------------------(0)ドラム ページ
	if (RaDrumButtons) {
		[RaDrumButtons release];	// viewDidUnloadされた後、ここを通る
		RaDrumButtons = nil;
	}
	NSMutableArray *maButtons = [NSMutableArray new];
	// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
	for (int i=0; i<DRUMS_MAX; i++) {
		// ドラム切り替えボタン(透明)をaddSubView
		UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
		bu.tag = i;
#ifdef AzMAKE_SPLASHFACE
		bu.alpha = 0.0;	// これで非表示状態になる
		//bu.hidden = YES;   MvDrumButtonShowで変更しているため効果なし
#else
		bu.alpha = 0.3; // 半透明 (0.0)透明にするとクリック検出されなくなる
		[bu addTarget:self action:@selector(MvDrumButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];  //TouchUpInside];
#endif
		[maButtons addObject:bu];
		//[self.view addSubview:bu];
		[ibScrollUpper addSubview:bu];
		//[bu release]; Auto
	}
	RaDrumButtons = [[NSArray alloc] initWithArray:maButtons];	
	[maButtons release];
	
	if (RaDrums==nil) {
		// Drumオブジェクトは、最初に1度だけ生成し、viewDidUnloadでは破棄しない。
		NSMutableArray *mRaDrums	= [NSMutableArray new];
		// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
		for (int i=0; i<DRUMS_MAX; i++) {
			// ドラムインスタンス生成
			Drum *drum = [Drum new];
			[mRaDrums addObject:drum];
			[drum release];
		}
		RaDrums = [[NSArray alloc] initWithArray:mRaDrums];		
		[mRaDrums release];
		
		entryComponent = 0;
		bDramRevers = NO;
		bZoomEntryComponent = NO;
	}

	// IBコントロールの初期化
	ibPvDrum.delegate = self;
	ibPvDrum.dataSource = self;
	ibPvDrum.showsSelectionIndicator = NO;
	//NG//[ibPvDrum setSoundsEnabled:NO];  // ピッカーの音を止める。   Apple審査拒絶されました「仕様禁止メソッド」
	
	
	//-----------------------------------------------------(1)数式 ページ
	// UITextView
	ibLbFormAnswer.text = @"=";
	ibTvFormula.delegate = self;
	ibTvFormula.text = [NSString stringWithFormat:@"%@%@", FORMULA_BLANK, NSLocalizedString(@"Formula mode", nil)];
	//ibTvFormula.font = [UIFont systemFontOfSize:14];
	ibTvFormula.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	
	[ibBuGetDrum setTitle:NSLocalizedString(@"Formula Quote", nil) forState:UIControlStateNormal];
	ibBuGetDrum.titleLabel.textAlignment = UITextAlignmentCenter;
	ibBuGetDrum.titleLabel.font = [UIFont systemFontOfSize:14];
	//
	float dx = ibScrollUpper.frame.size.width;
#ifdef AzSTABLE
	rect = ibTvFormula.frame;		
	rect.origin.x += dx;	
	rect.size.height += (rect.origin.y - 3);  rect.origin.y = 3;  // AdMobのスペースを埋めるため
	ibTvFormula.frame = rect;
#else
	// Free : 上部に AdMob スペースあり
	rect = ibTvFormula.frame;		rect.origin.x += dx;	ibTvFormula.frame = rect;
#endif
	rect = ibLbFormAnswer.frame;	rect.origin.x += dx;	ibLbFormAnswer.frame = rect;
	rect = ibBuFormLeft.frame;		rect.origin.x += dx;	ibBuFormLeft.frame = rect;
	rect = ibBuFormRight.frame;		rect.origin.x += dx;	ibBuFormRight.frame = rect;
	rect = ibBuGetDrum.frame;		rect.origin.x += dx;	ibBuGetDrum.frame = rect;


	//========================================================== Lower ==============
	//[0.4.2]//[self MvPadKeysShow]より前に必要だった。
	//[0.4.1]//"Received memory warning. Level=2" 回避するための最適化
	
	if (bPad) { // iPad
		iKeyPages = 4;	//[0.4]単位キー追加のため
		iKeyCols = 7;	iKeyOffsetCol = 0; // AzdicKeys.plist C 開始位置
		iKeyRows = 7;	iKeyOffsetRow = 0;
		fKeyGap = 3.0;
		fKeyFontZoom = 1.5;
	}
	else { // iPhone
		//iKeyPages = 4;  //iPhone3Gだと、4以上にすると Received memory warning. 発生し、しばらくすると落ちる
		iKeyPages = 5;  //mKeyView（1ページ生成）方式により制限解除
		iKeyCols = 5;	iKeyOffsetCol = 1; // AzdicKeys.plist C 開始位置
		iKeyRows = 5;	iKeyOffsetRow = 1;
		fKeyGap = 1.5;
		fKeyFontZoom = 1.0;
	}
	
	// ScrollLower 	(0)Memorys (1〜)Buttons
	MiSvLowerPage = 1; // DEFAULT PAGE
	rect = ibScrollLower.bounds;
	//ibScrollLower.contentSize = CGSizeMake(rect.size.width * iKeyPages, rect.size.height); 
	//ibScrollLower.contentSize = CGSizeMake(rect.size.width * (iKeyPages + 2), rect.size.height); // (0)先頭 と (iKeyPages+1)末尾 にブランクページ
	ibScrollLower	.contentSize = CGSizeMake(rect.size.width * PAGES, rect.size.height); 
	ibScrollLower.scrollsToTop = NO;
	//rect.origin.x = rect.size.width * MiSvLowerPage;
	rect.origin.x = rect.size.width * PAGES/2;
	[ibScrollLower scrollRectToVisible:rect animated:NO]; // 初期ページ位置
	ibScrollLower.delegate = self;
	//ibScrollLower.delaysContentTouches = YES; //スクロール操作検出のため0.5s先取する
	
	//[1.0.8]　UITapGestureRecognizer対応 ＜＜iOS3.2以降
	ibScrollLower.scrollEnabled = NO; //スクロール禁止
	ibScrollLower.delaysContentTouches = NO; //スクロール操作検出のため0.5s先取中止 ⇒ これによりキーレスポンス向上する
	// セレクタを指定して、ジェスチャーリコジナイザーを生成する ＜＜iOS3.2以降対応
	// handleSwipeLeft:ハンドラ登録　　2本指で左へスワイプされた
	//UISwipeGestureRecognizer *
	swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLowerSwipeLeft:)];
	swipe.numberOfTouchesRequired = 1; //2; //タッチの数、つまり指の本数
	swipe.direction = UISwipeGestureRecognizerDirectionLeft; //左
	[ibScrollLower addGestureRecognizer:swipe];// スクロールビューに登録
	[swipe release], swipe = nil;
	// handleSwipeRight:ハンドラ登録　　2本指で右へスワイプされた
	swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLowerSwipeRight:)];
	swipe.numberOfTouchesRequired = 1; //2; //タッチの数、つまり指の本数
	swipe.direction = UISwipeGestureRecognizerDirectionRight; //右
	[ibScrollLower addGestureRecognizer:swipe];// スクロールビューに登録
	[swipe release], swipe = nil;
	
	//NSInteger iPageUpdate = 999; //[0.4]ユーザのキー配置変更を守りつつ単位キーを追加するため

#ifdef AzMAKE_SPLASHFACE
	ibPvDrum.alpha = 0.9;
	ibBuMemory.hidden = YES;
	ibLbEntry.hidden = YES;
	ibBuSetting.hidden = YES;
	ibBuInformation.hidden = YES;
	RdicAllKeys = [NSDictionary new];
#else
	// standardUserDefaults からキー配置読み込む
	if (RdicAllKeys) {
		[RdicAllKeys release], RdicAllKeys = nil;
	}
	RdicAllKeys = [userDef objectForKey:GUD_KeyboardSet];
	if (RdicAllKeys==nil) {  // インストール初回のみ通る
		// AzKeySet.plistからキー配置読み込む
		NSString *zPath;
		if (bPad) { // iPad
			zPath = [[NSBundle mainBundle] pathForResource:@"AzKeySet-iPad" ofType:@"plist"];
		} else {
			zPath = [[NSBundle mainBundle] pathForResource:@"AzKeySet" ofType:@"plist"];
		}
		RdicAllKeys = [[NSDictionary alloc] initWithContentsOfFile:zPath];	// 後で release している
		if (RdicAllKeys==nil) {
			AzLOG(@"ERROR: AzKeySet.plist not Open");
			exit(-1);
		}
	}
	// 初期キーボード配置dicを　standardUserDefaults へ保存する　＜＜アプリがアップデートされても保持される＞＞
	[userDef setObject:RdicAllKeys forKey:GUD_KeyboardSet];
	if ([userDef synchronize] != YES) {
		NSLog(@"RdicAllKeys synchronize: ERROR");
	}
#endif
	
	// ibPvDrumは、画面左下を基点にしている。
	// ボタンの縦横比を「黄金率」にして余白をGapにする
	fKeyWidGap = 0;
	fKeyHeiGap = 0;
	fKeyWidth = ibScrollLower.bounds.size.width / iKeyCols;  // 均等割り　 iPhone=320/5=64  iPad=768/7=110
	fKeyHeight = ibScrollLower.bounds.size.height / iKeyRows; 
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

	/*[1.0.10] viewWillAppear:にて生成＆描画するようにした。
	CGRect rc = ibScrollLower.bounds;
	for (int page=0; page<iKeyPages; page++ ) 
	{
		rc.origin.x = rc.size.width * page;
		UIView *vv = [[UIView alloc] initWithFrame:rc];
		[self drawKeyboard:vv page:page];
		[ibScrollLower addSubview:vv];
		[vv release];
	}
	[dicKeys release];

	if (RaKeyMaster) {
		[RaKeyMaster release];
		RaKeyMaster = nil;
	}
	*/
	
#ifdef GD_Ad_ENABLED
	//--------------------------------------------------------------------------------------------------------- AdMob
	if (RoAdMobView==nil) {
		RoAdMobView = [[GADBannerView alloc] init];
		RoAdMobView.rootViewController = self;
		
        if (bPad) { // iPad    GAD_SIZE_728x90, GAD_SIZE_468x60
            //rc.origin.x = ibScrollUpper.frame.size.width * 1.5 - rc.size.width/2.0; // (1)ページ中央へ
			RoAdMobView.adUnitID = AdMobID_CalcRollPAD;
			//[1.0.5]大型
			RoAdMobView.frame = CGRectMake(ibScrollUpper.frame.size.width+20,  0,
										   GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }
		else {
			RoAdMobView.adUnitID = AdMobID_CalcRoll;
			RoAdMobView.frame = CGRectMake(ibScrollUpper.frame.size.width,  0,
										   GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
		}
		GADRequest *request = [GADRequest request];
		//[request setTesting:YES];
		[RoAdMobView loadRequest:request];	

		[ibScrollUpper addSubview:RoAdMobView];
		[self.view bringSubviewToFront:RoAdMobView]; // 上にする
		//[RoAdMobView release] しない。 deallocにて 停止(.delegate=nil) & 破棄 するため。
	}

	//--------------------------------------------------------------------------------------------------------- iAd
	//if (NSClassFromString(@"ADBannerView")) {
	if (RiAdBanner==nil && [[[UIDevice currentDevice] systemVersion] compare:@"4.0"]!=NSOrderedAscending) { // !<  (>=) "4.0"
		assert(NSClassFromString(@"ADBannerView"));
		// iPad はここで生成する。　iPhoneはXIB生成済み。
		NSLog(@"-1- retainCount: RiAdBanner=%d", [RiAdBanner retainCount]);
		RiAdBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
		NSLog(@"-2- retainCount: RiAdBanner=%d", [RiAdBanner retainCount]);

		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.2"]==NSOrderedAscending) { // ＜ "4.2"
			// iOS4.2より前
			//[0.5.0]ヨコのときもタテと同じバナーを使用する
			RiAdBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, nil];
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		}
		else {
			// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
			//[0.5.0]ヨコのときもタテと同じバナーを使用する
			RiAdBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, nil];
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		}
		RiAdBanner.delegate = self;
		CGRect theBannerFrame = self.view.frame;
		theBannerFrame.origin.y = -70;  // viewの外へ出す (iPadの高さが66)
		RiAdBanner.frame = theBannerFrame;	
		[ibScrollUpper addSubview:RiAdBanner];
		//retainCount +2 --> unloadRelease:にて　-2 している　　　　　unloadReleaseにて.delegate=nilしてからreleaseするため、自己管理する。
		bADbannerIsVisible = NO;
	}
	//1.0.0//AdMob共用化
	bADbannerTopShow = YES;
#endif
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MfAudioVolume = (float)[defaults integerForKey:GUD_AudioVolume] / 10.0;
	
	// Setting
#ifdef AzMAKE_SPLASHFACE
	MiSegDrums = 1; // Default.png ドラム数
#else
	MiSegDrums = 1 + (NSInteger)[defaults integerForKey:GUD_Drums];	// ドラム数 ＜＜セグメント値に +1 している＞＞
	if (MiSegDrums<=0) {
		if (bPad) { 
			MiSegDrums = 3;	// iPad初期ドラム数
		} else {
			MiSegDrums = 2;	// iPhone初期ドラム数
		}
		[defaults setInteger:MiSegDrums-1 forKey:GUD_Drums];
	}
#endif
	if (DRUMS_MAX < MiSegDrums) MiSegDrums = DRUMS_MAX;  // 生成数を超えないように
	MiSegCalcMethod = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
	[CalcFunctions setCalcMethod:MiSegCalcMethod];
	
	MiSegDecimal = (NSInteger)[defaults integerForKey:GUD_Decimal];
	if (DECIMAL_Float <= MiSegDecimal) MiSegDecimal = PRECISION; // [F]小数桁制限なし
	[CalcFunctions setDecimal:MiSegDecimal];
	
	MiSegRound = (NSInteger)[defaults integerForKey:GUD_Round];
	[CalcFunctions setRound:MiSegRound];
	
	MiSegReverseDrum = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];
	
	// Option
	MfTaxRate = 1.0 + [defaults floatForKey:GUD_TaxRate] / 100.0; // 1 + 消費税率%/100
	
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
	
	//-------------------------------------------------------------------------キーボード生成
	// キーボタン イメージ
	if (RimgDrumButton) {
		[RimgDrumButton release], RimgDrumButton = nil;
	}
	if (RimgDrumPush) {
		[RimgDrumPush release], RimgDrumPush = nil;
	}
	switch ([defaults integerForKey:GUD_ButtonDesign]) {
		case 1: // Oval
			//[1.0.10]stretchableImageWithLeftCapWidth:により四隅を固定して伸縮する
			if (bPad) {
				RimgDrumButton = [[[UIImage imageNamed:@"KeyOvalUp@Pad"] stretchableImageWithLeftCapWidth:35 topCapHeight:35] retain];
				RimgDrumPush = [[[UIImage imageNamed:@"KeyOvalDw@Pad"] stretchableImageWithLeftCapWidth:35 topCapHeight:35] retain];
			} else {
				RimgDrumButton = [[[UIImage imageNamed:@"KeyOvalUp"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] retain];
				RimgDrumPush = [[[UIImage imageNamed:@"KeyOvalDw"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] retain];
			}
			break;
			
		case 2: // Square
			//[1.0.10]stretchableImageWithLeftCapWidth:により四隅を固定して伸縮する
			RimgDrumButton = [[[UIImage imageNamed:@"KeySquareUp"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] retain];
			RimgDrumPush = [[[UIImage imageNamed:@"KeySquareDw"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] retain];
			break;
			
		default: // 0=Roll
			//[1.0.10]stretchableImageWithLeftCapWidth:によりボタンイメージ向上
			//RimgDrumButton = [[UIImage imageNamed:@"KeyRollUp"] retain];
			RimgDrumButton = [[[UIImage imageNamed:@"KeyRollUp"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] retain];
			RimgDrumPush = [[[UIImage imageNamed:@"KeyRollDw"] stretchableImageWithLeftCapWidth:12 topCapHeight:0] retain];
			break;
	}
	
	// キーボード破棄
	if (mKeyViewPrev) {
		mKeyViewPrev.hidden = YES;  // 実機では、removeだけでは消えない場合があった。
		[mKeyViewPrev removeFromSuperview];
		mKeyViewPrev = nil;
	}
	if (mKeyView) {
		mKeyView.hidden = YES;  // 実機では、removeだけでは消えない場合があった。
		[mKeyView removeFromSuperview];
		mKeyView = nil;
	}
#ifdef AzMAKE_SPLASHFACE
	ibBuMemory.hidden = YES;
#else
	// キーボード生成
	CGRect rcBounds = ibScrollLower.bounds;	// .y = 0
	rcBounds.origin.x = rcBounds.size.width * PAGES/2; // 常に中央位置
	mKeyView = [[UIView alloc] initWithFrame:rcBounds]; // .y=どこでも大丈夫
	[self drawKeyboard:mKeyView page:MiSvLowerPage];
	[ibScrollLower addSubview:mKeyView], [mKeyView release];
	[ibScrollLower scrollRectToVisible:rcBounds animated:NO]; // 中央 ＜＜ .y=0でも大丈夫

	// MEMORY BUTTON
	[ibBuMemory setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
	[ibBuMemory setBackgroundImage:RimgDrumPush forState:UIControlStateHighlighted];
	ibBuMemory.hidden = NO;
	ibBuMemory.alpha = 0.0; // 透明にして隠す
	[self.view bringSubviewToFront:ibBuMemory]; // 上にする
	ibBuMemory.hidden = YES;

	if (bPad) {
		[self MvPadKeysShow]; // iPad専用 メモリー20キー配置 および 回転処理
	}
	
	// キーボタン生成後、小数点を変更する
	id obj = [mKeyView viewWithTag:KeyTAG_DECIMAL]; // (KeyTAG_DECIMAL)[.]小数点
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
#endif
}

- (void)viewDidAppear:(BOOL)animated // 画面表示された後にコールされる
{
	[super viewDidAppear:animated];
	
	/*
	if (buChangeKey) {
		//buChangeKey.backgroundColor = [UIColor clearColor]; // 前選択を戻す
		// 復帰
		[buChangeKey setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
		buChangeKey = nil;
	}*/

#ifdef GD_Ad_ENABLED
	[self MvShowAdApple:YES AdMob:YES];
#endif

	if (MbInformationOpen) {	//initWithStyleにて判定処理している
		MbInformationOpen = NO;	// 以後、自動初期表示しない。
		[self ibBuInformation:nil];
	}
}

// Entryセル表示：entryComponentの位置にibLbEntryActiveを表示する
- (void)MvDrumButtonShow
{
	assert(0 <= MiSegDrums);
	//float fWid = self.view.frame.size.width - DRUM_LEFT_OFFSET*2;
	float fWid = ibPvDrum.frame.size.width - DRUM_LEFT_OFFSET*2;
	float fWiMin, fWiMax;
	if (bZoomEntryComponent) {  // entryComponentを拡大する
		fWiMin = PICKER_COMPONENT_WiMIN; // 1コンポーネントの表示最小幅
		if (bPad) fWiMin *= 2.0;
		fWiMax = fWid - ((fWiMin + DRUM_GAP) * (MiSegDrums-1));
	} else {
		fWiMin = (fWid / MiSegDrums) - DRUM_GAP;
		fWiMax = fWiMin; // 均等
	}
	float fX = DRUM_LEFT_OFFSET + 4.0;
	float fY = ibPvDrum.frame.origin.y;
	int i = 0;
	for ( ; i<MiSegDrums ; i++) {
		UIButton *bu = [RaDrumButtons objectAtIndex:i];
		bu.hidden = NO;
		if (i == entryComponent) {
			//bu.frame = CGRectMake(fX,fY+155, fWiMax-6,28); // 選択中
			bu.frame = CGRectMake(fX,fY+153, fWiMax-6,32); // 選択中
			bu.backgroundColor = [UIColor greenColor];	// 追加
			bu.userInteractionEnabled = NO; //[1.0.10]ピッカーロール優先のため無効にした。　ダブルタップ式に変更
			// Next
			fX += (fWiMax + DRUM_GAP);
		} else {
			bu.frame = CGRectMake(fX,fY, fWiMin-6,fY+ibPvDrum.frame.size.height);  // 非選択時
			//bu.backgroundColor = [UIColor yellowColor];  //DEBUG
			bu.backgroundColor = [UIColor clearColor];
			bu.userInteractionEnabled = YES;
			// Next
			fX += (fWiMin + DRUM_GAP);
		}
	}
	for ( ; i<DRUMS_MAX ; i++) {
		UIButton *bu = [RaDrumButtons objectAtIndex:i];
		bu.hidden = YES;
	}
	[ibPvDrum reloadAllComponents];
}

// [M]ラベル表示
- (void)MvMemoryShow
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
		CGRect rc = ibBuMemory.frame; // Y位置はnib定義通り固定
		// 文字数からボタンの幅を調整する
		CGSize sz = [zTitle sizeWithFont:ibBuMemory.titleLabel.font];
		AzLOG(@"sizeWithFont = W%f, H%f", sz.width, sz.height);
		rc.size.width = sz.width + 20;
		if (260 < rc.size.width) rc.size.width = 260; // Over
		rc.origin.x = (ibPvDrum.frame.size.width - rc.size.width) / 2.0;
		ibBuMemory.frame = rc;
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// アニメ終了時の状態をセット
		ibBuMemory.alpha = 1.0;
	} 
	else {
		if (ibScrollLower.frame.origin.y <= ibBuMemory.frame.origin.y) return; // 既に隠れている
		// ボタンをibScrollLowerの裏に隠す
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// アニメ終了時の状態をセット
		ibBuMemory.alpha = 0.0;	// 透明
	}
	// アニメ開始
	[UIView commitAnimations];
}


#pragma mark  View 回転

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) return YES; // タテは常にOK
	else if (bPad) return YES; // iPad
	return NO;
}

//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation: ＜＜OS 3.0以降は非推奨×××
// 回転の開始前にコールされる。 ＜＜OS 3.0以降の推奨＞＞
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
#ifdef GD_Ad_ENABLED
	if (RiAdBanner) {	//[0.4.1]
		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.2"]==NSOrderedAscending) { // ＜ "4.2"
			// iOS4.2より前
			/*			if (UIInterfaceOrientationIsLandscape(orientation)) {
			 RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
			 } else {
			 RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			 }*/
			//[0.5.0]ヨコのときもタテと同じバナーを使用する
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		} else {
			// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
			/*			if (UIInterfaceOrientationIsLandscape(orientation)) {
			 RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			 } else {
			 RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			 }*/
			//[0.5.0]ヨコのときもタテと同じバナーを使用する
			RiAdBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		}
	}
#endif
	
	if (bPad) {
		// このタイミングでなければ、配置がズレる
		[ibTvFormula resignFirstResponder]; // キーボードを隠す
	}
}

// 回転アニメーションの開始直前に呼ばれる。 この直前の配置から、ここでの配置までの移動がアニメーション表示される。
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
#ifdef AzMAKE_SPLASHFACE
	return;
#endif
	if (!bPad) return; // iPhone
	
	// iPad専用 メモリー20キー配置 および 回転処理
	[self MvPadKeysShow]; 
	
	// RaDrumButtons
	[self MvDrumButtonShow];
	
	// ibBuMemory：透明にして隠す。その後、改めて MvMemoryShow する
	ibBuMemory.alpha = 0;
	[self MvMemoryShow]; // 改めて表示
}


#pragma mark - GestureRecognizer Handler

- (void)handleUpper2Taps: (UILongPressGestureRecognizer *) recognizer 
{	// 上部で1指2タップ　＜＜指が離れたときにも呼び出される（2回）ことに注意
	if (MiSvUpperPage==0) { // 選択中のロールを拡幅/縮小する
		[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
		// ドラム幅を拡大する
		bZoomEntryComponent = !bZoomEntryComponent;  // 拡大／均等トグル式
		
		// 以下の処理をしないと pickerView が再描画されない。
		NSInteger iDrums = MiSegDrums;
		MiSegDrums = 0;
		[ibPvDrum reloadAllComponents];
		MiSegDrums = iDrums;
		// ibPvDrum は、以下のアニメーションに対応しない。
		// アニメ準備
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		// アニメ終了時の位置をセット
		// Entryセル表示　＜＜この中でpickerView再描画
		[self MvDrumButtonShow];
		// アニメ開始
		[UIView commitAnimations];
	}
}

- (void)handleUpperSwipeLeft: (UISwipeGestureRecognizer*) recognizer 
{	// 2本指で左へスワイプされた
	NSLog(@"handleUpperSwipeLeft -- Swipe Left 2 finger -- MiSvUpperPage=%d", (int)MiSvUpperPage);
	if (ibScrollUpper.scrollEnabled) {
		// 次（右）ページ(1)へ
		if (1 <= MiSvUpperPage) { // End
			[self audioPlayer:@"short_double_low.caf"];  // 
		} else {
			MiSvUpperPage = 1;
			[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
			CGRect rect = ibScrollUpper.frame;
			rect.origin.x = rect.size.width * MiSvUpperPage;
			[ibScrollUpper scrollRectToVisible:rect animated:YES];
		}
	}
}

- (void)handleUpperSwipeRight: (UISwipeGestureRecognizer*) recognizer 
{	// 2本指で右へスワイプされた
	NSLog(@"handleUpperSwipeRight -- Swipe Right 2 finger -- MiSvUpperPage=%d", (int)MiSvUpperPage);
	if (ibScrollUpper.scrollEnabled) {
		// 前（左）ページ(0)へ
		if (MiSvUpperPage <= 0) {
			[self audioPlayer:@"sq_lock.caf"];  // 
		} else {
			MiSvUpperPage = 0;
			[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
			CGRect rect = ibScrollUpper.frame;
			rect.origin.x = rect.size.width * MiSvUpperPage;
			[ibScrollUpper scrollRectToVisible:rect animated:YES];
		}
	}
}

- (void)handleLowerSwipeLeft: (UISwipeGestureRecognizer*) recognizer 
{	// 2本指で左へスワイプされた
	NSLog(@"handleLowerSwipeLeft -- Swipe Left 2 finger -- MiSvLowerPage=%d", (int)MiSvLowerPage);
	// 次（右）ページへ
	if (iKeyPages <= MiSvLowerPage) {
		MiSvLowerPage = 0; // 最初のページ へ
	} else {
		MiSvLowerPage++; // Right
	}
	NSLog(@"-- MiSvLowerPage=%d", (int)MiSvLowerPage);
	[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音

	//assert(mKeyViewPrev==nil);
	if (mKeyViewPrev) {  // スクロールが完全停止しないうちにスワイプしたときのため
		[mKeyViewPrev removeFromSuperview];
	}
	mKeyViewPrev = mKeyView; // 直前ページを保持
	CGRect rect = mKeyView.frame; // .y=0 であることに注意
	if (ibScrollLower.contentSize.width - rect.size.width <= rect.origin.x) { // スクロール限界オーバー
		rect.origin.x = rect.size.width * PAGES/2; // 強制的に中央へ戻す
		[ibScrollLower scrollRectToVisible:rect animated:NO]; // 瞬間移動！
		mKeyViewPrev.frame = rect;		// 瞬間移動！ ＜＜結構、うまく錯覚させることができているようだ。
	}
	rect.origin.x += rect.size.width;	// (+)右へ
	// 新しいページを生成し、スクロール表示
	mKeyView = [[UIView alloc] initWithFrame:rect];
	[self drawKeyboard:mKeyView page:MiSvLowerPage]; // キー生成
	[ibScrollLower addSubview:mKeyView], [mKeyView release];
	[ibScrollLower scrollRectToVisible:rect animated:YES]; // rect.origin.y=0になっているが垂直移動しないので無視される
	// キーレイアウト変更モードならば、直前ページを保存する
	if (RaKeyMaster) {// !=nil キーレイアウト変更モード
		[self MvSaveKeyView:mKeyViewPrev];
	}
}

- (void)handleLowerSwipeRight: (UISwipeGestureRecognizer*) recognizer 
{	// 2本指で右へスワイプされた
	NSLog(@"handleLowerSwipeRight -- Swipe Right 2 finger -- MiSvLowerPage=%d", (int)MiSvLowerPage);
	// 前（左）ページへ
	if (MiSvLowerPage <= 0) {
		MiSvLowerPage = iKeyPages; // 最終ページ へ
	} else {
		MiSvLowerPage--; // Left
	}
	NSLog(@"-- MiSvLowerPage=%d", (int)MiSvLowerPage);
	[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音

	//assert(mKeyViewPrev==nil);
	if (mKeyViewPrev) {  // スクロールが完全停止しないうちにスワイプしたときのため
		[mKeyViewPrev removeFromSuperview];
	}
	mKeyViewPrev = mKeyView; // 直前ページを保持
	CGRect rect = mKeyView.frame; // .y=0 であることに注意
	if (rect.origin.x <= 0) { // スクロール限界オーバー
		rect.origin.x = rect.size.width * PAGES/2; // 強制的に中央へ戻す
		[ibScrollLower scrollRectToVisible:rect animated:NO]; // 瞬間移動！
		mKeyViewPrev.frame = rect;		// 瞬間移動！ ＜＜結構、うまく錯覚させることができているようだ。
	}
	rect.origin.x -= rect.size.width; // (-)左へ
	// 新しいページを生成し、スクロール表示
	mKeyView = [[UIView alloc] initWithFrame:rect];
	[self drawKeyboard:mKeyView page:MiSvLowerPage]; // キー生成
	[ibScrollLower addSubview:mKeyView], [mKeyView release];
	[ibScrollLower scrollRectToVisible:rect animated:YES]; // rect.origin.y=0になっているが垂直移動しないので無視される
	// キーレイアウト変更モードならば、直前ページを保存する
	if (RaKeyMaster) {// !=nil キーレイアウト変更モード
		[self MvSaveKeyView:mKeyViewPrev];
	}
}

/*
- (void)reset_MiSwipe1fingerCount {
	MiSwipe1fingerCount = 0;
}

- (void)handleSwipe1finger: (UISwipeGestureRecognizer*) recognizer
{	// 1本指で右または左へスワイプされた
	NSLog(@"handleSwipe1finger");
	MiSwipe1fingerCount++;
	if (MiSwipe1fingerCount == 1) {
		[self performSelector:@selector(reset_MiSwipe1fingerCount) withObject:nil afterDelay:1.0f]; // 秒後にクリアする
	}
	else if (2 <= MiSwipe1fingerCount) {	// 2回以上スワイプされたらヘルプメッセージを出す
		MiSwipe1fingerCount = 0;
		//NG//alertBox( NSLocalizedString(@"Help LowerSwipe title", nil), nil, @"OK" );  LINK ERROR になる
		
		NSString *zTitle;
		if (ibBuFormLeft.frame.origin.x < 0) {  // Fomula editting [(]左括弧ボタンが画面外に出ている ⇒ 編集ロック中
			zTitle = NSLocalizedString(@"Help Fomula locking", nil);
		} else {
			zTitle = NSLocalizedString(@"Help Swipe 2 fingers", nil);
		}
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:zTitle
														message:nil
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
}
*/

#pragma mark - UNIT 単位

- (void)MvKeyUnitGroupSI
{	//[1.0.10]キーボードスクロール時、単位キーの有無効を直前と同様にする
	for (id obj in mKeyView.subviews)
	{
		if ([obj isMemberOfClass:[KeyButton class]]) {
			KeyButton *kb = obj;
			if (3<[kb.RzUnit length]) {  // = "SI基本単位:変換式;逆変換式"
				if (mGvKeyUnitSI || mGvKeyUnitSi2) {		// 注意 ↓ nil ↓ 渡すとエラーになる
					if ((mGvKeyUnitSI && [kb.RzUnit hasPrefix:mGvKeyUnitSI]) 
						|| (mGvKeyUnitSi2 && [kb.RzUnit hasPrefix:mGvKeyUnitSi2])
						|| (mGvKeyUnitSi3 && [kb.RzUnit hasPrefix:mGvKeyUnitSi3])) {
						// 同系列ハイライト
						kb.userInteractionEnabled = YES;
						kb.alpha = KeyALPHA_DEFAULT_ON;
					} else {
						// 異系列グレーアウト
						//NG//kb.enabled = NO;  ＜＜これをすると無効になったキーに薄い線が現れてしまう。
						kb.userInteractionEnabled = NO;
						kb.alpha = 0.5; // OFF
					}
				} else {
					// ノーマル
					kb.userInteractionEnabled = YES;
					kb.alpha = KeyALPHA_DEFAULT_ON;
				}
			}
		}
	}
}

- (void)GvKeyUnitGroupSI:(NSString *)unitSI 
				   andSI:(NSString *)unitSi2 // =nil:ハイライト解除
{
	[self GvKeyUnitGroupSI:unitSI andSi2:unitSi2 andSi3:nil];
}

- (void)GvKeyUnitGroupSI:(NSString *)unitSI
				  andSi2:(NSString *)unitSi2
				  andSi3:(NSString *)unitSi3 // =nil:ハイライト解除
{
	NSLog(@"***GvKeyUnitGroupSI=%@,%@,%@", unitSI, unitSi2, unitSi3);
	[mGvKeyUnitSI release];		if (unitSI) mGvKeyUnitSI = [unitSI copy];			else	mGvKeyUnitSI = nil;
	[mGvKeyUnitSi2 release];	if (unitSi2) mGvKeyUnitSi2 = [unitSi2 copy];	else	mGvKeyUnitSi2 = nil;
	[mGvKeyUnitSi3 release];	if (unitSi3) mGvKeyUnitSi3 = [unitSi3 copy];	else	mGvKeyUnitSi3 = nil;
	NSLog(@"***mGvKeyUnitSI=%@,%@,%@", mGvKeyUnitSI, mGvKeyUnitSi2, mGvKeyUnitSi3);
	[self MvKeyUnitGroupSI];
}


// MARK: キー表示

// keyView キー配置＆属性を記録する。起動時間短縮  　　
- (void)MvSaveKeyView:(UIView*)keyView	
{	//[1.0.10] keyView のキー配置を記録する　＜＜キー配置変更時、ページ切替の都度、呼び出されて記録する。
	if (!keyView) return;

	//NSMutableDictionary *mdKeySet = [NSMutableDictionary new];
	NSMutableDictionary *mdKeySet = [NSMutableDictionary new];  //[userDef objectForKey:GUD_KeyboardSet];
	[mdKeySet setDictionary:RdicAllKeys];
	if (!mdKeySet) {
		NSLog(@"MvSaveKeyView: ERROR: mdKeySet==nil");
		return;
	}
	
	NSArray *aKeys = [keyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
	for (id obj in aKeys) {
		//AzLOG(@"aKeys:obj class=%@", [[obj class] description]); // "KeyButton" が得られる
		assert([obj isMemberOfClass:[KeyButton class]]);
		KeyButton *bu = (KeyButton *)obj;
		NSString *zPCR = [[NSString alloc] initWithFormat:@"P%dC%dR%d", (int)bu.iPage, (int)bu.iCol, (int)bu.iRow];
		/*
		 if ([mdKeySet objectForKey:zPCR]) {
			// キー重複
			NSLog(@"MvSaveKeyView: ERROR:キー重複:%@", zPCR);
		} 
		else */
		
		[mdKeySet removeObjectForKey:zPCR]; // キー削除する
		
		{
			// 新規生成して追加
			NSString *strText  = bu.titleLabel.text;
			NSNumber *numSize  = [NSNumber numberWithFloat:bu.fFontSize];
			NSNumber *numColor = [NSNumber numberWithInteger:bu.iColorNo];
			NSNumber *numAlpha = [NSNumber numberWithFloat:bu.alpha];
			NSString *strUnit  = bu.RzUnit;
			
			if (RaKeyMaster) 
			{	// Master属性を優先する
				strText = nil;
				for (NSArray *aKey in RaKeyMaster) {
					for (NSDictionary *dKey in aKey) {
						if ([[dKey objectForKey:@"Tag"] integerValue] == bu.tag) {
							strText	 = [dKey objectForKey:@"Text"];
							numSize  = [dKey objectForKey:@"Size"];
							numColor = [dKey objectForKey:@"Color"];
							numAlpha = [dKey objectForKey:@"Alpha"];
							strUnit  = [dKey objectForKey:@"Unit"];
							break;
						}
					}
					if (strText) break;
				}
			}
			
			if (strText==nil) strText = @" "; // Space1
			if (strUnit==nil) strUnit = @"";  // Dictionary では、nil 禁止のため
			
			NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
								 [NSNumber numberWithInteger:bu.tag], @"Tag",
								 strText,	@"Text",
								 numSize,	@"Size",
								 numColor,	@"Color",
								 numAlpha,	@"Alpha",
								 strUnit,	@"Unit", nil];
			[mdKeySet setObject:dic forKey:zPCR];
			[dic release];
		}
		[zPCR release];
	}		
	// RdicAllKeys 更新
	[RdicAllKeys release];
	RdicAllKeys = [[NSDictionary alloc] initWithDictionary:mdKeySet];
	//
#ifdef AzDEBUG
	// レイアウト結果を.plistファイルへ書き出すことにより、初期レイアウトファイル"AzKeySet.plist"を作ることができる。
	NSString *zPath = @"/Users/masa/AzukiSoft/AzCalc/AzCalc/AzKeySet_DEBUG.plist";
	[mdKeySet writeToFile:zPath atomically:YES];
#endif
	[mdKeySet release];	mdKeySet = nil;
}


- (void)MvKeyLayoute:(KeyButton *)button   // キーレイアウト変更モード // ドラム選択中のキーを割り当てる
{
	int iComponent = 0;
	int iRow = 0;  // 見出し行
	for (int i=0; i<[RaKeyMaster count]; i++) {
		iRow = [ibPvDrum selectedRowInComponent:i];
		if (0 < iRow) {
			iComponent = i;
			break;
		}
	}
	if (iComponent==0 && iRow==0) { // ドラム選択が無い場合、押したキーの選択にする
		int iComp = 0;
		for (NSArray *aComponent in RaKeyMaster) {
			int iDict = 0;
			for (NSDictionary *dic in aComponent) {
				if ([[dic objectForKey:@"Tag"] integerValue] == button.tag) {
					[ibPvDrum selectRow:iDict inComponent:iComp animated:YES];
					// 他リセット
					for (int i=0; i<[RaKeyMaster count]; i++) {
						if (i != iComp) [ibPvDrum selectRow:0 inComponent:i animated:YES];
					} break;
				} iDict++;
			} iComp++;
		} 
		return;
	}
	// iRow==0 ならば .tag=(-1)未定義になる
	NSDictionary *dic = [[RaKeyMaster objectAtIndex:iComponent] objectAtIndex:iRow];
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
		// Unit
		button.RzUnit = @"";
	}
	else {
		button.bDirty = YES; // 変更あり ⇒ 保存される
		// Text
		[button setTitle:[dic objectForKey:@"Text"] forState:UIControlStateNormal];
		// Color
		button.iColorNo = [[dic objectForKey:@"Color"] integerValue];
		switch (button.iColorNo) {
			case 1:	[button setTitleColor:[UIColor blackColor]	forState:UIControlStateNormal];	break;
			case 2:	[button setTitleColor:[UIColor redColor]	forState:UIControlStateNormal];	break;
			case 3:	[button setTitleColor:[UIColor blueColor]	forState:UIControlStateNormal];	break;
			case 4:	[button setTitleColor:[UIColor brownColor]	forState:UIControlStateNormal];	break;
			default:[button setTitleColor:[UIColor yellowColor]	forState:UIControlStateNormal];	break;
		}
		// Size
		float fSize = [[dic objectForKey:@"Size"] floatValue]; 
		button.fFontSize = fSize; 
		if (bPad) fSize *= 1.5; // iPadやや拡大
		button.titleLabel.font = [UIFont boldSystemFontOfSize:fSize];
		// Alpha
		button.alpha = [[dic objectForKey:@"Alpha"] floatValue];
		// Unit
		button.RzUnit = [dic objectForKey:@"Unit"];
	}
	
	//[0.3.1]毎回、ドラムをリセットすることにした。
	for (int i=0; i<[RaKeyMaster count]; i++) {
		[ibPvDrum selectRow:0 inComponent:i animated:YES];
	}
}

- (void)MvFormulaBlankMessage:(BOOL)bBlank
{
	if (bBlank) {
		// 入力なければブランクメッセージ表示する
		if ([ibTvFormula.text length]<=0) {
			//ibTvFormula.font = [UIFont systemFontOfSize:14];  iPadのXIBで、フォントサイズを大きくしているため
			ibTvFormula.text = [NSString stringWithFormat:@"%@%@", FORMULA_BLANK, NSLocalizedString(@"Formula mode", nil)];
			ibBuGetDrum.hidden = NO;
		}
	} else {
		// ブランクメッセージ表示中ならばクリアする
		if ([ibTvFormula.text hasPrefix:FORMULA_BLANK]) {
			ibTvFormula.text = @"";
			//ibTvFormula.font = [UIFont systemFontOfSize:20];
			ibBuGetDrum.hidden = YES;
		}
	}
}

- (void)GvMemorySave
{	// [M]メモリボタンや[PB]ボタン を standardUserDefaults へ保存する
	NSMutableDictionary *mdMk = [NSMutableDictionary new];
	if (RaPadKeyButtons) { // iPad専用メモリー優先　＜＜たいていiPhoneメモリ数より多いから＞＞
		for (KeyButton *bu in RaPadKeyButtons) {
			//NSNumber *num = [NSNumber numberWithInteger:bu.tag];
			NSString *zTag = [NSString stringWithFormat:@"%ld", (long)bu.tag]; // forKey:文字列のみ
			if ([mdMk objectForKey:zTag]==nil) { // なければ追加、あればパス
				// Add
				[mdMk setObject:bu.titleLabel.text forKey:zTag];
			}
		}
	}
	// 主にiPhone 初期の0ページにあるメモリボタンを保存
	//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
	NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
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
	
	/*[1.0.9]常に DEFAULT PAGE に戻すようにした。
	// Keyboard ページ保存
	[mdMk setObject:[NSNumber numberWithInteger:MiSvLowerPage]  forKey:@"KB_PAGE"];
	 */
	
	// SAVE
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	[userDef setObject:mdMk forKey:GUD_KeyMemorys];
	//if ([userDef synchronize] != YES) { // file write
	//	AzLOG(@"GUD_KeyMemorys synchronize: ERROR");
	//}
	[mdMk release];	//mdMk = nil;
}

- (void)GvMemoryLoad
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
	if (RaPadKeyButtons) { // iPad専用メモリー優先　＜＜たいていiPhoneメモリ数より多いから＞＞
		for (KeyButton *bu in RaPadKeyButtons) {
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
	//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
	NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
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
	[self MvMemoryShow];
	// Keyboard ページ復帰
	{
		/*[1.0.9]常に DEFAULT PAGE に戻すようにした。
		NSNumber *num = [dicMkeys objectForKey:@"KB_PAGE"];
		if (num && 0<=[num integerValue]) {
			MiSvLowerPage = [num integerValue];
			CGRect rc = ibScrollLower.frame;
			rc.origin.x = rc.size.width * MiSvLowerPage;
			[ibScrollLower scrollRectToVisible:rc animated:NO];
		} else {
			MiSvLowerPage = 2; // DEFAULT PAGE
		}*/
		MiSvLowerPage = 1; // DEFAULT PAGE
	}
}

- (void)MvKeyboardPage:(NSInteger)iPage
{
	//if (ibScrollLower.frame.origin.x / ibScrollLower.frame.size.width == iPage) return; // 既にiPageである。
	CGRect rc = ibScrollLower.frame;
	rc.origin.x = rc.size.width * iPage;
	[ibScrollLower scrollRectToVisible:rc animated:YES];
}

/*[1.0.8]廃止：2指スワイプ対応により相性が悪くなったため
- (void)MvKeyboardPage1Alook0 // 1ページから0ページを「ちょっと見せる」アニメーション
{
	//AzLOG(@"ibScrollLower: x=%f w=%f", ibScrollLower.frame.origin.x, ibScrollLower.frame.size.width);
	//if (ibScrollLower.  .frame.origin.x / ibScrollLower.frame.size.width != 1) return; // 1ページ限定
	CGRect rc = ibScrollLower.frame;
	rc.origin.x = rc.size.width - 17; // 0Page方向へ「ちょっと見せる」だけ戻す
	[ibScrollLower scrollRectToVisible:rc animated:NO];
	rc.origin.x = rc.size.width * 1; // 1Pageに復帰
	[ibScrollLower scrollRectToVisible:rc animated:YES];
}*/

- (void)MvPadKeysShow // iPad専用 メモリー20キー配置 および 回転処理
{
	assert(bPad); // iPad
	if (RaPadKeyButtons) {
		//破棄しない//[RaPadKeyButtons release], RaPadKeyButtons = nil;
		// .titleに値を保持しているため、破棄せずに表示だけ変更する
		for (KeyButton *bu in RaPadKeyButtons) {
			[bu setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
			[bu setBackgroundImage:RimgDrumPush forState:UIControlStateHighlighted];
		}
	}
	else {
		// 生成
		NSMutableArray *maBus = [NSMutableArray new];
		for (int i=0; i<15; i++) 
		{
			//UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
			KeyButton *bu = [[KeyButton alloc] initWithFrame:CGRectZero];
			[bu setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
			[bu setBackgroundImage:RimgDrumPush forState:UIControlStateHighlighted];
			bu.iPage = 9;
			bu.iCol = 0;
			bu.iRow = 0;
			bu.bDirty = NO;
			bu.alpha = KeyALPHA_MSTORE_OFF;
			bu.tag = KeyTAG_MSTORE_Start + 1 + i;
			[bu setTitle:[NSString stringWithFormat:@"M%d", (int)1+i] forState:UIControlStateNormal];
			bu.titleLabel.font = [UIFont boldSystemFontOfSize:DRUM_FONT_MSG];
			[bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
			[bu addTarget:self action:@selector(ibButton:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:bu];
			[maBus addObject:bu];
		}
		RaPadKeyButtons = [[NSArray alloc] initWithArray:maBus];
		[maBus release];
	}
	
	// 回転移動
	CGRect rc = CGRectMake(0,0, 256-8*2, 49.8-5*2);
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		// ヨコ ⇒ W254 H748 縦20行1列表示
		rc.origin.x = 768 + 8;
		rc.origin.y = 5;
		for (UIButton *bu in RaPadKeyButtons) {
			bu.frame = rc;
			rc.origin.y += 49.8;
		}
	}
	else {
		// タテ ⇒ W768 H256 縦7行3列表示
		rc.origin.x = 8;
		rc.origin.y = 5;
		for (UIButton *bu in RaPadKeyButtons) {
			bu.frame = rc;
			rc.origin.y += 49.8;
			if (250 < rc.origin.y) {
				rc.origin.x += 256;
				rc.origin.y = 5;
			}
		}
	}
}




// MARK: キー操作

- (void)vDrumButtonTap1Clear
{
	bDrumButtonTap1 = NO;
}

- (void)MvDrumButtonTouchUp:(UIButton *)button	// ドラム切り替え
{
	if (RaKeyMaster) {
		// キーレイアウト変更モード
		return;
	}

#ifdef xxxOLDxxx
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
#else
	// シングルタップ式
	if (entryComponent == button.tag) {
		[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
		// ドラム幅を拡大する
		bZoomEntryComponent = !bZoomEntryComponent;  // 拡大／均等トグル式
	}
#endif
	
	//BOOL bTouchAction = NO;
	if (entryComponent != button.tag) {
		[self audioPlayer:@"SentMessage.caf"];  // SMSの送信音

		entryComponent = button.tag;	// ドラム切り替え
		bZoomEntryComponent = NO;  // 均等サイズに戻す
		//bTouchAction = YES;
		// ドラム切り替え時に、キーボードをページ(1)にする
	//	CGRect rc = ibScrollLower.frame;
	//	rc.origin.x = rc.size.width * 1;
	//	[ibScrollLower scrollRectToVisible:rc animated:YES];
		// UNIT系列 再構成
		Drum *drum = [RaDrums objectAtIndex:entryComponent];
		//[self GvKeyUnitGroupSI:[drum zUnitRebuild] andSI:nil];
		[drum GvEntryUnitSet];
	}
	
	// 以下の処理をしないと pickerView が再描画されない。
	NSInteger iDrums = MiSegDrums;
	MiSegDrums = 0;
	[ibPvDrum reloadAllComponents];
	MiSegDrums = iDrums;
	// ibPvDrum は、以下のアニメーションに対応しない。

	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	// アニメ終了時の位置をセット
	
	// Entryセル表示　＜＜この中でpickerView再描画
	[self MvDrumButtonShow];

	// アニメ開始
	[UIView commitAnimations];
}

- (void)MvDrumButtonDragEnter:(UIButton *)button;
{
	AzLOG(@"MvDrumButtonDragEnter: button.tag=%d", (int)button.tag);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)MvButtonFormula:(NSInteger)iKeyTag  // 数式へのキー入力処理
{
	AzLOG(@"MvButtonFormula: iKeyTag=(%d)", iKeyTag);
	
	// これ以降、localPool管理エリア
	NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
	@try {
		BOOL bCalcing = NO; // YES=再計算する
		[self MvFormulaBlankMessage:NO];
		//
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
				ibTvFormula.text = [ibTvFormula.text stringByAppendingFormat:@"%d", (int)iKeyTag];
				bCalcing = YES; // 再計算する
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
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:NUM_DECI];
				break;
				
			case KeyTAG_00: // [00]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@"00"];
				bCalcing = YES; // 再計算する
				break;
				
			case KeyTAG_000: // [000]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@"000"];
				bCalcing = YES; // 再計算する
				break;
				
			case KeyTAG_SIGN: // [+/-]
				if ([ibTvFormula.text hasSuffix:OP_ADD]) { // [+] ⇒ [-]
					ibTvFormula.text = [ibTvFormula.text substringToIndex:[ibTvFormula.text length]-1]; // BS
					ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_SUB];
				}
				else if ([ibTvFormula.text hasSuffix:OP_SUB]) { // [-] ⇒ [+]
					ibTvFormula.text = [ibTvFormula.text substringToIndex:[ibTvFormula.text length]-1]; // BS
					ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_ADD];
				}
				else {
					NSInteger i = [ibTvFormula.text length]-1;
					NSRange rg;
					for ( ; 0<i ; i-- ) {
						rg = NSMakeRange(i, 1);
						NSString *z = [ibTvFormula.text substringWithRange:rg];
						if ([z compare:@"0"]==NSOrderedAscending || [z compare:@"9"]==NSOrderedDescending) { // <"0" or "9"<
							if ([z isEqualToString:OP_ADD]) {
								// [+] ⇒ [-]置換
								rg = NSMakeRange(i, 1);
								ibTvFormula.text = [ibTvFormula.text stringByReplacingCharactersInRange:rg 
																							 withString:OP_SUB];
							}
							else if ([z isEqualToString:OP_SUB]) { 
								// [-] ⇒ [+]置換
								rg = NSMakeRange(i, 1);
								ibTvFormula.text = [ibTvFormula.text stringByReplacingCharactersInRange:rg 
																							 withString:OP_ADD];
							}
							else {
								// [-]挿入
								rg = NSMakeRange(i+1, 0);
								ibTvFormula.text = [ibTvFormula.text stringByReplacingCharactersInRange:rg 
																							 withString:OP_SUB];
							}
							break;
						}
						else if (i==0) {
							// [-]挿入
							rg = NSMakeRange(0, 0);
							ibTvFormula.text = [ibTvFormula.text stringByReplacingCharactersInRange:rg 
																						 withString:OP_SUB];
						}
					}
				}
				bCalcing = YES; // 再計算する
				break;
				
			case KeyTAG_PERC: // [%]パーセント ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@"÷100"];
				bCalcing = YES; // 再計算する
				break;
			case KeyTAG_PERM: // [‰]パーミル ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@"÷1000"];
				bCalcing = YES; // 再計算する
				break;
			case KeyTAG_ROOT: // [√]ルート
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_ROOT];
				break;
			case KeyTAG_LEFT: // [(]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@"("];
				break;
			case KeyTAG_RIGHT: // [)]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:@")"];
				bCalcing = YES; // 再計算する
				break;
				
				//---------------------------------------------[100]-[199] Operators
			case KeyTAG_ANSWER: // [=]
				bCalcing = YES; // 再計算する
				break;
				
			case KeyTAG_PLUS: // [+]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_ADD];	break;
			case KeyTAG_MINUS: // [-]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_SUB];	break;
			case KeyTAG_MULTI: // [×]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_MULT];	break;
			case KeyTAG_DIVID: // [÷]
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:OP_DIVI];	break;
				
			case KeyTAG_GT: // [GT] Ground Total: 1ドラムの全[=]回答値の合計
				if ([ibTvFormula.text hasPrefix:@"("] && [ibTvFormula.text hasSuffix:@")"]) {
					// 大外カッコを外す
					NSRange rg = NSMakeRange(1, [ibTvFormula.text length]-2);
					ibTvFormula.text = [ibTvFormula.text substringWithRange:rg];
				} else {
					// 大外カッコを付ける
					ibTvFormula.text = [NSString stringWithFormat:@"(%@)", ibTvFormula.text];
				}
				break;
				
				//---------------------------------------------[200]-[299] Functions
			case KeyTAG_AC: // [AC]
				ibTvFormula.text = @"";
				ibLbFormAnswer.text = @"=";
				break;
				
			case KeyTAG_BS: { // [BS]
				if (0 < [ibTvFormula.text length]) {
					ibTvFormula.text = [ibTvFormula.text substringToIndex:[ibTvFormula.text length]-1];
					bCalcing = YES; // 再計算する
				}
			} break;
				
			case KeyTAG_SC: { // [SC] Section Clear：数式では1セクション（直前の演算子まで）クリア
				NSString *z;
				NSRange rg;
				NSInteger idx = [ibTvFormula.text length] - 1;
				for ( ; 0<=idx ; idx--) {
					z = [ibTvFormula.text substringWithRange:NSMakeRange(idx,1)];
					rg = [@"0123456789." rangeOfString:z];
					if (rg.length==0) break;
				}
				if (0<idx) {
					ibTvFormula.text = [ibTvFormula.text substringToIndex:idx];
				} else {
					ibTvFormula.text = @"";
				}
			}	break;
				
			case KeyTAG_AddTAX: // [+Tax] 税込み
			case KeyTAG_SubTAX: // [-Tax] 税抜き
			{
				NSString *zAns = stringFormatter([CalcFunctions zAnswerFromFormula:ibTvFormula.text], YES);
				if (zAns) {
					if (iKeyTag==KeyTAG_AddTAX) {
						ibTvFormula.text = [NSString stringWithFormat:@"(%@)×%.3f", ibTvFormula.text, MfTaxRate];
					} else {
						ibTvFormula.text = [NSString stringWithFormat:@"(%@)÷%.3f", ibTvFormula.text, MfTaxRate];
					}
					bCalcing = YES; // 再計算する
				}
			}	break;
		}
		
		if (bCalcing) {
			// 再計算
			ibLbFormAnswer.text = [NSString stringWithFormat:@"= %@",
								   stringFormatter([CalcFunctions zAnswerFromFormula:ibTvFormula.text], YES)];
		}
		[self MvFormulaBlankMessage:YES];
	}
	@finally { //*****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!
		[localPool release];
	}
}

// Memory関係キー入力処理
- (void)vButtonMemory:(Drum *)drum withTag:(NSInteger)iKeyTag withCopyNumber:(NSString *)zCopyNumber
{
	switch (iKeyTag) {
		case KeyTAG_MCLEAR: // [MClear]
			if (0 < [[UIPasteboard generalPasteboard].string length]) {
				[UIPasteboard generalPasteboard].string = @"";
			} 
			else if (MiSvUpperPage==0 && ![drum.entryOperator hasPrefix:OP_ANS]) { // [=]でない
				[drum.entryNumber setString:@""];
			}
			
			if (KeyTAG_MSTORE_Start <= ibBuMemory.tag && ibBuMemory.tag <= KeyTAG_MSTROE_End) {
				// MemoryKey へ登録する
				//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
				NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
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
				if (RaPadKeyButtons) { // iPad専用メモリーもクリアする
					for (KeyButton *bu in RaPadKeyButtons) {
						if (bu.tag == ibBuMemory.tag) {
							[bu setTitle:[NSString stringWithFormat:@"M%d", (int)(bu.tag - KeyTAG_MSTORE_Start)]
								forState:UIControlStateNormal];
#ifdef AzMAKE_SPLASHFACE
							bu.alpha = 0.4; // Memory nothing
#else
							bu.alpha = KeyALPHA_MSTORE_OFF; // Memory nothing
#endif
							//break; 同じキーが複数割り当てられている可能性があるので最後までいく
						}
					}
				} else {
					//[self MvKeyboardPage1Alook0]; // iPhoneのときだけ「しゃくる」
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
			else if (MiSvUpperPage==0 && 0 < [drum.entryNumber length]) {
				// entry値をコピーする　　＜＜stringFormatterを通すため、Mutable ⇒ NSString 変換が必要＞＞
				[UIPasteboard generalPasteboard].string = stringFormatter([NSString stringWithString:drum.entryNumber], YES);
			}
			else if	(MiSvUpperPage==1 && 2 < [ibLbFormAnswer.text length]) {
				[UIPasteboard generalPasteboard].string = [ibLbFormAnswer.text substringFromIndex:2]; // 先頭の"= "を除く
			}
			else break;
			//
			
			if (0 < [[UIPasteboard generalPasteboard].string length]) {
				// [UIPasteboard generalPasteboard].string を 未使用メモリーKey へ登録する
				ibBuMemory.tag = 0; // MClear
				//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
				NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
				NSInteger iSavedTag = (-1);
				
				if (RaPadKeyButtons) { // iPad専用メモリー優先にセットする　＜＜たいていiPhoneメモリ数より多いから＞＞
					for (KeyButton *bu in RaPadKeyButtons) {
						if ([bu.titleLabel.text hasPrefix:@"M"]) { // 未使用メモリを探す
							iSavedTag = bu.tag;  // 未使用メモリ発見
							// アニメーション
							CGRect rcEnd = bu.frame; // 最終位置
                            //UIButton *buEntry = [RaDrumButtons objectAtIndex:entryComponent];
                            //CGRect rc = buEntry.frame; // 開始位置
                            //rc.origin.x += (rc.size.width - bu.frame.size.width);
                            //bu.frame = rc;
							bu.frame = ibBuMemory.frame;
                            
							// アニメ準備
							[UIView beginAnimations:nil context:NULL];
							[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
							[UIView setAnimationDuration:0.7];
							// アニメ終了時の位置をセット
							bu.frame = rcEnd;
							// アニメ開始
							[UIView commitAnimations];
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
				if (RaPadKeyButtons) { // iPad専用メモリーにセットする
					for (KeyButton *bu in RaPadKeyButtons) {
						if (bu.tag == iSavedTag) {
							[bu setTitle:[UIPasteboard generalPasteboard].string
								forState:UIControlStateNormal];
							bu.alpha = KeyALPHA_MSTORE_ON; // Memory OK
							//break; 2個以上連結しているため最後まで調べて全て更新する
						}
					}
				} else {
					//[self MvKeyboardPage1Alook0]; // iPhoneのときだけ「しゃくる」
				}
			}
			break;
			
		case KeyTAG_MPASTE: { // [Paste]　　＜＜ibBuMemoryから呼び出しているので.tagの変更に注意＞＞
			if (MiSvUpperPage==0) {
				if ([drum.entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
					if (![drum vNewLine:OP_START]) break; // entryをarrayに追加し、entryを新規作成する
				}
				NSString *str = stringAzNum([UIPasteboard generalPasteboard].string);
				[drum.entryNumber setString:str]; // Az数値文字列をセット
			}
			else if (MiSvUpperPage==1) {
				[self MvFormulaBlankMessage:NO];
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:
									stringAzNum([UIPasteboard generalPasteboard].string)];
				// 再計算
				ibLbFormAnswer.text = [NSString stringWithFormat:@"= %@",
									   stringFormatter([CalcFunctions zAnswerFromFormula:ibTvFormula.text], YES)];
			}
			// アニメーション不要
		}	break;
			
		case KeyTAG_M_PLUS: // [M+]
		case KeyTAG_M_MINUS: // [M-]
		case KeyTAG_M_MULTI: // [M×]
		case KeyTAG_M_DIVID: // [M÷]
			if (MiSvUpperPage != 0) break; // Drumのみ
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
					[drum vEnterOperator:OP_ANS];
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
				switch (iKeyTag) {
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
						[UIPasteboard generalPasteboard].string = NSLocalizedString(@"Divide by zero", nil);
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
						if (RaPadKeyButtons) { // iPad専用メモリー優先にセットする　＜＜たいていiPhoneメモリ数より多いから＞＞
							for (KeyButton *bu in RaPadKeyButtons) {
								if (bu.tag == ibBuMemory.tag) {
									[bu setTitle:[UIPasteboard generalPasteboard].string
										forState:UIControlStateNormal];
									//2個以上連結しているため最後まで調べて全て更新する
								}
							}
						}
						//NSArray *aKeys = [ibScrollLower subviews]; // addSubViewした順（縦書きで左から右）に収められている。
						NSArray *aKeys = [mKeyView subviews]; // addSubViewした順（縦書きで左から右）に収められている。
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


#pragma mark - IBAction


/*　[1.0.8]　UITapGestureRecognizer対応により以下没。
//[bu addTarget:self action:@selector(ibButtonDrag:) forControlEvents:UIControlEventTouchDragExit]; 
- (IBAction)ibButtonDrag:(KeyButton *)button // ダブルスイープスクロールのため
{
	NSLog(@"ibButtonDrag: Col=%d", (int)button.iCol);
	//ibScrollLower.scrollEnabled = YES; //スクロール許可
	//ibScrollLower.delaysContentTouches = YES; //スクロール操作検出のため0.5s先取する ⇒ これによりキーレスポンス低下する
}*/

- (IBAction)ibButton:(KeyButton *)button   // KeyButton TouchUpInside処理メソッド
{
	bDrumRefresh = YES;
	
	[self audioPlayer:@"Tock.caf"];  // キークリック音
	
	if (RaKeyMaster) {				// キーレイアウト変更モード // ドラム選択中のキーを割り当てる
		[self MvKeyLayoute:button];
		return;
	}
	else {	// 計算モードのとき、スクロールロックする
		//キー入力が始まるとスクロール禁止にする
		//ibScrollLower.scrollEnabled = NO; //スクロール禁止
		//ibScrollLower.delaysContentTouches = NO; //スクロール操作検出のため0.5s先取中止 ⇒ これによりキーレスポンス向上する
	}
	
	Drum *drum = [RaDrums objectAtIndex:entryComponent];
	
	NSString *zCopyNumber = nil; // 遡って数値を[Copy]するのに備えて保持する
	
	// ドラム逆回転時の処理
	if (MiSvUpperPage==0 && MiSegReverseDrum==1 && bDramRevers) {
		//bDramRevers = NO;  [Copy]後、遡った行が維持されるようにリマークした
		NSInteger iRow = [ibPvDrum selectedRowInComponent:entryComponent]; // 現在の選択行
		if (0 <= iRow && iRow < [drum count]) 
		{	// ドラム逆回転やりなおしモード ⇒ formulaとentryを選択行まで戻す
			// 遡った行の数値を「数値文字化」して copy autorelese object として保持する。
			zCopyNumber = stringAzNum([drum zNumber:iRow]);
			//
			[drum vRemoveFromRow:iRow];	// iRow以降削除＆リセット
		}
	}
	
	// entry行より下が選択されても、通常通りentry行入力にする。 
	// [=]の後に数値キー入力すると改行(新セクション)になる。
	
	// キー入力処理   先に if (button.tag < 0) return; 処理済み
	if (button.tag <= 9) { //[1.0.2]数値キーレスポンス向上のため
		if (MiSvUpperPage==0) {
			[drum entryKeyButton:button];
			[ibPvDrum reloadComponent:entryComponent];	//ドラム再表示
			[ibPvDrum selectRow:[drum count] inComponent:entryComponent animated:YES]; //Fix//これが無いと[=]後の数値がカソール下に残る
		} 
		else if (MiSvUpperPage==1) {
			[self MvButtonFormula:button.tag];
		}
		return;	// 以下の処理を通らない分だけレス向上
	} 
	else if (button.tag <= KeyTAG_STANDARD_End) { //[KeyTAG_STANDARD_Start-KeyTAG_STANDARD_End]---------Standard Keys
		if (MiSvUpperPage==0) {
			[drum entryKeyButton:button];
		} 
		else if (MiSvUpperPage==1) {
			[self MvButtonFormula:button.tag];
		}
	} 
	else if (button.tag <= KeyTAG_MEMORY_End) { //[KeyTAG_MEMORY_Start-KeyTAG_MEMORY_End]----------Memory Keys
		[self vButtonMemory:drum  withTag:button.tag  withCopyNumber:zCopyNumber];
	}
	else if (button.tag <= KeyTAG_MSTROE_End) { //[KeyTAG_MSTORE_Start-KeyTAG_MSTROE_End]-------Memory STORE Keys
		if (button && ![button.titleLabel.text hasPrefix:@"M"]) {
			// "M"でない。 メモリ値有効 ⇒ ペーストボードへ
			[UIPasteboard generalPasteboard].string = button.titleLabel.text;
			ibBuMemory.tag = button.tag;
			// [Paste]
			if (MiSvUpperPage==0) {
				if ([drum.entryOperator isEqualToString:OP_ANS]) { // [=]ならば新セクションへ改行する
					// entryをarrayに追加し、entryを新規作成する
					if ([drum vNewLine:OP_START]==NO) return; // ERROR
				}
				[drum.entryNumber setString:stringAzNum([UIPasteboard generalPasteboard].string)]; // Az数値文字列をセット
			}
			else if (MiSvUpperPage==1) {
				[self MvFormulaBlankMessage:NO];
				ibTvFormula.text = [ibTvFormula.text stringByAppendingString:
									stringAzNum([UIPasteboard generalPasteboard].string)];
				// 再計算
				ibLbFormAnswer.text = [NSString stringWithFormat:@"= %@",
									   stringFormatter([CalcFunctions zAnswerFromFormula:ibTvFormula.text], YES)];
			}
			// アニメーション：他のボタン同様にentryに際してはアニメなし
		}
	}
	else if (KeyTAG_UNIT_Start <= button.tag) { //[KeyTAG_UNIT_Start-KeyTAG_UNIT_End
		if (MiSvUpperPage==0) {
			[drum entryUnitKey:button];
			//[self MvKeyUnitGroup:button]; // 同系列単位のボタンをハイライト ＆ 以外をノーマルに戻す
		} 
	}
	
	if (MiSvUpperPage==0 && bDrumRefresh) { // ドラム再表示
		[ibPvDrum reloadComponent:entryComponent];
		[ibPvDrum selectRow:[drum count] inComponent:entryComponent animated:YES];
	}
	// [M]ラベル表示
	[self MvMemoryShow];
	
#ifdef GD_Ad_ENABLED
	if (MiSvUpperPage==0) { // [AC]
		if (button.tag==KeyTAG_AC) { // [AC]
			bADbannerTopShow = YES;
			[self MvShowAdApple:YES AdMob:YES];
		} else {
			bADbannerTopShow = NO; //[1.0.1]//入力が始まったので[AC]が押されるまで非表示にする
			[self MvShowAdApple:NO AdMob:NO];
		}
	}
#endif
}

- (IBAction)ibBuGetDrum:(UIButton *)button	// ドラム ⇒ 数式 転記
{
	//[0.3]ドラム式を数式にして ibTvFormula へ送る
	Drum *drum = [RaDrums objectAtIndex:entryComponent];
	NSString *zFormula = [drum zFormulaCalculator];
	if (0 < [zFormula length]) {
		[self MvFormulaBlankMessage:NO];
		ibTvFormula.text = zFormula;
		// 再計算
		ibLbFormAnswer.text = [NSString stringWithFormat:@"= %@",
							   stringFormatter([CalcFunctions zAnswerFromFormula:zFormula], YES)];
	}
}

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
	// キーレイアウト変更モードならば、現ページを保存する
	if (RaKeyMaster) {// !=nil キーレイアウト変更モード
		[self MvSaveKeyView:mKeyView];

		// RdicAllKeys　を　standardUserDefaults へ保存する　＜＜アプリがアップデートされても保持される＞＞
		NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
		[userDef setObject:RdicAllKeys forKey:GUD_KeyboardSet];
		if ([userDef synchronize] != YES) {
			NSLog(@"RdicAllKeys synchronize: ERROR");
		}
	}
	
	//AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	mAppDelegate.ibSettingVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;  // 水平回転
	[self presentModalViewController:mAppDelegate.ibSettingVC animated:YES];
}

- (IBAction)ibBuInformation:(UIButton *)button
{
	//AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (bPad) {
		mAppDelegate.ibInformationVC.modalPresentationStyle = UIModalPresentationFormSheet; // iPad画面1/4サイズ
	} else {
		mAppDelegate.ibInformationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	[self presentModalViewController:mAppDelegate.ibInformationVC animated:YES];
}


#pragma mark - delegate UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	if (RaKeyMaster) {
		return [RaKeyMaster count];
	}
	
	assert(MiSegDrums <= DRUMS_MAX);
	return MiSegDrums;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (RaKeyMaster) {
		return [[RaKeyMaster objectAtIndex:component] count]; 
	}

#ifdef AzMAKE_SPLASHFACE
	return 0;
#else
	Drum *dm = [RaDrums objectAtIndex:component];
	return ROWOFFSET + [dm count] + 1;  // (ROWOFFSET)タイトル行 + Drum(array行数) + 1(entry行)
#endif
}


// 幅
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//float fWid = self.view.frame.size.width - DRUM_LEFT_OFFSET*2; // DRUM_LEFT_OFFSET*2 = ドラム左右余白
	float fWid = ibPvDrum.frame.size.width - DRUM_LEFT_OFFSET*2; // DRUM_LEFT_OFFSET*2 = ドラム左右余白

	if (RaKeyMaster) {
		return (fWid / [RaKeyMaster count]) - DRUM_GAP;
	}

	if (bZoomEntryComponent) {
		float fWmin = PICKER_COMPONENT_WiMIN;
		if (bPad) fWmin *= 2.0;
		if (component == entryComponent) {  // entryComponentを拡大する
			return fWid - ((fWmin + DRUM_GAP) * (MiSegDrums-1));
		} else {
			return fWmin; // 1コンポーネントの表示最小幅
		}
	}
	return (fWid / MiSegDrums) - DRUM_GAP; // 均等
}


// 高さ
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	if (RaKeyMaster) {
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

	if (RaKeyMaster) { // キーボード変更モード
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
		lb.font = [UIFont boldSystemFontOfSize:DRUM_FONT_MAX];
		lb.text = [[[RaKeyMaster objectAtIndex:component] objectAtIndex:row] objectForKey:@"Text"];
		
		return vi;
	}
	
	// ドラタク通常モード
	assert(component < MiSegDrums);
	if (vi == nil) {
		vi = [[[UIView alloc] initWithFrame:CGRectMake(0,0,sz.width,32)] autorelease];
		// addSubview
		lb = [[UILabel alloc] initWithFrame:CGRectMake(5,0,sz.width-10,32)];
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
					lb.textAlignment = UITextAlignmentCenter;
					lb.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];    //-Condensed-ExtraBold  boldSystemFontOfSize:20];
					lb.text =  NSLocalizedString(@"Product Title",nil);
					break;
				case -1:
					lb.textAlignment = UITextAlignmentCenter;
					lb.font = [UIFont systemFontOfSize:12];
#ifdef AzFREE
					lb.text = [NSString stringWithFormat:@"%@ Free", NSLocalizedString(@"Product Localize",nil)];  //@"Free";   //NSLocalizedString(@" Azukid",nil);
#else
					lb.text =  NSLocalizedString(@"Product Localize",nil);
#endif
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
		assert(0<=iRow);
		Drum *drum = [RaDrums objectAtIndex:component];
		lb.textAlignment = UITextAlignmentRight;
		
		NSString *zOpe = [drum zOperator:iRow];
		if ([zOpe hasPrefix:OP_START]) {
#ifndef AzDEBUG
			if ([zOpe length]<=1) {
				zOpe = @"";  // 開始行の記号は非表示
			} else {
				zOpe = [zOpe substringFromIndex:1]; // OP_STARTより後の文字 [√]
			}
#endif
		} else if ([zOpe hasPrefix:OP_SUB]) {  // Unicode[002D]
			//zOpe = MINUS_SIGN; // Unicode[2212]
			// 演算子（OP_SUB=Unicode[002D]）を表示文字（MINUS_SIGN=Unicode[002D]）に置換する
			zOpe = [zOpe stringByReplacingOccurrencesOfString:OP_SUB withString:MINUS_SIGN];
		}
		
		NSString *zNum = [drum zNumber:iRow];
		if ([zNum length] <= 0) {
			lb.textColor = [UIColor blackColor];
			lb.font = [UIFont systemFontOfSize:DRUM_FONT_MAX];
			if (iRow < [drum count]) {	// drum.formula 表示
				lb.text = [NSString stringWithFormat:@"%@", zOpe];
			} else {
				lb.text = [NSString stringWithFormat:@"%@%@ ", 
						   stringFormatter([drum zAnswer], YES), zOpe]; // 回答＆演算子
			}
		} 
		else if ([zNum hasPrefix:@"@"]) {
			// 先頭が"@"ならば以降の文字列をそのまま表示する（エラーメッセージ表示）
			lb.textColor = [UIColor blackColor];
			lb.font = [UIFont systemFontOfSize:DRUM_FONT_MSG];
			lb.text = [zNum substringFromIndex:1]; // 先頭の"@"を除いて表示
		} 
		else {
			if ([zNum doubleValue] < 0.0) {
				lb.textColor = [UIColor redColor];
			} else {
				lb.textColor = [UIColor blackColor];
			}
			lb.font = [UIFont systemFontOfSize:DRUM_FONT_MAX];
			
			BOOL bFormat = (iRow < [drum count]) || [zOpe hasPrefix:OP_ANS];
			NSString *zUnit = [drum zUnit:iRow withPara:0]; // (0)表示単位
			lb.text = [NSString stringWithFormat:@"%@%@%@",
					   zOpe, 
					   stringFormatter(zNum, bFormat), // bFormat=NO ⇒ 入力通りに表示させる
					   zUnit];
		}
	}
	return vi;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (RaKeyMaster) { // キーボード変更モード
		// 他リセット
		for (int i=0; i<[RaKeyMaster count]; i++) {
			if (i != component) {
				[ibPvDrum selectRow:0 inComponent:i animated:YES];
			}
		}
		return;
	}
	
	Drum *drum = [RaDrums objectAtIndex:component];
	if ([drum count] <= row) {
		bDramRevers = NO;	// NO=「ドラム逆転やりなおしモード」を一時無効にする
	} else {
		bDramRevers = YES;	// YES=「ドラム逆転やりなおしモード」を許可
		drum.entryRow = row;
	}
}


#pragma mark - delegate UIScrollView
//=================================================================ibScrollUpper delegate
// スクロール開始したときに呼ばれる
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (scrollView==ibScrollUpper) {
		[ibTvFormula resignFirstResponder]; // キーボードを隠す

		//[self audioPlayer:@"mail-sent.caf"];  // Mail.appの送信音
		[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
	}
}

// スクロールして画面が静止したときに呼ばれる
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (scrollView==ibScrollUpper) {
		NSInteger iPrevUpper = MiSvUpperPage;
		MiSvUpperPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);

		if (iPrevUpper!=1 && MiSvUpperPage==1) {
			[CalcFunctions setCalcMethod:1]; // 数式側：常に (1)Formula にする
			// 全単位ボタンを無効にする
			[self GvKeyUnitGroupSI:@"" andSI:@""];
#ifdef GD_Ad_ENABLED
			[self MvShowAdApple:NO AdMob:YES];	
#endif
		}
		else if (iPrevUpper!=0 && MiSvUpperPage==0) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			MiSegCalcMethod = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
			[CalcFunctions setCalcMethod:MiSegCalcMethod];	// ドラム側：設定方式に戻す
			// 現ドラムの状態に従って、単位ボタンを有効にする
			Drum *drum = [RaDrums objectAtIndex:entryComponent];
			//[self GvKeyUnitGroupSI:[drum zUnitRebuild] andSI:nil];
			[drum GvEntryUnitSet];
#ifdef GD_Ad_ENABLED
			[self MvShowAdApple:YES AdMob:YES];	
#endif
		}
	}
	else { // ibScrollLower
		// 直前ページを破棄
		if (mKeyViewPrev) {
			[mKeyViewPrev removeFromSuperview];
			mKeyViewPrev = nil;
		}
	}
}


#pragma mark - delegate UITextView

// 数式(TextView)をタッチして拡張するときの高さ拡張量を返す
- (float)fPadKeyOffset 
{	// 日本語キーになるとファンクション行があらわれてMemoryとAnswer行の一部が隠れるが、通常Asciiキーなので問題にしない。
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		return 170; // ヨコ
	} else {
		return 260; // タテ
	}
}

//=================================================================ibTvFormula delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	AzLOG(@"--textViewDidBeginEditing:");
	ibScrollUpper.scrollEnabled = NO; // [Done]するまでスクロール禁止にする

	[self audioPlayer:@"unlock.caf"];  // ロック解除音

	//ibTvFormula.keyboardType = UIKeyboardTypeNumbersAndPunctuation;  どちらも効かず、上部ファンクションを消せない
	//[ibTvFormula setKeyboardType:UIKeyboardTypeNumbersAndPunctuation]; どちらも効かず、上部ファンクションを消せない
	// 今の所、手操作で UIKeyboardTypeNumbersAndPunctuation モードに変えてもらうしか無い。

	CGRect rc;
	// アニメ開始時の位置をセット
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.9];
	// アニメ終了時の位置をセット
	if (bPad) { // iPad
		float fOfs = [self fPadKeyOffset];
        rc = ibBuFormLeft.frame;    rc.origin.x -= 100;		ibBuFormLeft.frame = rc;	ibBuFormLeft.alpha = 0;
        rc = ibBuFormRight.frame;	rc.origin.x += 100;		ibBuFormRight.frame = rc;	ibBuFormRight.alpha = 0;
        rc = ibScrollLower.frame;	rc.origin.y += (fOfs+20);	ibScrollLower.frame = rc;
        rc = ibScrollUpper.frame;	rc.size.height += fOfs;	ibScrollUpper.frame = rc;
		rc = ibTvFormula.frame;		rc.size.height += fOfs;	ibTvFormula.frame = rc;
        rc = ibLbFormAnswer.frame;	rc.origin.y += fOfs;		ibLbFormAnswer.frame = rc;
        rc = ibBuMemory.frame;		rc.origin.y += fOfs;		ibBuMemory.frame = rc;
    } else {
        rc = ibBuFormLeft.frame;    rc.origin.x -= 100;		ibBuFormLeft.frame = rc;
        rc = ibBuFormRight.frame;	rc.origin.x += 100;		ibBuFormRight.frame = rc;
        rc = ibScrollLower.frame;	rc.origin.y += 100;		ibScrollLower.frame = rc;
        rc = ibTvFormula.frame;		rc.size.height += 27;	ibTvFormula.frame = rc;
        rc = ibLbFormAnswer.frame;	rc.origin.y += 27;		ibLbFormAnswer.frame = rc;
        rc = ibBuMemory.frame;		rc.origin.y += 27;		ibBuMemory.frame = rc;
    }

	[self MvFormulaBlankMessage:NO];
	// アニメ開始
	[UIView commitAnimations];
}

- (void)textViewAnimeDidStop
{	// アニメ終了後、
	[self audioPlayer:@"lock.caf"];  // ロック音
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	ibScrollUpper.scrollEnabled = YES; // スクロール許可

	CGRect rc;
	// アニメ開始時の位置をセット
	// アニメ準備
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];	// 戻りは早く

	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(textViewAnimeDidStop)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要

	// アニメ終了時の位置をセット
	if (bPad) { // iPad
		float fOfs = [self fPadKeyOffset];
        rc = ibBuFormLeft.frame;	rc.origin.x += 100;		ibBuFormLeft.frame = rc;	ibBuFormLeft.alpha = 1;
        rc = ibBuFormRight.frame;	rc.origin.x -= 100;		ibBuFormRight.frame = rc;	ibBuFormRight.alpha = 1;
        rc = ibScrollLower.frame;	rc.origin.y -= (fOfs+20);	ibScrollLower.frame = rc;
        rc = ibScrollUpper.frame;	rc.size.height -= fOfs;    ibScrollUpper.frame = rc;
        rc = ibTvFormula.frame;		rc.size.height -= fOfs;	ibTvFormula.frame = rc;
        rc = ibLbFormAnswer.frame;	rc.origin.y -= fOfs;		ibLbFormAnswer.frame = rc;
        rc = ibBuMemory.frame;		rc.origin.y -= fOfs;		ibBuMemory.frame = rc;
    } else {
        rc = ibBuFormLeft.frame;	rc.origin.x += 100;		ibBuFormLeft.frame = rc;
        rc = ibBuFormRight.frame;	rc.origin.x -= 100;		ibBuFormRight.frame = rc;
        rc = ibScrollLower.frame;	rc.origin.y -= 100;		ibScrollLower.frame = rc;
        rc = ibTvFormula.frame;		rc.size.height -= 27;	ibTvFormula.frame = rc;
        rc = ibLbFormAnswer.frame;	rc.origin.y -= 27;		ibLbFormAnswer.frame = rc;
        rc = ibBuMemory.frame;		rc.origin.y -= 27;		ibBuMemory.frame = rc;
    }

	[self MvFormulaBlankMessage:YES];

	// アニメ開始
	[UIView commitAnimations];
}

- (void)textViewDidChange:(UITextView *)textView
{
	AzLOG(@"--textViewDidChange:");
	// 再計算
    if (bFormulaFilter) {
        bFormulaFilter = NO;
        ibTvFormula.text = [CalcFunctions zFormulaFilter:ibTvFormula.text];
    }
	ibLbFormAnswer.text = [NSString stringWithFormat:@"= %@",
						   stringFormatter([CalcFunctions zAnswerFromFormula:ibTvFormula.text], YES)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSLog(@"--shouldChangeTextInRange-----[%@]", text);
	
	if ([text length]<=0) { // [BS]
		return YES;
	}
	
	if ([text hasPrefix:@"\n"]) { // [Done]
		[textView resignFirstResponder]; // キーボードを隠す 
		return NO;
	}
    if (FORMULA_MAX_LENGTH < [textView.text length] + [text length] - range.length) {
		ibLbFormAnswer.text = @"= Game Over =";
        return NO;
    }
    if (1 < [text length]) {
        // ペーストによる文字列ならば無条件許可する
        bFormulaFilter = YES;   // [CalcFunctions zFormulaFilter:]処理必要
        // この直後、textViewDidChange が呼び出される。
        return YES;
	}
	
	const NSString *zList = @"0123456789. +-×÷*/()";  // 入力許可文字
	NSRange rg = [zList rangeOfString:text];
	if (rg.length==1) {
		[self MvFormulaBlankMessage:NO];
		return YES; // 入力許可文字
	}
	return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	AzLOG(@"--textViewShouldEndEditing");
	[ibTvFormula resignFirstResponder]; // キーボードを隠す
	return YES;
}

#pragma mark - AVAudioPlayer
- (void)audioPlayer:(NSString*)filename
{
	if (MfAudioVolume <= 0.0 || 1.0 < MfAudioVolume) return;
#if (TARGET_IPHONE_SIMULATOR)
	// シミュレータで動作している場合のコード
	NSLog(@"AVAudioPlayer -　SIMULATOR");
#else
	// 実機で動作している場合のコード
 	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@", filename]];
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	player.volume = MfAudioVolume;  // 0.0〜1.0
	player.delegate = self;		// audioPlayerDidFinishPlaying:にて release するため。
	[player play];
#endif
}

#pragma mark  <AVAudioPlayerDelegate>

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{	// 再生が終了したとき、破棄する	＜＜ シミュレータでは呼び出されない
	NSLog(@"- audioPlayerDidFinishPlaying -");
	player.delegate = nil;
    [player release];
}

- (void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer*)player error:(NSError*)error
{	// エラー発生
	NSLog(@"- audioPlayerDecodeErrorDidOccur -");
	player.delegate = nil;
	[player release];
}

#ifdef GD_Ad_ENABLED
#pragma mark - iAd, AdMob

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	//AzLOG(@"=== bannerViewDidLoadAd ===");
	bADbannerIsVisible = YES; // iAd取得成功（広告内容あり）
	[self MvShowAdApple:YES AdMob:YES];
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	AzLOG(@"=== didFailToReceiveAdWithError ===");
	[self MvShowAdApple:NO AdMob:YES];		// iAdなし、AdMob表示
	bADbannerIsVisible = NO; // iAd取得失敗（広告内容なし）
}

/*
 // iAd 広告表示を閉じて元に戻る前に呼ばれる
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 AzLOG(@"===== bannerViewActionDidFinish =====");
 banner.hidden = YES;	// 一度見れば非表示にする
 }
 */

- (void)MvShowAdApple:(BOOL)bApple AdMob:(BOOL)bMob
{
	NSLog(@"=== MvShowAdApple[%d] AdMob[%d] ===", bApple, bMob);
	
	if (bADbannerTopShow==NO) {
		bApple = NO;
		bMob = NO;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.2];
	
	if (NSClassFromString(@"ADBannerView") && RiAdBanner) {
		if (bApple && bADbannerIsVisible) {
			RiAdBanner.frame = ibPvDrum.frame;
			[ibScrollUpper bringSubviewToFront:RiAdBanner]; // 上層にする
			bMob = NO; // iAd表示優先
		} else {
			RiAdBanner.frame = CGRectMake(0,-70, 0,0);
		}
	}
	
	if (RoAdMobView) {
		CGRect rc = RoAdMobView.frame;
		if (bMob && MiSvUpperPage==0) { // Upper(0)pageに表示する
			if (bPad) {
				rc.origin.x = (ibScrollUpper.frame.size.width - rc.size.width)/2.0; // (0)ページ中央へ
			} else {
				rc.origin.x = 0;
			}
		} else { // Upper(1)pageに表示する　AdMobは非表示無し
			if (bPad) { // iPad
				//rc.origin.x = ibScrollUpper.frame.size.width + 20; // (1)ページ左端へ
				rc.origin.x = ibScrollUpper.frame.size.width + (ibScrollUpper.frame.size.width - rc.size.width)/2.0; // (1)ページ中央へ
			} else {
				rc.origin.x = ibScrollUpper.frame.size.width; // (1)ページ
			}
		}
		rc.origin.y = 0;
		RoAdMobView.frame = rc;
	}
	
	[UIView commitAnimations];
}

#endif

@end








