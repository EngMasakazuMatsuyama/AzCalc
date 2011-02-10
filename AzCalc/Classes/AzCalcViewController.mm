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

#define	DRUMS_MAX				5		// この数のDrumsオブジェクトを常に生成する
#define	PICKER_WiMAX			298		// Pickerの最大幅
#define	PICKER_COMPONENT_WiMIN	40		// 1コンポーネントの表示最小幅

#define ROWOFFSET	 2
#define DECIMALMAX  12

#define MINUS_SIGN	@"−" // Unicode[2212] 表示用文字　[002D]より大きくするため


@interface AzCalcViewController (PrivateMethods)
- (void)vDrumButtonDisplay;
- (void)ibLbMemoryDisplay;
- (void)vDrumButton:(UIButton *)button;
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
	[arrayDrums release];
	[arrayButtons release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	// arrayButtonsオブジェクトは、SubViewなので、毎回生成する。 viewDidUnloadで破棄する。
	assert(arrayButtons==nil);
	NSMutableArray *maButtons = [NSMutableArray new];
	// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
	for (int i=0; i<DRUMS_MAX; i++) {
		// ドラム切り替えボタン(透明)をaddSubView
		UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
		bu.tag = i;
		//bu.superview.alpha = 0.0; // 透明
		bu.alpha = 0.3; // 半透明 (0.0)透明にするとクリック検出されなくなる
		[bu addTarget:self action:@selector(vDrumButton:) forControlEvents:UIControlEventTouchUpInside];
		[maButtons addObject:bu];
		[self.view addSubview:bu];
		[bu release];
	}
	arrayButtons = [[NSArray alloc] initWithArray:maButtons];	
	[maButtons release];

	if (!arrayDrums) {
		// Drumオブジェクトは、SubViewではないので、最初に1度だけ生成し、viewDidUnloadでは破棄しない。
		NSMutableArray *maDrums	= [NSMutableArray new];
		// 初期ドラム生成：常にDRUMS_MAX個生成し、表示はその一部または全部
		for (int i=0; i<DRUMS_MAX; i++) {
			// ドラムインスタンス生成
			Drum *drum = [Drum new];
			[maDrums addObject:drum];
			[drum release];
		}
		arrayDrums = [[NSArray alloc] initWithArray:maDrums];		
		[maDrums release];
		
		entryComponent = 0;
		bDramRevers = NO;
		bZoomEntryComponent = NO;
	}

	// IBコントロールの初期化
	ibPicker.delegate = self;
	ibPicker.dataSource = self;
	ibPicker.showsSelectionIndicator = NO;
	
	CGRect theBannerFrame = self.view.frame;
	theBannerFrame.origin.y = -52;  // viewの外へ出す
	ibADBannerView.frame = theBannerFrame;	
	
	//[self iAdOff];
	bADbannerIsVisible = NO;
	bADbannerFirstTime = YES;
}

// 裏画面(非表示)状態のときにメモリ不足が発生するとコールされるので、viewDidLoadで生成したOBJを解放する
- (void)viewDidUnload
{
    [super viewDidUnload];
	// IB(xib)で生成されたOBJは自動的に解放＆再生成されるので触れないこと。
	
	// [arrayButtons release];不要　SubViewなので自動的に破棄されている。 viewDidLoadにて生成
	arrayButtons = nil;  // 自動的に破棄されているが、この変数は不燃なのでここで無効(nil)にしておく。
	
	// arrayDrums は、SubViewではないから破棄しない。
	
	// この後、viewDidLoadがコールされて、改めてOBJ生成される
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Setting
	MiSegDrums = 1 + (NSInteger)[defaults integerForKey:GUD_Drums];	// ドラム数 ＜＜セグメント値に +1 している＞＞
	if (DRUMS_MAX < MiSegDrums) MiSegDrums = DRUMS_MAX;  // 生成数を超えないように
	MiSegCalcMethod = (NSInteger)[defaults integerForKey:GUD_CalcMethod];
	MiSegDecimal = (NSInteger)[defaults integerForKey:GUD_Decimal];
	MiSegRound = (NSInteger)[defaults integerForKey:GUD_Round];
	MiSegReverseDrum = (NSInteger)[defaults integerForKey:GUD_ReverseDrum];
	// Option
	switch ((NSInteger)[defaults integerForKey:GUD_GroupingSeparator]) {
		case 0:
			formatterGroupingSeparator( @"," );
			break;
		case 1:
			formatterGroupingSeparator( @"'" ); // [']
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

	formatterGroupingSize( (int)[defaults integerForKey:GUD_GroupingSize] );				// Default[3]
	
//	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
//	UIButton *bu = [appDelegate.viewController viewWithTag:16]; // (16)[.]小数点
	UIButton *bu = (UIButton *)[self.view viewWithTag:16]; // (16)[.]小数点
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
	
	// reSetting
	for (Drum *drum in arrayDrums) {
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
	[self ibLbMemoryDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self iAdOn];
}


// Entryセル表示
- (void)vDrumButtonDisplay
{
	float fWiMin, fWiMax;
	if (bZoomEntryComponent) {  // entryComponentを拡大する
		fWiMin = PICKER_COMPONENT_WiMIN; // 1コンポーネントの表示最小幅
		fWiMax = PICKER_WiMAX - (PICKER_COMPONENT_WiMIN * (MiSegDrums-1));
	} else {
		fWiMin = PICKER_WiMAX / MiSegDrums;
		fWiMax = fWiMin; // 均等
	}
	float fX = 14;
	int i = 0;
	for ( ; i<MiSegDrums ; i++) {
		UIButton *bu = [arrayButtons objectAtIndex:i];
		bu.hidden = NO;
		if (i == entryComponent) {
			bu.frame = CGRectMake(fX,155, fWiMax-6,30);
			bu.backgroundColor = [UIColor greenColor];
			// Next
			fX += (fWiMax + 2);
		} else {
			bu.frame = CGRectMake(fX,50, fWiMin-6,150);  // iAdより下に配置
			//bu.backgroundColor = [UIColor yellowColor];
			bu.backgroundColor = [UIColor clearColor];
			// Next
			fX += (fWiMin + 2);
		}
	}
	for ( ; i<DRUMS_MAX ; i++) {
		UIButton *bu = [arrayButtons objectAtIndex:i];
		bu.hidden = YES;
		//bu.frame = CGRectMake(0,0, 0,0);
	}
	[ibPicker reloadAllComponents];
}

// [M]ラベル表示
- (void)ibLbMemoryDisplay
{
	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.dMemory == 0.0) {
		ibLbMemory.hidden = YES;
	} else {
		ibLbMemory.text = [NSString stringWithFormat:@"M %@", 
						   stringFormatter([NSString stringWithFormat:FLOAT_FORMAT, appDelegate.dMemory], YES)];
		ibLbMemory.hidden = NO;
	}
}

- (void)vDrumButtonTap1Clear
{
	bDrumButtonTap1 = NO;
}

- (void)vDrumButton:(UIButton *)button
{
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

	
	if (entryComponent != button.tag) {
		entryComponent = button.tag;	// ドラム切り替え
		bZoomEntryComponent = NO;  // 均等サイズに戻す
	}
	
	// 以下の処理をしないと pickerView が再描画されない。
	NSInteger iDrums = MiSegDrums;
	MiSegDrums = 0;
	[ibPicker reloadAllComponents];
	MiSegDrums = iDrums;
	
	// Entryセル表示　＜＜この中でpickerView再描画
	[self vDrumButtonDisplay];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (IBAction)ibBuSetting:(UIButton *)button
{
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[UIView setAnimationDuration:3.0];

	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ibSettingVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;  // 水平回転
												// UIModalTransitionStylePartialCurl; // めくれ上がる（計算式表示に使う）
	appDelegate.ibInformationVC.view.hidden = YES;
	appDelegate.ibSettingVC.view.hidden = NO;
	appDelegate.ibOptionVC.view.hidden = YES;
	[self presentModalViewController:appDelegate.ibSettingVC animated:YES];

//	[UIView commitAnimations];
}

- (IBAction)ibBuInformation:(UIButton *)button
{
	AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ibInformationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	appDelegate.ibInformationVC.view.hidden = NO;
	appDelegate.ibSettingVC.view.hidden = YES;
	appDelegate.ibOptionVC.view.hidden = YES;
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
	assert(MiSegDrums <= DRUMS_MAX);
	return MiSegDrums;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	Drum *dm = [arrayDrums objectAtIndex:component];
	
	return ROWOFFSET + [dm count] + 1;  // (ROWOFFSET)タイトル行 + Drum(array行数) + 1(entry行)
}


 // 幅
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (bZoomEntryComponent) {
		if (component == entryComponent) {  // entryComponentを拡大する
			return PICKER_WiMAX - (PICKER_COMPONENT_WiMIN * (MiSegDrums-1));
		} else {
			return PICKER_COMPONENT_WiMIN; // 1コンポーネントの表示最小幅
		}
	}
	return PICKER_WiMAX / MiSegDrums; // 均等
}


// 高さ
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
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
	assert(component < MiSegDrums);

	UIView *vi = reView;  // Viewが再利用されるため
	UILabel *lb = nil;
	CGSize sz = [pickerView rowSizeForComponent:component];

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
		Drum *drum = [arrayDrums objectAtIndex:component];
		lb.textAlignment = UITextAlignmentRight;
		
		if (iRow < [drum count]) {			// drum.formula 表示
			NSString *zOpe = [drum.formulaOperators objectAtIndex:iRow]; // 計算セクション開始行では常に" "スペース
			if ([zOpe isEqualToString:OP_START]) {
				zOpe = @"";  // 開始行の記号は非表示
			} else if ([zOpe isEqualToString:OP_SUB]) {  // Unicode[002D]
				zOpe = MINUS_SIGN; // Unicode[2212]
			}
			if ([[drum.formulaNumbers objectAtIndex:iRow] length] <= 0) {
				lb.textColor = [UIColor blackColor];
				lb.font = [UIFont systemFontOfSize:30];
				lb.text = [NSString stringWithFormat:@"%@ ", zOpe];
			} 
			else {
				double dNum = [[drum.formulaNumbers objectAtIndex:iRow] doubleValue];
				if (dNum < 0) {
					lb.textColor = [UIColor redColor];
				} else {
					lb.textColor = [UIColor blackColor];
				}
				lb.font = [UIFont systemFontOfSize:30];
				lb.text = [NSString stringWithFormat:@"%@ %@", zOpe, 
						   stringFormatter([drum.formulaNumbers objectAtIndex:iRow], YES)];
			}
		} else {			// drum.entry 表示
			NSString *zOpe = drum.entryOperator;
			if ([zOpe isEqualToString:OP_START]) {
				zOpe = @"";  // 開始行の記号は非表示
			} else if ([zOpe isEqualToString:OP_SUB]) {  // Unicode[002D]
				zOpe = MINUS_SIGN; // Unicode[2212]
			}
			if ([drum.entryNumber length] <= 0) {
				lb.textColor = [UIColor blackColor];
				lb.font = [UIFont systemFontOfSize:30];
				lb.text = [NSString stringWithFormat:@"%@ ", zOpe];
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
					lb.text = [NSString stringWithFormat:@"%@ %@", zOpe, stringFormatter(drum.entryNumber, YES)];
				} else {
					lb.text = [NSString stringWithFormat:@"%@ %@", zOpe, stringFormatter(drum.entryNumber, NO)];
				}
			}
		}
	}
	
	return vi;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	Drum *drum = [arrayDrums objectAtIndex:component];
	if ([drum count] <= row) {
		bDramRevers = NO;	// NO=「ドラム逆転やりなおしモード」を一時無効にする
	} else {
		bDramRevers = YES;	// YES=「ドラム逆転やりなおしモード」を許可
	}
}


- (IBAction)ibButton:(UIButton *)button   // 全ボタンを割り当てている
{
	Drum *drum = [arrayDrums objectAtIndex:entryComponent];

	if (MiSegReverseDrum==1 && bDramRevers) {
		bDramRevers = NO;
		NSInteger iRow = [ibPicker selectedRowInComponent:entryComponent]; // 現在の選択行
		if (0 <= iRow && iRow < [drum count]) 
		{	// ドラム逆回転やりなおしモード
			if ([[drum.formulaOperators objectAtIndex:iRow] isEqualToString:OP_START]) {
				[drum.entryOperator setString:OP_START];
			} else {
				[drum.entryOperator setString:@""];
			}
			NSRange range = NSMakeRange(iRow, [drum count] - iRow);
			[drum.formulaOperators removeObjectsInRange:range];
			[drum.formulaNumbers removeObjectsInRange:range];		[drum.entryNumber setString:@""]; 
		}
	}
	
	// entry行より下が選択されても、通常通りentry行入力にする。 
	// [=]の後に数値キー入力すると改行(新セクション)になる。
	
	// キー入力処理
	[drum entryKeyTag:button.tag option:nil];
	// 再表示
	[ibPicker reloadComponent:entryComponent];
	[ibPicker selectRow:[drum count] inComponent:entryComponent animated:YES];
	// [M]ラベル表示
	[self ibLbMemoryDisplay];

	// iAd
	if (NSClassFromString(@"ADBannerView")) {
		if (button.tag==100) {
			[self iAdOn];
		} else {
			[self iAdOff];
		}
	}
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
	if (ibADBannerView==nil) return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	CGRect theBannerFrame = self.view.frame;
	theBannerFrame.origin.y = -52;  // viewの外へ出す
	ibADBannerView.frame = theBannerFrame;	
	
	[UIView commitAnimations];
}


@end
