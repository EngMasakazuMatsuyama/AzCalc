//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  Drum.swift
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

//
//  Drum.swift　＜＜＜BCD.cpp関数を利用しているため.mmにする必要がある＞＞＞
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/20.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

import Foundation

let DRUM_RECORDS = 200 // 1ドラムの最大行数制限

// 再計算して単位表示する			    (-1)entryUnit
var zRevers = zUnit(-1, withPara: 3) // (3)逆変換式
// ドラムから計算式作成
var zForm = zFormulaFromDrum()
// [;]で区切られたコンポーネント(部分文字列)を切り出す
var arUnit = zUnit?.components(separatedBy: KeyUNIT_DELIMIT)
// 末尾から評価する式の区間を求める
var idxTop = 0
var idxEnd = formulaOperators.count() - 1
var idx = idxEnd
//idx
var zOpe = formulaOperators[idx] as? String
//idx
// 
var zUnitSI: String? = nil
var zUni: String?
var zOpe: String?
var iDim = 0
var iDimAns = 0 // 直前までの次元
var iDimAnsFix = -1 // [+][-]による次元決定、以後異なる次元になれば単位に"?"表示
var bMMM = false // YES=メートル系
var idx = idxTop
//entryOperator
// UNIT  SI基本単位変換
var arUnit = zUni?.components(separatedBy: KeyUNIT_DELIMIT)
//iDim
//iDim
//iDim
//iDimAns // 回答の次元が異なれば単位に"?"表示する
var zForm = zFormulaFromDrum()
// [=]行ならば iDimMax 次元
// ドラムから計算式作成
var zForm = zFormulaFromDrum()
// 回答に最適な単位にする
var zOpUnit = zOptimizeUnit(zUnitSI, withNum: Double(entryNumber ?? "") ?? 0.0)
// 最適な単位が、SI単位と違うので変換する
var zRevers = zUnitPara(zOpUnit, withPara: 3) // (3)逆変換式
abs(dNum)
//zUnitSI
//entryOperator
//entryNumber
var zUni: String?
//entryUnit
// [;]で区切られたコンポーネント(部分文字列)を切り出す
var zz = zUnitPara(zUni, withPara: iPara)
//zz
var zOpe = zOperator(iRow)
var range = NSRange(location: iRow, length: formulaOperators.count() - iRow)
var alert = UIAlertView(title: NSLocalizedString("Final answer", comment: ""), message: NSLocalizedString("Final answer msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
// 再計算
var zFormula = zFormulaFromDrum()
//zFormula
//entryNumber
//entryNumber
// ドラム情報から計算文字列式を生成する
var zFormula = ""
var iRowStart = 0 // 最初から
//entryRow
//iRowStart
// 計算対象範囲は、iRowStart 〜 iRowEnd まで
var iRowEnd = entryRow
var zOpe: String?
var zNum: String?
var zUni: String?
var zUnitFormat: String?
var idx = iRowStart
//iRowEnd
// UNIT  SI基本単位変換
var arUnit = zUni?.components(separatedBy: KeyUNIT_DELIMIT)
//zFormula
var zFormula = zFormulaFromDrum() // autorelease
//entryAnswer

class Drum: NSObject {
    private var appDelegate: AzCalcAppDelegate? // initにて = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
    private var formulaOperators: [AnyHashable]? // entryOperatorをaddする
    private var formulaNumbers: [AnyHashable]? // entryNumberをaddする
    private var formulaUnits: [AnyHashable]? // entryUnit をaddする
    // Az数値文字列（使用文字は、[+][-][.][0〜9]のみ、スペース無し）
 // Az数値文字列：前行までの回答値、あれば演算子の前に表示する。数値入力が始まれば非表示
 // NSArray にして MaOperator へ追加する
 // Az数値文字列：入力中は文字列扱いする ＜＜小数以下の0を表示するため ＆ [BS]処理が簡単
 // 単位 [%][‰] [mm][cm][m][km] [￥][＄]
 // 現在選択行　>=0 And <= [aOperators count];
    // Setting
    private var MiSegCalcMethod = 0
    private var MiSegDecimal = 0
    private var MiSegRound = 0
    private var MiSegReverseDrum = 0
    private var MfTaxRate: Float = 0.0

    var entryAnswer: String?
    var entryOperator: String?
    var entryNumber: String?
    var entryUnit: String?
    var entryRow = 0

    func entryUnitKey(_ keybu: KeyButton?) {
    } // 単位キー処理

    func vNewLine(_ zNextOperator: String?) -> Bool {
    } // entryをarrayに追加し、entryを新規作成する

    //- (void)vCalcing:(NSString *)zNextOperator;
    func vEnterOperator(_ zOperator: String?) {
    }

    func zFormulaFromDrum() -> String? {
    } // ドラム ⇒ 数式

    func zAnswer() -> String? {
    }

    func zFormulaCalculator() -> String? {
    } // ドラム ⇒ ibTvFormula用の数式文字列

    // UNIT Convert
    //- (NSString *)zUnitSiFromDrum;	// 現在のドラムで使われているUNIT-SI基本単位
    //- (NSString *)zUnitRebuild;		// UNITを使用している場合、その系列に従ってキーやドラム表示を変更する
    func gvEntryUnitSet() {
    }

    // formulaOperators,formulaNumbers,formulaUnits を隠匿するためのメソッド
    func zOperator(_ iRow: Int) -> String? {
    }

    func zNumber(_ iRow: Int) -> String? {
    }

    func zUnitPara(_ zUnit: String?, withPara iPara: Int) -> String? {
    }

    func zUnit(_ iRow: Int, withPara iPara: Int) -> String? {
    }

    func zUnit(_ iRow: Int) -> String? {
    }

    func zAnswer() -> String? {
    }

    func vRemove(fromRow iRow: Int) {
    }
    //- (void)vEditFromRow:(NSInteger)iRow;



    //+ (NSString *)strNumber:(NSString *)sender;


    //@synthesize formulaOperators, formulaNumbers, formulaUnits;
 // 初期化

    // MARK: - NSObject lifecicle


    override init() {
        super.init()
        appDelegate = UIApplication.shared.delegate as? AzCalcAppDelegate

        formulaOperators = []
        formulaNumbers = []
        formulaUnits = []

        entryAnswer = ""
        entryOperator = OP_START
        entryNumber = ""
        entryUnit = ""

        entryRow = 0
        //dMemory = 0.0;

        reSetting()

    }

 // Settingリセット

    // MARK: - Function

    func reSetting() {
        let defaults = UserDefaults.standard
        // Setting
        MiSegCalcMethod = defaults.integer(forKey: GUD_CalcMethod)
        MiSegDecimal = defaults.integer(forKey: GUD_Decimal)
        if DECIMAL_Float <= MiSegDecimal {
            MiSegDecimal = PRECISION // [F]小数桁制限なし
        }
        MiSegRound = defaults.integer(forKey: GUD_Round)
        MiSegReverseDrum = defaults.integer(forKey: GUD_ReverseDrum)
        MfTaxRate = 1.0 + defaults.float(forKey: GUD_TaxRate) / 100.0 // 1 + 消費税率%/100
    }

 // = [formulaOperators count];
    func count() -> Int {
        return formulaOperators?.count ?? 0
    }

    func iNumLength(_ zNum: String?) -> Int {
        // [-][.] を取り除く
        var z = zNum?.replacingOccurrences(of: OP_SUB, with: "")
        z = z?.replacingOccurrences(of: NUM_DECI, with: "")
        return z?.count ?? 0
    }

 // キー入力処理

    // MARK: - Key function

    //- (void)entryKeyTag:(NSInteger)iKeyTag keyButton:(KeyButton *)keyButton  // キー入力処理
    func entryKeyButton(_ keyButton: KeyButton?) {
        AzLOG("entryKeyButton: (%d)", keyButton?.tag)

        // これ以降、localPool管理エリア
        //NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
        // 以後、return;使用禁止！すると@finallyを通らず、localPoolが解放されない。

        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
        SwiftTryCatch.try({
            switch keyButton?.tag {
            //---------------------------------------------[0]-[99] Numbers
            case 0, 1, 2, 3, 4, 5, 6, 7, 8, 9:
                if entryOperator == OP_ANS {
                    // [=]ならば新セクションへ改行する
                    if vNewLine(OP_START) {
                        // entryをarrayに追加し、entryを新規作成する
                        entryNumber = (entryNumber ?? "") + "\(Int(keyButton?.tag ?? 0))"
                        gvEntryUnitSet() // entryUnitと単位キーを最適化
                    }
                }
                if PRECISION - 2 <= (entryNumber?.count ?? 0) {
                    // [-][.]を考慮して(-2)
                    // 改めて[-][.]を除いた有効桁数を調べる
                    if PRECISION <= iNumLength(entryNumber) {
                        // 有効桁数に到達
                    }
                }
            default:
                break
            }
            if entryNumber?.hasPrefix("0") ?? false {
                OR
            }
            entryNumber?.hasPrefix("-0")
            do {
                let rg = (entryNumber as NSString?)?.range(of: NUM_DECI)
                if rg?.location == NSNotFound {
                    // 小数点が無い ⇒ 整数部である
                    if 0 < (keyButton?.tag ?? 0) {
                        // 末尾の[0]を削除して数値を追加する
                        if let subRange = Range<String.Index>(NSRange(location: (entryNumber?.count ?? 0) - 1, length: 1), in: entryNumber) { entryNumber?.removeSubrange(subRange) } // 末尾より1字削除
                    } else {
                        break // 2個目以降の[0]は無効
                    }
                }
            }
            entryNumber = (entryNumber ?? "") + "\(Int(keyButton?.tag ?? 0))"
            break
        }, catch: { exception in
        }, finallyBlock: {
        })
    }
}

extension Drum {
 // entryをarrayに追加し、entryを新規作成する
}

 ///****************************!!!!!!!!!!!!!!!!必ず通ること!!!!!!!!!!!!!!!!!!!//[localPool release];
 /* 単位キー処理 */// これ以降、localPool管理エリア
//NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
 /* 単位表示 */ /* ; */ /* SI基本単位;への変換式;戻す式 */// UNIT逆変換式："#" ⇒ "%@" Format文字に変更する
 /* 逆変換式を加える */// 単位変換後に丸め処理される
 ///****************************!!!!!!!!!!!!!!!!必ず通る!!!!!!!!!!!!!!!!!!!//[localPool release];
// MARK: - Unit function

// iPara = (0)表示単位 (1)SI基本単位　(2)変換式　(3)逆変換式 /* 未定義　(1)以降が未定義ならば「単位」でない。 */// 直前までの式を評価して次に使用可能な単位キーを有効にし、entryUnit へ適切な単位をセットする。
// 演算子入力時やドラム切り替え時などに呼び出される。 /* 全単位有効 */ /* 単位なし */ /* idxEnd+1 */ /*entryUnit; ここは、この単位を求めるための処理である */ /* (1)SI基本単位 */ /* 平方 */ /* 立方 */ /* 長さ系でない1次元単位 */ /* [>] */ /* [×] */ /* [÷] */ /* [+][-][=] *///
 /* 次元決定 */ /* 回答の次元が決定次元と異なるので単位に"?"表示する */// 単位＜矛盾＞
 /* メートル系 */ /* メートルのみ */ /* 平方メートルのみ */ /* 立方メートルのみ */ /* 単位なし　全単位無効 */ /* メートル系でない1次元単位 "Kg" など */// zUnitSI そのまま
//[[zUnitSI retain] autorelease];	//[1.0.10]保持する
 /* 単位なし　全単位無効 */// ↓↓↓ zUnitSI ↓↓↓ 必須
// UNIT逆変換式："#" ⇒ "%@" Format文字に変更する
 /* 逆変換式を加える */// 単位変換後に丸め処理される
 /* メートル系 */ /* iDimAns以下の選択が可能 *///[entryUnit setString:@"m;m;#;#"];
//[entryUnit setString:@"㎡;㎡;#;#"];
//[entryUnit setString:@"㎥;㎥;#;#"];
 /* 単位なし　全単位無効 *///[entryUnit setString:@""];
 /* 単位は都度入力する方が便利だと判断した。 */ /* メートル系でない1次元単位 *///NG//[entryUnit setString:zUnitSI];
// 単位なし　全単位無効
// zUnitSI系列でzNumに最適な単位を返す /* 平方 */ /* 立方 */ /* 表示単位 */// MARK: - Drum function
 /* iRow以降削除（ドラム逆回転時に使用） */ /* 開始行を維持する。　削除する前に処理すること！ */ /* [=] */// entry値クリア
// これまでの式を評価して次に使用可能な単位キーを有効にし、entryUnit へ適切な単位をセットする。
/*没！ [1.1]仕様として根本的な解決を図ること！
- (void)vEditFromRow:(NSInteger)iRow // iRow行クリア ＆ Entry行リセット （ドラム逆回転時に使用）
{
	assert([formulaOperators count]==[formulaNumbers count]);
	assert([formulaOperators count]==[formulaUnits count]);

	NSString *zOpe = [self zOperator:iRow];
	if ([zOpe hasPrefix:OP_START]) { // 開始行を維持する。　削除する前に処理すること！
		[entryOperator setString:OP_START];
	} 
	else if ([zOpe hasPrefix:OP_ANS]) { // [=]
		[entryOperator setString:@""];
	} 
	else {
		[entryOperator setString:zOpe];
	}

	// entryEditRow クリア
//	[formulaOperators replaceObjectAtIndex:iRow withObject:@""];
//	[formulaNumbers replaceObjectAtIndex:iRow withObject:@""];
//	[formulaUnits replaceObjectAtIndex:iRow withObject:@""];
	//entryEditRow = iRow;  // entryを記録する行	　通常は、(-1)末尾
	entryRow = iRow;	// vNewLineにて末尾追加でなく、置換処理される
	// entry値クリア
	[entryNumber setString:@""]; 
	[entryAnswer setString:@""]; 
	// これまでの式を評価して次に使用可能な単位キーを有効にし、entryUnit へ適切な単位をセットする。
	//[self GvEntryUnitSet];
}
*/
 /* entryをarrayに追加し、entryを新規作成する */ /* 1ドラム最大行数制限 */ /* 最終行オーバー：entry行に[=]回答を表示する */ /* 最終行オーバーにつき拒否 */// 最終行
// Operator: entryをarrayに追加し、entryを新規作成する
// Number: entryをarrayに追加し、entryを新規作成する
// Unit: entryをarrayに追加し、entryを新規作成する
// Answer: addObjectしないのでクリアするだけ。
// formula へ addObject しているのはここだけ。 要素数は、必ず一致すること。
// もし、ここでエラー発生したときは、「ドラム逆回転時の処理」で削除が適切に行われているか確認すること。
//============================================================================================
// 演算子(zOperator) を加えて改行する。  [=]ならば回答行になる
//============================================================================================ /* [=]＆数値あり ⇒ 新しい演算子に置き換えて数値クリア */ /* ここまでの回答を演算子の前に表示する */ /* 数値クリア */ /* entryUnitと単位キーを最適化 */ /* 演算子＆数値あり ⇒ 改行 */// entryの演算子と数値が有効であるなら追加計算
// entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理する
 /* 改行（新しい行を追加） */ /* 改行成功 */ /* [=]ならば、計算結果表示 */// ここまでの回答を演算子の前に表示する
 /* entryUnitと単位キーを最適化 */ /* 改行失敗（行数オーバーで追加できなかった） */ /* 数値未定 ⇒ 演算子セットして単位あれば最適化 */ /* 数値未定＆開始行：演算子[>]の置換禁止 */ /* 数値未定＆開始行＆[-] ⇒ マイナス符号ON/OFF  ＜＜数値あれば演算子扱いになる＞＞ */// 先頭が"-"ならば、先頭の"-"を削除する
// 先頭に"-"を挿入する　＜＜数値未定の場合、符号だけ先に入ることになる＞＞
 /* 回答クリア */ /* 開始行でなければ演算子を置換 */ /* entryUnitと単位キーを最適化 */ /* 演算子なし */ /* entryUnitと単位キーを最適化 *////****	
/// //============================================================================================
/// // entryを追加してから、直近の[=]の次行以降、今追加した行まで計算処理する
/// //============================================================================================
/// - (void)vCalcing:(NSString *)zNextOperator
/// {
/// [self vEnterOperator:zNextOperator];
/// return;
/// if ([entryNumber length]<=0) {
/// // 数値未定
/// if (! [entryOperator hasPrefix:OP_START]) { // 開始行でない！ならば、演算子だけ変更して計算しない
/// [entryOperator setString:zNextOperator];
/// [self GvEntryUnitSet]; // entryUnitと単位キーを最適化
/// }
/// return;
/// }
/// //AzLOG(@"********************************entryUnit=1=[%@]", entryUnit);
/// // 新しい行を追加する
/// if (![self vNewLine:zNextOperator]) return; // NO=行数オーバーで追加できなかった。
/// if ([zNextOperator isEqualToString:OP_ANS]) {
/// // [=]が押されたならば、計算結果表示
/// [entryNumber setString:[self zAnswerDrum]];
/// }
/// else {
/// // ここまでの回答を演算子の前に表示する
/// [entryAnswer setString:[self zAnswerDrum]]; 
/// }
/// [self GvEntryUnitSet]; // entryUnitと単位キーを最適化
/// return;
/// }
///********


// MARK: - Formula
 /* ドラム ⇒ ibTvFormula用の数式文字列 */ /*[=]を含めないようにする */ /* 開始行 */// 開始行の演算子には[>]が入っている。その右に入る可能性があるのは今の所、[√]だけ。
 /* ドラム ⇒ 数式 */// 現在行より前にある[=][GT]行の次から計算する　＜＜セクション単位に計算する
 /* 直前の[=]の次にする */ /* 直前の[>GT]の次にする */// stringFormatter(小数末尾のZero除去) さらに stringAzNum(区切記号を除去)
// 演算子部
 /* 開始行 */// 開始行の演算子には[>]が入っている。その右に入る可能性があるのは今の所、[√]だけ。
 /* OP_STARTより後の文字 [√] *///AzLOG(@"--zOpe=%@", zOpe);

// 数値部 ＆ 単位部
// ＋％増　＜＜シャープ式： a[+]b[%] = aのb%増し「税込」と同じ＞＞ 100+5% = 100*(1+5/100) = 105
// ー％減　＜＜シャープ式： a[-]b[%] = aのb%引き「税抜」と違う！＞＞ 100-5% = 100*(1-5/100) = 95
 /* 1/100 */// ＋‰増　＜＜シャープ式： a[+]b[‰] = aのb%増し＞＞
// ー‰減　＜＜シャープ式： a[-]b[‰] = aのb%引き＞＞
 /* 1/1000 */ /* (0)表示単位 (1)SI基本単位　(2)変換式　(3)逆変換式 */// UNIT変換式："#" ⇒ "%@" Format文字に変更する
//AzLOG(@"--zFormula=%@", zFormula);
// 数値と演算子の間のスペースはあってもなくても大丈夫
// localPoolが解放される前に確保しておく
// retainCount=1
 /* nilにすると、戻り値を使った setString:で落ちる */ /* nilにすると、戻り値を使った setString:で落ちる *///[autoPool release];
//if ([zFormula retainCount]==1)
//	[zFormula autorelease];  // @""ならば不要だから
 /* ドラム ⇒ 数式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え */ // autorelease