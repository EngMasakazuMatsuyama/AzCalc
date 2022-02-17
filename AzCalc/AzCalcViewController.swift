//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  AzCalcViewController.swift
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

//
//  AzCalcViewController.m
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

import AVFoundation
import iAd
import UIKit

#if GD_Ad_ENABLED
//[1.1.6] iAd優先 AdMob補助 方式に戻した。 iAdは30秒以上表示するだけでも収益あり
//#import "AdWhirlView.h"
//#import "AdWhirlDelegateProtocol.h"
//#define GAD_SIZE_320x50     CGSizeMake(320, 50)
//#import "MasManagerViewController.h"
//#import "NADView.h"  //AppBank nend
#endif



let KeyMemorys_MAX = 20 // M1〜M20

var aPage: [AnyHashable]?
var dic: [AnyHashable : Any]?
 /* 1ページ内のキー *///NSLog(@"mKmPages: dic=%@", dic);
var iTag = (dic?["Tag"] as? NSNumber)?.intValue ?? 0
var dic: [AnyHashable : Any]?
var iTag = (dic?["Tag"] as? NSNumber)?.intValue ?? 0
var iColOfs = 0
var iRowOfs = 0 // AzKeySet仕様に合わせるため＜＜ iPad(0,0) iPhone(1,1) を原点にしていたため。
var iPage = 0
//iKeyPages
var maKeys: [AnyHashable] = []
var iCol = iColOfs
//iKeyCols
var iRow = iRowOfs
//iKeyRows
var zPCR = String(format: "P%dC%dR%d", iPage, iCol, iRow)
var dicKey = keybordSet[zPCR] as? [AnyHashable : Any]
// 未定義(Blank)キーを登録する
var dicKeyNull = [
    "Tag" : NSNumber(value: -1),
    "Text" : "(Blank)",
    "Size" : NSNumber(value: 10.0),
    "Color" : NSNumber(value: 0),
    "Alpha" : NSNumber(value: 0.2),
    "Unit" : ""
]
var dic = NSDictionary(contentsOfFile: zCalcRollPath) as Dictionary?
var array: [AnyHashable]?
var alv = UIAlertView(title: NSLocalizedString("Canceled", comment: ""), message: NSLocalizedString("CanceledMsg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: NSLocalizedString("Roger", comment: ""))
var aPage: [AnyHashable]?
var muKeys: [AnyHashable] = []
var aKey: [AnyHashable : Any]?
var dKey = aKey
var aKey: [AnyHashable : Any]?
var dKey = aKey
var userDef = UserDefaults.standard
var array: [AnyHashable]?
var aPage: [AnyHashable]?
var muKeys: [AnyHashable] = []
var aKey: [AnyHashable : Any]?
var dKey = aKey
var aKey: [AnyHashable : Any]?
var dKey = aKey
var aPage: [AnyHashable]?
var muKeys: [AnyHashable] = []
var aKey: [AnyHashable : Any]?
var dKey = aKey
// standardUserDefaults:GUD_KeyboardSet から[1.0.9]以前のキー配置を読み込む
var keyboardSet = userDef.dictionary(forKey: "GUD_KeyboardSet") //[1.0.9]までのuserDef保存Key
//[1.0.10]以降、AzCalcRoll.plistからキー配置読み込む
var zPath: String?
var keyView = UIView(frame: frame) // .y=どこでも大丈夫
assert(keyView)
//page
//keyView // No Keybutton
var aPage = mKmPages[page] as? [AnyHashable]
var idx = 0
//NSLog(@"KeyMap: aPage=%@", aPage);

var fx = fKeyWidGap
var col = 0
var fy = fKeyHeiGap
var row = 0
var bu = KeyButton(frame: CGRect(x: CGFloat(fx), y: CGFloat(fy), width: fKeyWidth, height: fKeyHeight))
//page
//col
//row
//
var dicKey = aPage?[idx] as? [AnyHashable : Any]
var strText = dicKey?["Text"] as? String
var numSize = dicKey?["Size"] as? NSNumber
var numColor = dicKey?["Color"] as? NSNumber
var numAlpha = dicKey?["Alpha"] as? NSNumber
var strUnit = dicKey?["Unit"] as? String
var zFile = Bundle.main.path(forResource: "AzKeyMaster", ofType: "plist")
var aComponent: [AnyHashable]?
var dic: [AnyHashable : Any]?
//KeyALPHA_DEFAULT_ON
//strUnit
//KeyALPHA_DEFAULT_OFF
//UIViewAutoresizingFlexibleRightMargin
// AzKeyMaster.plistからマスターキー一覧読み込む
var zFile = Bundle.main.path(forResource: "AzKeyMaster", ofType: "plist")
var bu: UIButton?
var i = 0
// キー再表示：連結されたキーがあれば独立させる
var aKeys = keyView.subviews // addSubViewした順（縦書きで左から右）に収められている。
var bu = obj as? KeyButton
var rc = bu?.frame
//fKeyWidth
//fKeyHeight
//rc
var drum: Drum?
// キー再表示
var aKeys = keyView.subviews // addSubViewした順（上から下へかつ左から右）に収められている。
var bu = obj as? KeyButton
var bu2 = obj as? KeyButton
/*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 ⇒ 右側を残して右隣(C+1)だけ比較するようにした。
									 CGRect rc = bu.frame;
									 rc.size.height = CGRectGetMaxY(bu2.frame) - rc.origin.y;
									 bu.frame = rc;
									 bu2.hidden = YES;
									 */
var rc = bu?.frame // タテ3連結以上に対応しているか確認すること。
//y
//rc // 下側ボタンを生かす。
var bu = obj as? KeyButton
var bu2 = obj as? KeyButton
/*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 ⇒ 右側を残して右隣(C+1)だけ比較するようにした。
									 CGRect rc = bu.frame;
									 rc.size.width = CGRectGetMaxX(bu2.frame) - rc.origin.x;
									 bu.frame = rc;
									 bu2.hidden = YES;
									 */
var rc = bu?.frame // ヨコ3連結以上に対応しているか確認すること。
//x
//rc // 右側ボタンを生かす。
//keyView // 受け取った側で release すること。
//audioPlayer再生にてiPod演奏が停止しないようにするため
var audioSession = AVAudioSession.sharedInstance()
var userDef = UserDefaults.standard
// インストールやアップデート後、1度だけ処理する
var zNew = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
var zDef = userDef.value(forKey: "DefVersion") as? String
//self
var rect = ibScrollUpper.frame
var MiSvUpperPage: width?
//[1.0.8.2]　UITapGestureRecognizer対応 ＜＜iOS3.2以降
// セレクタを指定して、ジェスチャーリコジナイザーを生成する ＜＜iOS3.2以降対応
// 1指2タップ
var tap = UITapGestureRecognizer(target: self, action: Selector("handleUpper2Taps:"))
var maButtons: [AnyHashable] = []
var i = 0
//DRUMS_MAX
// ドラム切り替えボタン(透明)をaddSubView
var bu = UIButton(type: .custom)
//i
// Drumオブジェクトは、最初に1度だけ生成し、viewDidUnloadでは破棄しない。
var mRaDrums: [AnyHashable] = []
var i = 0
//DRUMS_MAX
// ドラムインスタンス生成
var drum = Drum()
//self
//self
//self
//UIKeyboardTypeNumbersAndPunctuation
//UITextAlignmentCenter
//
var dx = ibScrollUpper.frame.size.width
//frame
//dx
//rect
//frame
//dx
//rect
//frame
//dx
//rect
//frame
//dx
//rect
//frame
//dx
//rect
//frame
//dx
//rect
var rect = ibScrollLower.bounds
var PAGES: width?
var rect: width?
//[1.0.8]　UITapGestureRecognizer対応 ＜＜iOS3.2以降
// セレクタを指定して、ジェスチャーリコジナイザーを生成する ＜＜iOS3.2以降対応
// handleSwipeLeft:ハンドラ登録　　2本指で左へスワイプされた
var swipe = UISwipeGestureRecognizer(target: self, action: Selector("handleLowerSwipeLeft:"))
//UISwipeGestureRecognizerDirectionLeft //左
//UISwipeGestureRecognizerDirectionRight //右
//UISwipeGestureRecognizerDirectionLeft //左
//UISwipeGestureRecognizerDirectionRight //右
//iKeyCols // 均等割り　 iPhone=320/5=64  iPad=768/7=110
//iKeyRows
var ff = Float((fKeyWidth - fKeyGap * 2) / GOLDENPER)
//fKeyGap
//GOLDENPER
//fKeyGap
//fKeyGap
//fKeyGap
//self
//AdMobID_CalcRollPAD
//AdMobID_CalcRoll
var request = GADRequest()
//self
//ADBannerContentSizeIdentifier320x50
//ADBannerContentSizeIdentifierPortrait
var defaults = UserDefaults.standard
//DRUMS_MAX // 生成数を超えないように
//PRECISION // [F]小数桁制限なし
var userDef = UserDefaults.standard
// 小数点の表記(@"Text")を変更する
var zDec = "." // ドット
formatterDecimalSeparator(zDec)
#else
// キーボード生成
var rcBounds = ibScrollLower.bounds // .y = 0
assert(mKeyView)
var fWid = Float(ibPvDrum.frame.size.width - DRUM_LEFT_OFFSET * 2)
var fWiMin: Float = 0.0
var fWiMax: Float = 0.0
//PICKER_COMPONENT_WiMIN // 1コンポーネントの表示最小幅
//DRUM_GAP
//fWiMin // 均等
var fX = Float(DRUM_LEFT_OFFSET + 4.0)
var fY = ibPvDrum.frame.origin.y
var i = 0
//MiSegDrums
var bu = RaDrumButtons.object(at: i)
//DRUMS_MAX
var bu = RaDrumButtons.object(at: i)
var zNumPaste = stringAzNum(UIPasteboard.general.string) // Az数値文字列化する
var zTitle: String?
// ボタンを出現させる
var rc = ibBuMemory.frame // Y位置はnib定義通り固定
var sz = zTitle?.size(withAttributes: [NSAttributedString.Key.font: font])
//rc
//KeyALPHA_MSTORE_ON
//ADBannerContentSizeIdentifier320x50
//ADBannerContentSizeIdentifierPortrait
//bZoomEntryComponent // 拡大／均等トグル式
// 以下の処理をしないと pickerView が再描画されない。
var iDrums = Int(MiSegDrums)
//iDrums
var rect = mKeyView.frame // .y=0 であることに注意
//rect // 瞬間移動！ ＜＜結構、うまく錯覚させることができているようだ。
//width // (+)右へ
//mKeyView // 直前ページを保持
var rect = mKeyView.frame // .y=0 であることに注意
//rect // 瞬間移動！ ＜＜結構、うまく錯覚させることができているようだ。
//width // (-)左へ
//mKeyView // 直前ページを保持
var alert = UIAlertView(title: NSLocalizedString("Help Swipe 2 fingers", comment: ""), message: "", delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
assert(keyView)
var `in` = [obj](repeating: , count: keyView)
var kb = obj
//KeyALPHA_DEFAULT_ON
//KeyALPHA_DEFAULT_ON
var maKeys = mKmPages[keyView.tag] as? [AnyHashable]
var idx = 0
var `in` = [obj](repeating: , count: keyView)
var kb = obj as? KeyButton
var dicKb = maKeys?[idx] as? [AnyHashable : Any]
var iComponent = 0
var iRow = 0 // 見出し行
var i = 0
//i
var iComp = 0
var aComponent: [AnyHashable]?
var iDict = 0
var dic: [AnyHashable : Any]?
var i = 0
// iRow==0 ならば .tag=(-1)未定義になる
var dic = RaKeyMaster.object(at: iComponent)[iRow] as? [AnyHashable : Any]
// Size
var fSize = (dic?["Size"] as? NSNumber)?.floatValue ?? 0.0
//fSize
var i = 0
var userDef = UserDefaults.standard
var userDef = UserDefaults.standard
var str = userDef.object(forKey: "PB_TEXT") as? String
var num = userDef.object(forKey: "PB_TAG") as? NSNumber
assert(bPad) // iPadのみ
var kb: KeyButton?
// 生成
var maBus: [AnyHashable] = []
var idx = 0
//KeyMemorys_MAX
var kb = KeyButton(frame: CGRect.zero)
var dic = mKmPadFunc[idx] as? [AnyHashable : Any]
//DRUM_FONT_MSG
//KeyALPHA_DEFAULT_OFF
// 回転移動
var rc = CGRect(x: 0, y: 0, width: 256 - 8 * 2, height: 49.8 - 5 * 2)
var bu: UIButton?
//rc
var bu: UIButton?
//rc
#if GD_Ad_ENABLED
assert(bPad) // iPadのみ
var rciAd = RiAdBanner.frame
//y
//rciAd
//bZoomEntryComponent // 拡大／均等トグル式
//bZoomEntryComponent // 拡大／均等トグル式
//tag // ドラム切り替え
var zz = String(format: "Comp=%ld", Int(entryComponent))
//bTouchAction = YES;
// ドラム切り替え時に、キーボードをページ(1)にする
//	CGRect rc = ibScrollLower.frame;
//	rc.origin.x = rc.size.width * 1;
//	[ibScrollLower scrollRectToVisible:rc animated:YES];
// UNIT系列 再構成
var drum = RaDrums.object(atIndex: entryComponent)
// 以下の処理をしないと pickerView が再描画されない。
var iDrums = Int(MiSegDrums)
//iDrums
//button
var zTouch = "Touch Calc"
var bCalcing = false // YES=再計算する
var zz = "[\(Int(iKeyTag))]"
var i = ibTvFormula.text.length() - 1
var rg: NSRange?
//i
var z: String? = nil
if let rg = rg {
    z = ibTvFormula.text.substring(with: rg)
}
// 大外カッコを外す
var rg = NSRange(location: 1, length: ibTvFormula.text.length() - 2)
var z: String?
var rg: NSRange?
var idx = ibTvFormula.text.length() - 1
//idx
var zAns = stringFormatter(CalcFunctions.zAnswer(fromFormula: ibTvFormula.text), true)
var fAlpha = Float(KeyALPHA_MSTORE_ON)
//KeyALPHA_MSTORE_OFF
var dic: [AnyHashable : Any]?
// 現ページにあれば表示更新する
var aKeys = mKeyView.subviews() // addSubViewした順（縦書きで左から右）に収められている。
var kb = obj as? KeyButton
//fAlpha
var kb: KeyButton?
// アニメーション
var rcEnd = kb?.frame // 最終位置
//frame
//rcEnd
//fAlpha
// 最小順位の未使用メモリを探す
var iTagMin = KeyTAG_MSTROE_End
var dic: [AnyHashable : Any]?
var iTag = (dic?["Tag"] as? NSNumber)?.intValue ?? 0
var zText = dic?["Text"] as? String
//iTag
var alert = UIAlertView(title: NSLocalizedString("Memory Over", comment: ""), message: NSLocalizedString("Memory Over msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
//iTagMin
var zTouch = "Touch Calc"
var str = stringAzNum(UIPasteboard.general.string)
var zMem = stringAzNum(UIPasteboard.general.string)
var cNum1 = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
var cNum2 = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
var cAns = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
var zAns = String(cString: Int8(cAns), encoding: .ascii)
//zAns // ERROR
// 丸め処理
var cNum = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
var cAns = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
//self
var zRootPath: String?
var vc = AZDropboxVC(
    appKey: "62f2rrofi788410" /*CalcRoll */,
    appSecret: "s07scm6ifi1o035",
    root: kDBRootAppFolder /*kDBRootAppFolder or kDBRootDropbox */,
    rootPath: zRootPath,
    mode: AZDropboxUpDown /* Up & Down & Delete */,
    extension: CALCROLL_EXT,
    delegate: self) //<AZDropboxDelegate>が呼び出される
//表示開始		Naviへ突っ込む。iPad共通
var nc = UINavigationController(rootViewController: vc)
//UIModalPresentationFormSheet // 背景Viewが保持される
//UIModalTransitionStyleFlipHorizontal //	UIModalTransitionStyleFlipHorizontal
var drum = RaDrums.object(atIndex: entryComponent)
var zCopyNumber: String? = nil // 遡って数値を[Copy]するのに備えて保持する
//bDramRevers = NO;  [Copy]後、遡った行が維持されるようにリマークした
var iRow = ibPvDrum.selectedRow(inComponent: entryComponent) // 現在の選択行
//text
//tag
var drum = RaDrums.object(atIndex: entryComponent)
var zFormula = drum?.zFormulaCalculator()
//zFormula
var kb = KeyButton(frame: CGRect.zero) as? // [Paste]
KeyButton
//KeyTAG_MPASTE // [Paste]
//UIModalTransitionStyleFlipHorizontal // 水平回転
/*	//AzCalcAppDelegate *appDelegate = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (bPad) {
		mAppDelegate.ibInformationVC.modalPresentationStyle = UIModalPresentationFormSheet; // iPad画面1/4サイズ
	} else {
		mAppDelegate.ibInformationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	}
	[self presentModalViewController:mAppDelegate.ibInformationVC animated:YES];
*/
// このアプリについて
var vc = AZAboutVC()
//vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
//[self.navigationController pushViewController:vc animated:YES];
var nc = UINavigationController(rootViewController: vc)
//UIModalPresentationFormSheet // iPad画面1/4サイズ
//UIModalTransitionStyleFlipHorizontal
//UIModalTransitionStyleFlipHorizontal
//MiSegDrums
#else
var dm = RaDrums.object(atIndex: component)
//float fWid = self.view.frame.size.width - DRUM_LEFT_OFFSET*2; // DRUM_LEFT_OFFSET*2 = ドラム左右余白
var fWid = Float(ibPvDrum.frame.size.width - DRUM_LEFT_OFFSET * 2) // DRUM_LEFT_OFFSET*2 = ドラム左右余白
//DRUM_GAP
var fWmin = Float(PICKER_COMPONENT_WiMIN)
//fWmin // 1コンポーネントの表示最小幅
//DRUM_GAP // 均等
var vi = reView // Viewが再利用されるため
var lb: UILabel? = nil
var sz = pickerView.rowSize(forComponent: component)
//UIBaselineAdjustmentAlignBaselines
//UITextAlignmentCenter
//vi
//UIBaselineAdjustmentAlignBaselines
var iRow = row - ROWOFFSET // タイトル行を空けるため
//UITextAlignmentCenter
//UITextAlignmentCenter
var drum = RaDrums.object(atIndex: component)
//UITextAlignmentRight
var zOpe = drum?.zOperator(iRow)
var zNum = drum?.zNumber(iRow)
var bFormat = (iRow < (drum?.count() ?? 0)) || zOpe?.hasPrefix(OP_ANS) ?? false
var zUnit = drum?.zUnit(iRow, withPara: 0) // (0)表示単位
//vi
var i = 0
var drum = RaDrums.object(atIndex: component)
//row
var iPrevUpper = Int(MiSvUpperPage ?? 0)
var userDef = UserDefaults.standard
// 現ドラムの状態に従って、単位ボタンを有効にする
var drum = RaDrums.object(atIndex: entryComponent)
//ibTvFormula.keyboardType = UIKeyboardTypeNumbersAndPunctuation;  どちらも効かず、上部ファンクションを消せない
//[ibTvFormula setKeyboardType:UIKeyboardTypeNumbersAndPunctuation]; どちらも効かず、上部ファンクションを消せない
// 今の所、手操作で UIKeyboardTypeNumbersAndPunctuation モードに変えてもらうしか無い。

var rc = CGRect.zero
var fOfs = fPadKeyOffset()
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
var rc = CGRect.zero
var fOfs = fPadKeyOffset()
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//fOfs
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
//frame
//rc
let zList = "0123456789. +-×÷*/()" // 入力許可文字
var rg = (zList as NSString).range(of: text)
// 先に.plist保存する
var dic: [AnyHashable : Any]? = nil
#else
// 実機で動作している場合のコード
//viewDidLoad:にて AVAudioSessionカテゴリ指定すること。さもなくばiPod演奏が止まる
var url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/\(filename)")
var error: Error? = nil
//NG//AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//NG//AVAudioPlayer __strong *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//ARCにより破棄されないようにするためにインスタンス変数に仮保持する
var player: AVAudioPlayer? = nil
do {
    player = try AVAudioPlayer(contentsOf: url)
} catch {
}
//self // audioPlayerDidFinishPlaying:にて release するため。
//MfAudioVolume // 0.0〜1.0
//player
//bShow
var rc = RiAdBanner.frame
//origin
//rc
var rc = RoAdMobView.frame
//origin
//rc

class AzCalcViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate, AZDropboxDelegate, ADBannerViewDelegate, GADBannerViewDelegate {
    @IBOutlet var ibPvDrum: UIPickerView!
    @IBOutlet var ibLbEntry: UILabel!
    @IBOutlet var ibBuMemory: UIButton!
    @IBOutlet var ibBuSetting: UIButton!
    @IBOutlet var ibBuInformation: UIButton!
    @IBOutlet var ibScrollLower: UIScrollView!
    @IBOutlet var ibScrollUpper: UIScrollView! //[0.3]
    @IBOutlet var ibTvFormula: UITextView! //[0.3]
    @IBOutlet var ibLbFormAnswer: UILabel!
    @IBOutlet var ibBuFormLeft: UIButton!
    @IBOutlet var ibBuFormRight: UIButton!
    @IBOutlet var ibBuGetDrum: UIButton!

    private var RaDrums: [AnyHashable]?
    private var RaDrumButtons: [AnyHashable]?
    private var RaKeyMaster: [AnyHashable]? // !=nil キーレイアウト変更モード
    private var RimgDrumButton: UIImage?
    private var RimgDrumPush: UIImage?
    private var mKeyView: UIView?
    private var mKeyViewPrev: UIView? // スクロール後に破棄する
    private var mGvKeyUnitSI: String?
    private var mGvKeyUnitSi2: String?
    private var mGvKeyUnitSi3: String?
    private var mPadMemoryKeyButtons: [AnyHashable]? // <--(KeyButton *)[M]
    //[1.0.10] mKm : KeyMap   ＜＜＜注意！ 配下も全てMutableにすること。
    private var mKmPages: [AnyHashable]? // <--(NSMutableArray *)All Page <--(NSMutableDictionary *) キー配列
    private var mKmPadFunc: [AnyHashable]? // <--(NSMutableDictionary *) iPad拡張メモリキー配列
    private var mKmMemorys: [AnyHashable]? // <--(NSMutableDictionary *) mKmPagesとmKmPadFuncの[M]キーをリンクしている
    private var mAppDelegate: AzCalcAppDelegate?
    private var entryComponent = 0
    private var bDramRevers = false // これにより、ドラム逆転やりなおしモード時のキー連打不具合に対処している。
    private var bZoomEntryComponent = false // YES= entryComponentの幅を最大にする
    private var bDrumButtonTap1 = false // 最初のタップでYES
    private var bDrumRefresh = false // =YES:ドラムを再表示する  =NO:[Copy]後などドラムを動かしたくないとき
    private var bFormulaFilter = false // =YES:ペーストされたのでフィルタ処理する
    private var bPad = false // =YES:iPad  =NO:iPhone
    private var MbInformationOpen = false
    #if GD_Ad_ENABLED
    private var RiAdBanner: ADBannerView?
    private var RoAdMobView: GADBannerView?
    //GADBannerView*	RoAdMobView;
    //AdWhirlView							*mAdWhirlView;
    //NADView									*mNendView;
    //MasManagerViewController	*mMedibaAd; 

    private var bADbannerIsVisible = false // iAd 広告内容があればYES
    private var bAdShow = false // 広告表示可否
    //BOOL				bADbannerFirstTime;		// iAd 広告内容があれば、起動時に表示するため
    //[1.1.6]Ad隠さない、常時表示する。
    //BOOL				bADbannerTopShow;		//[1.0.1]// =YES:トップの広告を表示する  =NO:入力が始まったので隠す
    #endif

    // Keyboard spec
    private var iKeyPages = 0
    private var iKeyCols = 0 //, iKeyOffsetCol;
    private var iKeyRows = 0 //, iKeyOffsetRow;
    private var fKeyGap: Float = 0.0
    private var fKeyFontZoom: Float = 0.0
    private var fKeyWidGap: Float = 0.0 // キートップ左右の余白
    private var fKeyHeiGap: Float = 0.0 // キートップ上下の余白
    private var fKeyWidth: Float = 0.0 // キートップの幅
    private var fKeyHeight: Float = 0.0 // キートップの高さ
    private var MfTaxRate: Float = 0.0 // 消費税率(%)
    private var MfAudioVolume: Float = 0.0 // 0.0〜1.0
    // Setting
    private var MiSegDrums = 0 // ドラム数 ＜＜セグメント値に +1 している＞＞
    private var MiSegCalcMethod = 0
    private var MiSegDecimal = 0
    private var MiSegRound = 0
    private var MiSegReverseDrum = 0
    private var MiSvLowerPage = 0 // ibScrollLower の現在表示ページを常に保持
    private var MiSvUpperPage = 0 // ibScrollUpper の現在表示ページを常に保持
    private var MiSwipe1fingerCount = 0 // 1指で3回スワイプされたらヘルプメッセージを出すため
    private var mSoundClick: AVAudioPlayer? //ARCにより破棄されないようにするため
    private var mSoundSwipe: AVAudioPlayer?
    private var mSoundLock: AVAudioPlayer?
    private var mSoundUnlock: AVAudioPlayer?
    private var mSoundRollex: AVAudioPlayer? //Roll切替音

    @IBAction func ibBuMemory(_ button: UIButton?) {
    }

    @IBAction func ibBuSetting(_ button: UIButton?) {
    }

    @IBAction func ibBuInformation(_ button: UIButton?) {
    }

    @IBAction func ibButton(_ button: UIButton?) {
    } // 全電卓ボタンを割り当てている。.tag により識別

    @IBAction func ibBuGetDrum(_ button: UIButton?) {
    }

    func gvMemorySave() {
    } // AzCalcViewController:applicationWillTerminateからコールされる

    func gvMemoryLoad() {
    } // AzCalcViewController:applicationDidBecomeActiveからコールされる

    func gvKeyUnitGroupSI(_ unitSI: String?, andSI unitSi2: String?) {
    } // =nil:ハイライト解除

    func gvKeyUnitGroupSI(
        _ unitSI: String?,
        andSi2 unitSi2: String?,
        andSi3 unitSi3: String?
    ) {
    } // =nil:ハイライト解除

    #if GD_Ad_ENABLED
    func adShow(_ bShow: Bool) {
    } // applicationDidEnterBackground:から呼び出される

    #endif

    // delegate
    func gzCalcRollLoad(_ zCalcRollPath: String?) -> String? {
    }

    func gvDropbox(_ rootViewController: UIViewController?) {
    }

    // MARK: - Keymap

    func aleartKeymapErrorMsg(_ errNo: Int) {
        // キーマップ関係のエラーあれば表示し、削除インストールを促す
        let title = String(format: "%@\n#(%ld)#", NSLocalizedString("KeymapError", comment: ""), errNo)
        GA_TRACK_EVENT_ERROR(title, 0)
        let alv = UIAlertView(title: title, message: NSLocalizedString("KeymapError msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK") // autorelease];
        alv.show()
    }

    func keymapSaveAndSync(_ bSync: Bool) {
        var userDef = UserDefaults.standard

        if let mKmPages = mKmPages {
            // 初期キーボード配置を　standardUserDefaults へ保存する
            if bPad {
                userDef.set(mKmPages, forKey: GUD_KmPadPages)
            } else {
                userDef.set(mKmPages, forKey: GUD_KmPages)
            }
        }

        if let mKmPadFunc = mKmPadFunc {
            // mKmPadFunc を保存する
            //NSLog(@"SAVE: mKmPadFunc=%@", mKmPadFunc);
            userDef.set(mKmPadFunc, forKey: GUD_KmPadFunc)
        }

        if bSync {
            if userDef.synchronize() != true {
                print("keymapSaveAndSync: synchronize: ERROR")
                GA_TRACK_EVENT_ERROR("synchronize", 0)
            }
        }
        let zPath = "/Users/masa/AzukiSoft/AzCalc/AzCalc/"
        var dic: [AnyHashable : Any]? = nil
        if bPad {
            if let mKmPages = mKmPages, let mKmPadFunc = mKmPadFunc {
                dic = [
                    "PadPages" : mKmPages,
                    "PadFunc" : mKmPadFunc
                ]
            }
        }
    }
}

//#import "DropboxVC.h"		// SBjsonが含まれている


let DRUMS_MAX = 5 // この数のDrumsオブジェクトを常に生成する
let PICKER_COMPONENT_WiMIN = 40 // 1コンポーネントの表示最小幅

let DRUM_LEFT_OFFSET = 11.0 // ドラム左側の余白（右側も同じになるようにする）
let DRUM_GAP = 2.0 // ドラム幅指定との差
let DRUM_FONT_MAX = 27.0 // 数式表示フォントサイズの最大
let DRUM_FONT_MSG = 24.0 // メッセージ表示フォントサイズ
let DRUM_FONT_MIN = 6.0 // 数式表示フォントサイズの最小

let ROWOFFSET = 2
let DECIMALMAX = 12
let GOLDENPER = 1.618 // 黄金比

let MINUS_SIGN = "−" // Unicode[2212] 表示用文字　[002D]より大きくするため
let FORMULA_BLANK = "〓 " // Formula calc が空のとき表示するメッセージの先頭文字（判定に使用）

let PAGES = 100 // 2の倍数　＜＜瞬間移動！錯覚により、あまり大きくする必要が無くなった。


// Tags
//没//#define TAG_DrumButton_LABEL		109

/* Apple審査拒絶「仕様禁止メソッド」
@interface UIPickerView (Mute)
-(void) setSoundsEnabled:(BOOL)enabled;
@end
*/

//================================================================================AzCalcViewController
extension AzCalcViewController {
    //- (void)MvKeyboardPage:(NSInteger)iPage;
    //- (void)audioPlayer:(NSString*)filename;
}

/*	// JSON   （DropboxSDK.frameworkに含まれる）
		//NSArray		*mKmPages;			// <--(All Page) <--(NSDictionary *) キー配列
		//NSArray		*mKmPadFunc;		// <--(NSDictionary *) iPad拡張メモリキー配列
		NSArray *aJson = [[NSArray alloc] initWithObjects:mKmPages, mKmPadFunc, nil];
		NSString *zJson = [[NSString alloc] initWithString:(NSString*)[aJson JSONRepresentation]];
		[aJson release], aJson = nil;
		NSLog(@"zJson-------------------------------------\n%@\nzJson-------------------------------------", zJson);
		[zJson release], zJson = nil;
	 */
#endif
 /* keymapLoad から呼び出される。 */ /* RootだけMutable */ /* mKmPages にある[M]メモリキーを mKmMemorys から参照できるようにする *///NSLog(@"[mKmPages count]=%d", [mKmPages count]);
 /* メモリキー */ /* mKmPadFunc にある[M]メモリキーを mKmMemorys から参照できるようにする */ /* メモリキー *///NSLog(@"keymapLoad: mKmMemorys=%@", mKmMemorys); /* [1.0.9]以前の KeyboardSet を、mKmPages に変換する */// KeyMap へ変換する
 /* RootだけMutable */ /* iPad */// KeyMap 変換完了 /* zCalcRollPath.plist から mKmPages や mKmPadFunc を読み込む */ /*iPad最小ページ数4 *///---注意---＜＜Analize指摘
//
 /* 全てMutableにする */ /* 全てMutableにする */// mKmPages と mKmPadFunc から mKmMemory を生成する
//NG//[self viewWillAppear:YES]; 落ちる
 /*OK */#if AzMAKE_SPLASHFACE
 /* キー定義なし */#endif

 /* 全てMutableにする */ /* 全てMutableにする */ /* 全てMutableにする *///
 /* 未定義（インストール直後）ならば、 *///[1.0.9]以前のユーザ配置を読み込んで、mKmPages に変換する
// mKmPages へ変換する
// mKmPages 変換完了
// mKmPages と mKmPadFunc から mKmMemory を生成する
// MARK: - View lifecicle
 /* Function No. */ /* 通常は通らない。　将来、Master属性が増えたときに通る可能性あり。 */// AzKeyMaster 引用
 /* AzKeyMaster.plistからマスターキー一覧読み込む *///--注意---＜＜Analize指摘
//--注意---＜＜Analize指摘
// 将来、属性が増えれば、ここへ追加することになる。
 /* レス向上のため */ /* 特殊処理 */ /* 小数点 */func getFormatterDecimalSeparator() {
}

 /* Space1 */ /* UNIT */ /*.enabled=NOにすると薄い線が見える */ /* BLACK */ /*Patch//[0.4.1]//bbl=1.58987294928㎥⇒NG⇒0.158987294928㎥ */ /*Patch//[0.4.1]//cuin=0.016387064㎥⇒NG⇒0.000016387064㎥ */ /* Function No. *///bu.titleLabel.text = @" "; // = nill ダメ  Space1
 /* = nill ダメ  Space1 */#if AzMAKE_SPLASHFACE
#else
// 上と右のマージンが自動調整されるように。つまり、左下基点になる。
// UIControlEventTouchDown OR UIControlEventTouchUpInside

// タテヨコ連結処理は、viewWillAppearで処理されるので、ここでは不要

// init だから

// ボタン生成後の「キー連結」処理
// キーレイアウト変更モード
 /* レイアウト中は固定する *///--注意---＜＜Analize指摘
//buChangeKey = nil;
//--注意---＜＜Analize指摘
// 全ドラム選択行を0にする
 /*[0.3]連結された右端のボタンになる */ /*[0.3]連結された下端のボタンになる */ /* 単位キーで無効にされている場合、解除するため *///[M9]
 /* タイトルを初期化する　　＜＜ bu.titleLabel.text = 代入はダメ */#if GD_Ad_ENABLED
// キーレイアウト変更モードでは常時ＯＦＦ
//[self adShow:NO];
#endif
// ドラタク通常モード
// reSetting
// 表示ドラム数(component数)が変わったときの処理
 /* entryComponentが表示ドラムを超えないように補正する */// [ibPvDrum reloadAllComponents];  MvDrumButtonShow内で呼び出している
// Entryセル表示
// [M]ラベル表示
 /* 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する */// タテ連結処理
 /* 同ページ内に限る */ /*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 */ /* 同列 ＆ 下行 ならば タテ連結 */ /* 下行のTab違えば即終了 */ /* 列が違えば即終了 */ /* 上側ボタンを非表示にする */// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
 /* 起動時やメモリ不足時にviewDidLoad後に通ることになる。その時、非表示となったボタンは無視する */// ヨコ連結処理　＜＜同じ高さならば連結する＞＞
 /* 同ページ内に限る */ /*[0.3]Fix 間に他のボタンが入っても連結されてしまう不具合修正 */ /* 同行 ＆ 右隣 ならば ヨコ結合 */ /* 右列のTab違えば即終了 */ /* 右列の高さが違えば即終了 */ /* 左側ボタンを非表示にする *///[1.0.10]キーボードスクロール時、単位キーの有効／無効を「直前と同様に」セットする
//NSLog(@"KeyMap: keyView=%@", keyView);
//NSLog(@"--- retainCount: ibScrollLower=%d", [ibScrollLower retainCount]);
//
 /* ＜ "1.0.6" *///[1.0.6] "5/4" と "6/5" の位置を入れ替えたことに対応するため。
 /* Informationを自動オープンする */// 背景テクスチャ・タイルペイント
//========================================================== Upper ==============
// ScrollUpper  (0)Pickerドラム  (1)TextView数式
 /* 初期ページ(1)にする */ /*スクロール許可 ---> 数式編集中だけ NO で固定する。 */ /* 両端の跳ね返り */ /*NOにするとiPhone3Gにてスクロール困難になる。 */ /* 指数 */ /* タップ数 *///-----------------------------------------------------(0)ドラム ページ
// viewDidUnloadされた後、ここを通る
#if AzMAKE_SPLASHFACE
 /* これで非表示状態になる *///bu.hidden = YES;   MvDrumButtonShowで変更しているため効果なし
#else
 /* 半透明 (0.0)透明にするとクリック検出されなくなる */ /*TouchUpInside]; */#endif
//[self.view addSubview:bu];
//[bu release]; Auto
// IBコントロールの初期化
//NG//[ibPvDrum setSoundsEnabled:NO];  // ピッカーの音を止める。   Apple審査拒絶されました「仕様禁止メソッド」

//-----------------------------------------------------(1)数式 ページ
// UITextView
//ibTvFormula.font = [UIFont systemFontOfSize:14];
#if AzSTABLE
 /* AdMobのスペースを埋めるため */#else
// Free : 上部に AdMob スペースあり
#endif
//========================================================== Lower ==============
//[0.4.2]//[self MvPadFuncShow]より前に必要だった。
//[0.4.1]//"Received memory warning. Level=2" 回避するための最適化
 /* iPad */ /*[0.4]単位キー追加のため */ /*iKeyOffsetCol = 0; // AzdicKeys.plist C 開始位置 */ /*iKeyOffsetRow = 0; */ /* iPhone *///iKeyPages = 4;  //iPhone3Gだと、4以上にすると Received memory warning. 発生し、しばらくすると落ちる
 /*mKeyView（1ページ生成）方式により制限解除 */ /*iKeyOffsetCol = 1; // AzdicKeys.plist C 開始位置 */ /*iKeyOffsetRow = 1; */// ScrollLower 	(0)Memorys (1〜)Buttons
 /* DEFAULT PAGE *///ibScrollLower.contentSize = CGSizeMake(rect.size.width * iKeyPages, rect.size.height); 
//ibScrollLower.contentSize = CGSizeMake(rect.size.width * (iKeyPages + 2), rect.size.height); // (0)先頭 と (iKeyPages+1)末尾 にブランクページ
//rect.origin.x = rect.size.width * MiSvLowerPage;
 /* 初期ページ位置 */ /*self; */ /*スクロール禁止 */ /*NO:スクロール操作検出のため0.5s先取中止 ⇒ これによりキーレスポンス向上する */#if (TARGET_IPHONE_SIMULATOR)
// シミュレータで動作している場合のコード
 /*タッチの数、つまり指の本数 */#else
 /*タッチの数、つまり指の本数 */#endif
 /* スクロールビューに登録 */// handleSwipeRight:ハンドラ登録　　2本指で右へスワイプされた
#if (TARGET_IPHONE_SIMULATOR)
// シミュレータで動作している場合のコード
 /*タッチの数、つまり指の本数 */#else
 /*タッチの数、つまり指の本数 */#endif
 /* スクロールビューに登録 */#if (TARGET_IPHONE_SIMULATOR)
// シミュレータで動作している場合のコード
#else
// handleSwipe1Finger:ハンドラ登録　　1本指でスワイプされた
 /*タッチの数、つまり指の本数 */ /* スクロールビューに登録 */ /*タッチの数、つまり指の本数 */ /* スクロールビューに登録 */#endif
//----------------------------- KeyMap 読み込み
 /* mKmPages を生成する */// ibPvDrumは、画面左下を基点にしている。
// ボタンの縦横比を「黄金率」にして余白をGapにする
// この後、上のパラメータを使って、viewWillAppear:にて mKeyView 生成＆描画する
// [mKeyView　subViews] で取得できる配列には、addSubViewした順（縦書きで左から右）に収められている。

#if GD_Ad_ENABLED
//CGRect rcAd = CGRectMake(0,0, 320, 50); // TOP
//bADbannerTopShow = YES;

//--------------------------------------------------------------------------------------------------------- AdMob
 /* iPad    GAD_SIZE_728x90, GAD_SIZE_468x60 */ /* iPhone		GAD_SIZE_320x50 *///[ibScrollUpper addSubview:RoAdMobView];
//[self.view bringSubviewToFront:RoAdMobView]; // 上にする
//[RoAdMobView release] しない。 deallocにて 停止(.delegate=nil) & 破棄 するため。
//--------------------------------------------------------------------------------------------------------- iAd
 /* !<  (>=) "4.0" */// iPad はここで生成する。　iPhoneはXIB生成済み。
 /* ＜ "4.2" */// iOS4.2より前
//[0.5.0]ヨコのときもタテと同じバナーを使用する
// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
//[0.5.0]ヨコのときもタテと同じバナーを使用する
 /* iPhone: 320×50, 480×32			iPad: 768×66, 1024×66 */#endif
// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる// Setting
#if AzMAKE_SPLASHFACE
 /* Default.png ドラム数 */#else
 /* ドラム数 ＜＜セグメント値に +1 している＞＞ */ /* iPad初期ドラム数 */ /* iPhone初期ドラム数 */#endif
// Option
 /* 1 + 消費税率%/100 */ /* [']0x27 アポストロフィー (シングルクオート) */ /* (0) *///formatterGroupingSize( (int)[defaults integerForKey:GUD_GroupingSize] );				// Default[3]
 /* Default[3] */ /* ミドル・ドット（middle dot） */ /* ピリオド *///-------------------------------------------------------------------------キーボード生成
// キーボタン イメージ
 /* Oval *///[1.0.10]stretchableImageWithLeftCapWidth:により四隅を固定して伸縮する
 /* Square *///[1.0.10]stretchableImageWithLeftCapWidth:により四隅を固定して伸縮する
 /* 0=Roll *///[1.0.10]stretchableImageWithLeftCapWidth:によりボタンイメージ向上
//RimgDrumButton = [[UIImage imageNamed:@"KeyRollUp"] retain];
// キーボード破棄
 /* 実機では、removeだけでは消えない場合があった。 */#if AzMAKE_SPLASHFACE
 /* 常に中央位置 */ /* 実機では、removeだけでは消えない場合があった。 */ /* addSubview:直後にreleaseしているため、上でremoveしたならrelease不要。 */ /* 中央 ＜＜ .y=0でも大丈夫 */// MEMORY BUTTON		＜＜これだけは、 @"KeyRollUp" に固定。高さが不足し、Ovalが正しく表示されないため。
 /* 透明にして隠す */ /* 上にする */ /* iPad専用 メモリー(KeyMemorys_MAX=20)キー配置 および 回転処理 */#endif
 /* 画面表示された後にコールされる */ /* キーレイアウト変更モード */ /* 改めて表示 */#if GD_Ad_ENABLED
//GA_TRACK_EVENT_ERROR(@"AzCalcVC(300) ",0);  //2012-04-04//75件
//[self aleartKeymapErrorMsg:300];
#endif

 /*initWithStyleにて判定処理している */ /* 以後、自動初期表示しない。 *///GA_TRACK_EVENT_ERROR(@"AzCalcVC(301) ",0);
//[self aleartKeymapErrorMsg:301];
// Entryセル表示：entryComponentの位置にibLbEntryActiveを表示する /* entryComponentを拡大する *///bu.frame = CGRectMake(fX,fY+155, fWiMax-6,28); // 選択中
 /* 選択中 */ /* 追加 */ /*[1.0.10]ピッカーロール優先のため無効にした。　ダブルタップ式に変更 */// Next
 /* 非選択時 *///bu.backgroundColor = [UIColor yellowColor];  //DEBUG
// Next
// ibBuMemory 表示 /* ペーストボードに数値がある */ /* Clear */ /* Pasteboardより */// 文字数からボタンの幅を調整する
 /* Over */// アニメ終了時の状態をセット
 /* 既に隠れている */// ボタンをibScrollLowerの裏に隠す
// アニメ準備
// アニメ終了時の状態をセット
 /* 透明 */// アニメ開始
// MARK:  View 回転

// 回転サポート /* タテは常にOK */ /* iPad *///- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation: ＜＜OS 3.0以降は非推奨×××
// 回転の開始前にコールされる。 ＜＜OS 3.0以降の推奨＞＞#if AzMAKE_SPLASHFACE
#endif
 /* iPhone *///以下、iPadのみ

#if GD_Ad_ENABLED
 /* ＜ "4.2" */// iOS4.2より前
//[0.5.0]ヨコのときもタテと同じバナーを使用する
// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
//[0.5.0]ヨコのときもタテと同じバナーを使用する
 /* キーボードを隠す */// 回転アニメーションが終了した配置を定義する。 　この直前の配置から、ここの配置までの移動がアニメーション表示される。#if AzMAKE_SPLASHFACE
#endif
 /* iPhone */// iPad専用 メモリー(KeyMemorys_MAX=20)キー配置 および 回転処理
 /*＜＜この中で Ad回転処理もしている。 */// RaDrumButtons
// ibBuMemory：透明にして隠す。その後、改めて MvMemoryShow する
 /* 改めて表示 */// MARK:  View End
 /* 非表示になる直前にコールされる *//*
	 if (buChangeKey) {
	 //buChangeKey.backgroundColor = [UIColor clearColor]; // 前選択を戻す
	 // 復帰
	 [buChangeKey setBackgroundImage:RimgDrumButton forState:UIControlStateNormal];
	 buChangeKey = nil;
	 }*/
 /* dealloc, viewDidUnload から呼び出される */#if GD_Ad_ENABLED
 /* 停止 */ /* 解放メソッドを呼び出さないように　　　[0.4.1]メモリ不足時に落ちた原因 */ /* UIView解放		retainCount -1 */ /* alloc解放			retainCount -1 */ /*[0.4.20]受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる *///mMedibaAd.delegate = nil,			mMedibaAd = nil;
//mNendView.delegate = nil,		mNendView = nil;
//mAdWhirlView.delegate = nil,	mAdWhirlView = nil;
#endif

// RaDrums は破棄しない（ドラム記録を消さないため）deallocではreleaseすること。
//[0.4.1]//"Received memory warning. Level=2" 回避するため一元化
//不要//[mKeyView release], mKeyView = nil;  ＜＜ ibScrollLowerがオーナーだから。
//不要//[mKeyViewPrev release], mKeyViewPrev = nil;  ＜＜ ibScrollLowerがオーナーだから。// 裏画面(非表示)状態のときにメモリ不足が発生するとコールされるので、viewDidLoadで生成したOBJを解放する /* この後、viewDidLoadがコールされて、改めてOBJ生成される */// MARK: - GestureRecognizer Handler
 /* 上部で1指2タップ　＜＜指が離れたときにも呼び出される（2回）ことに注意 */ /* 選択中のロールを拡幅/縮小する *///[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
// ドラム幅を拡大する
// アニメ終了時の位置をセット
// Entryセル表示　＜＜この中でpickerView再描画
// アニメ開始
 /* 2本指で左へスワイプされた */// 次（右）ページへ
 /* 最初のページ へ */ /* Right *///[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
//assert(mKeyViewPrev==nil);
 /* スクロールが完全停止しないうちにスワイプしたときのため */ /* addSubview:直後にreleaseしているため、上でremoveしたならrelease不要。 */ /* スクロール限界オーバー */ /* 強制的に中央へ戻す */ /* 瞬間移動！ *///NG//[mKeyView removeFromSuperview]; これすると mKeyViewPrev が破棄されることになる。
// 新しいページを生成し、スクロール表示
 /* rect.origin.y=0になっているが垂直移動しないので無視される */// キーレイアウト変更モードならば、直前ページを保存する
 /* !=nil キーレイアウト変更モード */ /* 2本指で右へスワイプされた */// 前（左）ページへ
 /* 最終ページ へ */ /* Left *///[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
//assert(mKeyViewPrev==nil);
 /* スクロールが完全停止しないうちにスワイプしたときのため */ /* addSubview:直後にreleaseしているため、上でremoveしたならrelease不要。 */ /* スクロール限界オーバー */ /* 強制的に中央へ戻す */ /* 瞬間移動！ *///
//NG//[mKeyView removeFromSuperview]; これすると mKeyViewPrev が破棄されることになる。
// 新しいページを生成し、スクロール表示
 /* rect.origin.y=0になっているが垂直移動しないので無視される */// キーレイアウト変更モードならば、直前ページを保存する
 /* !=nil キーレイアウト変更モード */ /* 1本指でスワイプされた */ /* 秒後にクリアする */ /* 2回以上スワイプされたらヘルプメッセージを出す */// MARK: - UNIT 単位
 /*[1.0.10]キーボードスクロール時、単位キーの有無効を直前と同様にする */ /* = "SI基本単位:変換式;逆変換式" */ /* 注意 ↓ nil ↓ 渡すとエラーになる */// 同系列ハイライト
// 異系列グレーアウト
//NG//kb.enabled = NO;  ＜＜これをすると無効になったキーに薄い線が現れてしまう。
 /* OFF */// ノーマル
 /* =nil:ハイライト解除 */ /* =nil:ハイライト解除 */// MARK: キー表示

 /*[1.0.10] keyView のキー配置を記録する　＜＜キー配置変更時、ページ切替の都度、呼び出されて記録する。 */// 変化あり
 /* キーレイアウト変更モード // ドラム選択中のキーを割り当てる */ /* ドラム選択が無い場合、押したキーの選択にする */// 他リセット
// Tag
 /* Nothing Space */ /* 変更あり ⇒ 保存される */// Text
// Color
//button.titleLabel.textColor = [UIColor clearColor];
// Size
// Alpha
// Unit
 /* 変更あり ⇒ 保存される */// Text
 /*[M9]表示する　　＜＜ button.titleLabel.text = 代入はダメ */// Color
 /* iPadやや拡大 */// Alpha
// Unit
//[0.3.1]毎回、ドラムをリセットすることにした。
// 入力なければブランクメッセージ表示する
//ibTvFormula.font = [UIFont systemFontOfSize:14];  iPadのXIBで、フォントサイズを大きくしているため
// ブランクメッセージ表示中ならばクリアする
//ibTvFormula.font = [UIFont systemFontOfSize:20];
 /* バックグランドに入る前や終了前に呼び出される */// mKmPages を保存する
 /* バックグランドから復帰する前に呼び出される */// generalPasteboardの値を表示
 /*[PB] */ /*[M9] */// [UIPasteboard generalPasteboard].string そのまま表示
 /*[PB] */// ibBuMemory表示
//[1.0.9]常に DEFAULT PAGE に戻すようにした。
//NG//MiSvLowerPage = 1; // DEFAULT PAGE/*
- (void)MvKeyboardPage:(NSInteger)iPage
{
	//if (ibScrollLower.frame.origin.x / ibScrollLower.frame.size.width == iPage) return; // 既にiPageである。
	CGRect rc = ibScrollLower.frame;
	rc.origin.x = rc.size.width * iPage;
	[ibScrollLower scrollRectToVisible:rc animated:YES];
}*/

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
 /* iPad拡張 メモリー(KeyMemorys_MAX=20)キー配置 および 回転処理 */// .titleに値を保持しているため、破棄せずに表示だけ変更する
 /* !=nil キーレイアウト変更モード時、無効(NO)にして変更禁止する *///NG//kb.titleLabel.text = [dic objectForKey:@"Text"];
 /* 無効 */ /* blue */ /* 主に、ここでの配置変え（回転）のために記録する。 */// ヨコ ⇒ W254 H748 縦20行1列表示
// タテ ⇒ W768 H256 縦7行3列表示
 /* ドラム切り替え */// キーレイアウト変更モード
#if xxxOLDxxx
// ダブルタップ式
// Second (Double) Tapping：ドラム幅の拡大／均等を切り替える
// ドラム幅を拡大する
// First Tapping
 /* 0.5秒後にクリアする */#else
// シングルタップ式
//[self audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
// ドラム幅を拡大する
#endif

//BOOL bTouchAction = NO;
//[self audioPlayer:@"SentMessage.caf"];  // SMSの送信音
 /* 均等サイズに戻す */// アニメ終了時の位置をセット

// Entryセル表示　＜＜この中でpickerView再描画
// アニメ開始
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
 /* 数式へのキー入力処理 */// これ以降、localPool管理エリア
//NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
//
 /* .Tag は、AzKeyMaster.plist の定義が元になる。 *///---------------------------------------------[0]-[99] Numbers
 /* 再計算する *//*	case 10: // [A]  ＜＜HEX対応のため保留＞＞
				 case 11: // [B]
				 case 12: // [C]
				 case 13: // [D]
				 case 14: // [E]
				 case 15: // [F]
				 [entryNumber appendFormat:@"%d", (int)iKeyTag];
				 break; */

 /* [.]小数点 */ /* [00] */ /* 再計算する */ /* [000] */ /* 再計算する */ /* [+/-] */ /* [+] ⇒ [-] */ /* BS */ /* [-] ⇒ [+] */ /* BS */ /* <"0" or "9"< */// [+] ⇒ [-]置換
// [-] ⇒ [+]置換
// [-]挿入
// [-]挿入
 /* 再計算する */ /* [%]パーセント ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する */ /* 再計算する */ /* [‰]パーミル ------------------------------------次期計画では、entryUnitを用いて各種の単位対応する */ /* 再計算する */ /* [√]ルート */ /* [(] */ /* [)] */ /* 再計算する *///---------------------------------------------[100]-[199] Operators
 /* [=] */ /* 再計算する */ /* [+] */ /* [-] */ /* [×] */ /* [÷] */ /* [GT] Ground Total: 1ドラムの全[=]回答値の合計 */// 大外カッコを付ける
//---------------------------------------------[200]-[299] Functions
 /* [AC] */ /* [BS] */ /* 再計算する */ /* [SC] Section Clear：数式では1セクション（直前の演算子まで）クリア */ /* [+Tax] 税込み */ /* [-Tax] 税抜き */ /* 再計算する */// 再計算
 ///****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!//[localPool release];
 /*[MClear] */// 同じキーが2個以上配置されている可能性もあるので最後まで処理する
// アニメ終了時の状態をセット
 /* Memory Overflow */// 未使用メモリ（iTagMin）へ記録する
 /* [MClear] */ /* [=]でない *///
 /* 更新 */ /* Clear */ /*[PB] MClear */ /* [Memory]  ＜＜同じ値を続けて登録することも可とした＞＞ */// ドラムを逆回転させた行の数値 zCopyNumber が有効ならば優先コピー
 /* =NO:[Copy]後などドラムを動かしたくないとき */// entry値をコピーする　　＜＜stringFormatterを通すため、Mutable ⇒ NSString 変換が必要＞＞
 /* 先頭の"= "を除く *///
// [UIPasteboard generalPasteboard].string を 未使用メモリーKey へ登録する
 /* [Paste]　　＜＜ibBuMemoryから呼び出しているので.tagの変更に注意＞＞ */ /* [=]ならば新セクションへ改行する */ /* entryをarrayに追加し、entryを新規作成する */ /* Az数値文字列をセット */// 再計算
// アニメーション不要
 /* [M+] */ /* [M-] */ /* [M×] */ /* [M÷] */ /* Drumのみ */// ドラムを逆回転させた行の数値 zCopyNumber が有効
 /* =NO:[Copy]後などドラムを動かしたくないとき */// OK : entryNumber
// [][>]であれば、OK : entryNumber
// 演算中　entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理し、答えをentryNumberにセットする
// 計算処理する
// entry行に、この[=]が入るので、数値部に計算結果を入れる
// 0でなければそれを Ｍ−＋ する
//if ([drum.entryNumber doubleValue] != 0.0) {
 /* [M+] */ /* [M-] */ /* [M×] */ /* [M÷] */ /* iKeyTag 番号まちがい */// ペーストボードへ
// メモリへ記録する
 /* SettingVC:から呼び出される *////**************AZDropboxVC
/// // 未認証の場合、認証処理後、AzCalcAppDelegate:handleOpenURL:から呼び出される
/// if ([[DBSession sharedSession] isLinked]) 
/// {	// Dropbox 認証済み
/// GA_TRACK_EVENT(@"Dropbox",@"Auth",@"Authenticated", 0);
/// NSString *zHome = NSHomeDirectory();
/// NSString *zTmp = [zHome stringByAppendingPathComponent:@"tmp"]; // "Documents"
/// NSString *zPath = [zTmp stringByAppendingPathComponent:@"MyKeyboard.CalcRoll"];
/// // 先に.plist保存する
/// NSLog(@"zPath=%@", zPath);
/// NSDictionary *dic = nil;
/// if (iS_iPAD) {
/// dic = [[NSDictionary alloc] initWithObjectsAndKeys:
/// mKmPages,		@"PadPages", 
/// mKmPadFunc,	@"PadFunc",
/// nil];
/// } else {
/// dic = [[NSDictionary alloc] initWithObjectsAndKeys:
/// mKmPages,		@"Pages", 
/// nil];
/// }
/// [dic writeToFile:zPath atomically:YES];
/// if (iS_iPAD) {
/// DropboxVC *vc = [[DropboxVC alloc] initWithNibName:@"DropboxVC-iPad" bundle:nil];
/// vc.modalPresentationStyle = UIModalPresentationFormSheet;
/// vc.mLocalPath = zPath;
/// vc.delegate = self;
/// [self presentModalViewController:vc animated:YES];
/// } else {
/// DropboxVC *vc = [[DropboxVC alloc] initWithNibName:@"DropboxVC" bundle:nil];
/// vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
/// vc.mLocalPath = zPath;
/// vc.delegate = self;
/// [self presentModalViewController:vc animated:YES];
/// }
/// } else {
/// GA_TRACK_EVENT(@"Dropbox",@"Auth",@"Unauthenticated", 0);
/// // Dropbox 未認証
/// //[[DBSession sharedSession] link];
/// }
///*********

 /* 現在のToolBar状態をPushした上で、次画面では非表示にする */// Set up NEXT Left [Back] buttons.
//表示開始後にsetする
 /*//表示後にセットすること */// Function関係キー入力処理/*	switch (iKeyTag) {
		case KeyTAG_FUNC_Dropbox: // Dropbox authentication process
			[self GvDropbox];
			break;
	}*/// MARK: - IBAction


/*　[1.0.8]　UITapGestureRecognizer対応により以下没。
//[bu addTarget:self action:@selector(ibButtonDrag:) forControlEvents:UIControlEventTouchDragExit]; 
- (IBAction)ibButtonDrag:(KeyButton *)button // ダブルスイープスクロールのため
{
	NSLog(@"ibButtonDrag: Col=%d", (int)button.iCol);
	//ibScrollLower.scrollEnabled = YES; //スクロール許可
	//ibScrollLower.delaysContentTouches = YES; //スクロール操作検出のため0.5s先取する ⇒ これによりキーレスポンス低下する
}*/
 /* KeyButton TouchUpInside処理メソッド *///[self audioPlayer:@"Tock.caf"];  // キークリック音
 /* キーレイアウト変更モード // ドラム選択中のキーを割り当てる */ /* 計算モードのとき、スクロールロックする *///キー入力が始まるとスクロール禁止にする
//ibScrollLower.scrollEnabled = NO; //スクロール禁止
//ibScrollLower.delaysContentTouches = NO; //スクロール操作検出のため0.5s先取中止 ⇒ これによりキーレスポンス向上する
 /* ドラム逆回転やりなおしモード ⇒ formulaとentryを選択行まで戻す */// 遡った行の数値を「数値文字化」して copy autorelese object として保持する。
//
 /* iRow以降削除＆リセット */// entry行より下が選択されても、通常通りentry行入力にする。 
// [=]の後に数値キー入力すると改行(新セクション)になる。

// キー入力処理   先に if (button.tag < 0) return; 処理済み
 /*[1.0.2]数値キーレスポンス向上のため */ /*ドラム再表示 */ /*Fix//これが無いと[=]後の数値がカソール下に残る */ /* 以下の処理を通らない分だけレス向上 */ /*[KeyTAG_STANDARD_Start-KeyTAG_STANDARD_End]---------Standard Keys */ /*[KeyTAG_MEMORY_Start-KeyTAG_MEMORY_End]----------Memory Keys */ /*[KeyTAG_MSTORE_Start-KeyTAG_MSTROE_End]-------Memory STORE Keys */// "M"でない。 メモリ値有効 ⇒ ペーストボードへ
 /* [=]ならば新セクションへ改行する */// entryをarrayに追加し、entryを新規作成する
 /* ERROR */ /* Az数値文字列をセット */// 再計算
// アニメーション：他のボタン同様にentryに際してはアニメなし
 /*----------Function Keys */ /*[KeyTAG_UNIT_Start-KeyTAG_UNIT_End *///[self MvKeyUnitGroup:button]; // 同系列単位のボタンをハイライト ＆ 以外をノーマルに戻す
 /* ドラム再表示 */// [M]ラベル表示
#if GD_Ad_ENABLED
/*	if (MiSvUpperPage==0) { // [AC]
		if (button.tag==KeyTAG_AC) { // [AC]
			bADbannerTopShow = YES;
			[self adShow:YES];
		} else {
			bADbannerTopShow = NO; //[1.0.1]//入力が始まったので[AC]が押されるまで非表示にする
			[self adShow:NO];
		}
	}*/
#endif
 /* ドラム ⇒ 数式 転記 */// 再計算
 /* Paste処理させる */// キーレイアウト変更モードならば、現ページを保存する
 /* !=nil キーレイアウト変更モード */ /* mKmPages から mKmMemory を生成する */ /* mKmPages　を　standardUserDefaults へ保存する */ /* 世界共通名称 */#if GD_Ad_ENABLED
#else
 /* ローカル名称 */#endif
// MARK: - delegate UIPickerView
#if AzMAKE_SPLASHFACE
 /* (ROWOFFSET)タイトル行 + Drum(array行数) + 1(entry行) */#endif
// 幅 /* entryComponentを拡大する *//*  viewForRow:と共用はできない！
- (NSString *)pickerView:(UIPickerView *)pickerView 
			 titleForRow:(NSInteger)row 
			forComponent:(NSInteger)component
{
	return nil;
}
*/
 /* キーボード変更モード */// lb addSubview
// vi再利用可能なとき
// ドラタク通常モード
// addSubview
 /*-Condensed-ExtraBold  boldSystemFontOfSize:20]; */#if AzFREE
 /*@"Free";   //NSLocalizedString(@" Azukid",nil); */#else
#endif
#if !AzDEBUG
 /* 開始行の記号は非表示 */ /* OP_STARTより後の文字 [√] */#endif
 /* Unicode[002D] *///zOpe = MINUS_SIGN; // Unicode[2212]
// 演算子（OP_SUB=Unicode[002D]）を表示文字（MINUS_SIGN=Unicode[002D]）に置換する
 /* drum.formula 表示 */ /* 回答＆演算子 */// 先頭が"@"ならば以降の文字列をそのまま表示する（エラーメッセージ表示）
 /* 先頭の"@"を除いて表示 */ /* bFormat=NO ⇒ 入力通りに表示させる */ /* キーボード変更モード */// 他リセット
 /* NO=「ドラム逆転やりなおしモード」を一時無効にする */ /* YES=「ドラム逆転やりなおしモード」を許可 */ /* キーボードを隠す *///[self soundSwipe];
// スクロールして画面が静止したときに呼ばれる /* 数式側：常に (1)Formula にする */// 全単位ボタンを無効にする
#if GD_Ad_ENABLED
//[self adShow:YES];	
#endif
 /* ドラム側：設定方式に戻す */#if GD_Ad_ENABLED
//[self adShow:YES];	
#endif
// MARK: - delegate UITextView

// 数式(TextView)をタッチして拡張するときの高さ拡張量を返す /* 日本語キーになるとファンクション行があらわれてMemoryとAnswer行の一部が隠れるが、通常Asciiキーなので問題にしない。 */ /* ヨコ */ /* タテ *///=================================================================ibTvFormula delegate /* [Done]するまでスクロール禁止にする *///[self audioPlayer:@"unlock.caf"];  // ロック解除音
// アニメ終了時の位置をセット
 /* iPad */// アニメ開始
 /* アニメ終了後、 *///[self audioPlayer:@"lock.caf"];  // ロック音
 /* スクロール許可 */ /* 戻りは早く */ /*アニメーション終了後に呼び出す＜＜setAnimationDelegate必要 */// アニメ終了時の位置をセット
 /* iPad */// アニメ開始
// 再計算
 /* [BS] */ /* [Done] */ /* キーボードを隠す */// ペーストによる文字列ならば無条件許可する
 /* [CalcFunctions zFormulaFilter:]処理必要 */// この直後、textViewDidChange が呼び出される。
 /* 入力許可文字 */ /* キーボードを隠す */// MARK: - <AZDropboxDelegate>
 /*Up前処理＜UPするファイルを準備する＞ *///NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
//[kvs synchronize]; // iCloud最新同期（取得）

// キーレイアウト を filePath へ書き出す           crypt未対応
 /*OK */// mKmPages リセット
 /* .CalcRoll - Plist file *///結果　　ここで、成功後の再描画など行う /*=nil:Up成功 */// /*=nil:Down成功 *///// MARK: - AVAudioPlayer
 /* 0.0〜1.0 */ /* 0.0〜1.0 */ /* 0.0〜1.0 */ /* 0.0〜1.0 */ /* 0.0〜1.0 */#if (TARGET_IPHONE_SIMULATOR)
// シミュレータで動作している場合のコード
 /* iAd取得成功（広告内容あり） */// iAd取得できなかったときに呼ばれる　⇒　非表示にする /* iAd取得失敗（広告内容なし） */// これは、applicationDidEnterBackground:からも呼び出される//[1.1.6]Ad隠さない、常時表示する。
//if (bADbannerTopShow==NO) {
//	bShow = NO;
//}

 /* 上層にする */ /* 上層にする */#endif