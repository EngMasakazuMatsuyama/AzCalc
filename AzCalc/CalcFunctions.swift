//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  CalcFunctions.swift
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//
//  CalcFunctions.m
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

import Foundation

let PRECISION = 15 // 有効桁数＝整数桁＋小数桁（小数点は含まない）
let FORMULA_MAX_LENGTH = 200 // 数式文字列の最大長

// Operator String
let OP_START = ">" // 願いましては
let OP_ADD = "+" // 加算
let OP_SUB = "-" // 減算 Unicode[002D] 内部用文字（String ⇒ doubleValue)変換のために必須
let OP_MULT = "×" // 掛算
let OP_DIVI = "÷" // 割算
let OP_ANS = "=" // 答え
let OP_GT = ">GT" // 総計 ＜＜1字目を OP_START にして「開始行」扱いすることを示す＞＞
let OP_ROOT = "√" // ルート

// Number String
let NUM_0 = "0"
let NUM_DECI = "." // 小数点

// Unit String
let UNI_PERC = "%" // パーセント
let UNI_PERML = "‰" // パーミル
let UNI_AddTAX = "+Tax" // 税込み
let UNI_SubTAX = "-Tax" // 税抜き

//----------------------------------------------------------NSMutableArray Stack Method


private var MiSegCalcMethod = 0
private var MiSegDecimal = 0
private var MiSegRound = 0
// MARK: -

func levelOperator(_ zOpe: String?) -> Int {
    if (zOpe == "*") || (zOpe == "/") {
        // この優先付けでは、有理化はできない。
        return 1
    } else if (zOpe == "+") || (zOpe == "-") {
        if MiSegCalcMethod == 0 {
            return 1 // 電卓方式につき四則同順
        }
        return 2
    }
    return 3 // "(" ")" その他の演算子
}

class CalcFunctions: NSObject {
    // クラスメソッド（グローバル関数）
    class func setCalcMethod(_ i: Int) {
        MiSegCalcMethod = i // (0)Calculator  (1)Formula
    }

    class func setDecimal(_ i: Int) {
        MiSegDecimal = i
    }

    class func setRound(_ i: Int) {
        MiSegRound = i
    }

    class func zFormulaFilter(_ zForm: String?) -> String? {
        let zList = "0123456789. +-×÷*/()" // 数式入力許可文字
        var z: String?
        var zOuts = ""
        var rg: NSRange
        for i in 0..<(zForm?.count ?? 0) {
            z = (zForm as NSString?)?.substring(with: NSRange(location: i, length: 1))
            rg = (zList as NSString).range(of: z ?? "")
            if rg.length == 1 {
                // 許可文字
                zOuts = zOuts + (z ?? "")
            }
        }
        return zOuts
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
    class func zAnswer(fromFormula zFormula: String?) -> String? {
        AzLOG("zAnswerFromFormula: zFormula=%@", zFormula)
        if (zFormula?.count ?? 0) <= 0 {
            return "" // nilにすると、戻り値を使った setString:で落ちる
        }
        if (zFormula?.count ?? 0) <= 2 {
            // 式を構成できない
            return zFormula
        }
        if FORMULA_MAX_LENGTH < (zFormula?.count ?? 0) {
            return "@Game Over =" // 先頭を@にすると stringFormatter() で変換されずに@以降が返されてドラムに表示される
        }

        var maStack: [AnyHashable] = [] // - Stack Method
        var maRpn: [AnyHashable] = [] // 逆ポーランド記法結果
        var zAnswer = "" // nilにすると、戻り値を使った setString:で落ちる

        //-------------------------------------------------localPool BEGIN >>> @finaly release
        //NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
        // TODO: import SwiftTryCatch from https://github.com/ypopovych/SwiftTryCatch
        SwiftTryCatch.try({
            // 数式整理
            var zTemp = zFormula?.replacingOccurrences(of: " ", with: "") // [ ]スペース除去
            var zFlag: String? = nil
            if zTemp?.hasPrefix("-") ?? false || zTemp?.hasPrefix("+") ?? false {
                // 先頭が[-]や[+]ならば符号として処理する
                zFlag = (zTemp as NSString?)?.substring(to: 1) // 先頭の1字
                zTemp = (zTemp as NSString?)?.substring(from: 1) // 先頭の1字を除く
            }

            // マイナス「符号」⇒ "s"
            zTemp = zTemp?.replacingOccurrences(of: "×-", with: "×s")
            zTemp = zTemp?.replacingOccurrences(of: "÷-", with: "÷s")
            zTemp = zTemp?.replacingOccurrences(of: "+-", with: "+s")
            zTemp = zTemp?.replacingOccurrences(of: "--", with: "-s")
            zTemp = zTemp?.replacingOccurrences(of: "(-", with: "(s")
            // 残った "-" は「演算子」なので " - " にする	"-("  ")-"
            zTemp = zTemp?.replacingOccurrences(of: "-", with: " - ")
            // "s" を "-" にする
            zTemp = zTemp?.replacingOccurrences(of: "s", with: "-")

            // プラス「符号」⇒ ""
            zTemp = zTemp?.replacingOccurrences(of: "×+", with: "×")
            zTemp = zTemp?.replacingOccurrences(of: "÷+", with: "÷")
            zTemp = zTemp?.replacingOccurrences(of: "++", with: "+")
            zTemp = zTemp?.replacingOccurrences(of: "-+", with: "-")
            zTemp = zTemp?.replacingOccurrences(of: "(+", with: "(")

            // 演算子の両側にスペース挿入
            zTemp = zTemp?.replacingOccurrences(of: "*", with: " * ") // 前後スペース
            zTemp = zTemp?.replacingOccurrences(of: "/", with: " / ") // 前後スペース
            zTemp = zTemp?.replacingOccurrences(of: OP_MULT, with: " * ") // "×"半角文字化
            zTemp = zTemp?.replacingOccurrences(of: OP_DIVI, with: " / ") // "÷"半角文字化
            zTemp = zTemp?.replacingOccurrences(of: OP_ROOT, with: " √ ") // 前後スペース挿入
            zTemp = zTemp?.replacingOccurrences(of: "+", with: " + ") // [-]は演算子ではない
            zTemp = zTemp?.replacingOccurrences(of: "(", with: " ( ")
            zTemp = zTemp?.replacingOccurrences(of: ")", with: " ) ")

            if let zFlag = zFlag {
                zTemp = zFlag + (zTemp ?? "") // 先頭に符号を付ける
            }
            // スペースで区切られたコンポーネント(部分文字列)を切り出す
            let arComp = zTemp?.components(separatedBy: " ")
            print("arComp[]=\(arComp ?? [])")

            let iCapLeft = 0
            let iCapRight = 0
            let iCntOperator = 0 // 演算子の数　（関数は除外）
            let iCntNumber = 0 // 数値の数
            var zTokn: String?
            var zz: String?

            for index in 0..<(arComp?.count ?? 0) {
                zTokn = arComp?[index]
                AzLOG("arComp[%d]='%@'", index, zTokn)

                if (zTokn?.count ?? 0) < 1 || zTokn?.hasPrefix(" ") ?? false {
                    // パス
                } else if Double(zTokn ?? "") ?? 0.0 != 0.0 || zTokn?.hasSuffix("0") ?? false {
                    // 数値ならば
                    iCntNumber += 1
                    maRpn.push(zTokn)
                } else if zTokn == "√" {
                    maStack.push(zTokn) // スタックPUSH
                } else if (zTokn == ")") {
                    iCapRight += 1
                    while (zz = maStack.pop() as? String) {
                        // "("までスタックから取り出してRPNへ追加、両括弧は破棄する
                        if (zz == "(") {
                            break // 両カッコは、破棄する
                        }
                        maRpn.push(zz)
                    }
                } else if (zTokn == "(") {
                    iCapLeft += 1
                    maStack.push(zTokn)
                } else {
                    while 0 < maStack.count {
                        //			 スタック最上位の演算子優先順位 ＜ トークンの演算子優先順位
                        if let lastObject = maStack.last {
                            print("+++++[maStack lastObject]=(\(lastObject)) <= (\(zTokn ?? ""))")
                        }
                        if levelOperator(maStack.last as? String) <= levelOperator(zTokn) {
                            print("+++++ YES")
                            zz = maStack.pop() as? String
                            maRpn.push(zz) // スタックから取り出して、それをRPNへ追加
                        } else {
                            print("+++++ NO")
                            break
                        }
                    }
                    // スタックが空ならばトークンをスタックへ追加する
                    iCntOperator += 1
                    maStack.push(zTokn)
                }
            }
            // スタックに残っているトークンを全て逆ポーランドPUSH
            while (zz = maStack.pop() as? String) {
                maRpn.push(zz)
            }
            // 数値と演算子の数チェック
            if iCntNumber < iCntOperator + 1 {
                // 先頭の @ が無ければ、桁区切り処理されてしまう。
                throw NSLocalizedString("@Excess Operator", comment: "")
                // @演算子過多
            } else if iCntNumber > iCntOperator + 1 {
                throw NSLocalizedString("@Lack Operator", comment: "")
                // @演算子不足
            }
            // 括弧チェック
            if iCapLeft < iCapRight {
                throw NSLocalizedString("@Excess Closing", comment: "")
                // @閉じ過ぎ
            } else if iCapLeft > iCapRight {
                throw NSLocalizedString("@Unclosed", comment: "")
                // @閉じていない
            }

            print("***maRpn=\(maRpn)\n")
            #if AzDEBUG
            for index in 0..<maRpn.count {
                AzLOG("maRpn[%d]='%@'", index, maRpn[index])
            }
            #endif


            //-------------------------------------------------------------------------------------
            // maRpn 逆ポーランド記法を計算する
            //-------------------------------------------------------------------------------------
            // スタック クリア
            maStack.removeAll() //iStackIdx = 0;

            var zNum: String? // 一時用
            let cNum1 = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
            let cNum2 = [Int8](repeating: 0, count: SBCD_PRECISION + 100)
            let cAns = [Int8](repeating: 0, count: SBCD_PRECISION + 100)

            for index in 0..<maRpn.count {
                var zTokn = maRpn[index] as? String

                if zTokn == "√" {
                    if 1 <= maStack.count {
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        // 倍精度実数演算で近似値を求める
                        var d = Double(zNum ?? "") ?? 0.0
                        if d < 0 {
                            return "@Complex" // 虚数(複素数)になる
                        }
                        d = sqrt(d)
                        zNum = String(format: "%.9f", d)
                        strcpy(cAns, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        for i in 0..<10 {
                            stringDivision(cNum2, cNum1, cAns) // N2 = N1 / A
                            stringAddition(cAns, cAns, cNum2) // A = A + N2

                            stringDivision(cNum2, cAns, Int8("2\0")) // N2 = A / 2
                            stringSubtract(cAns, cAns, cNum2) // A = A - N2

                            stringMultiply(cNum2, cAns, cAns) // N2 = A * A
                            stringSubtract(cNum2, cNum1, cNum2) // N2 = N1 - N2

                            zNum = String(cString: Int8(cNum2), encoding: .ascii)
                            if abs(Float(Double(zNum ?? "") ?? 0.0)) < 0.0001 {
                                break // OK
                            }
                        }
                        let zAns = String(cString: Int8(cAns), encoding: .ascii)
                        AzLOG("-[√]- zAns=%@", zAns)
                        if zAns?.hasPrefix("@") ?? false {
                            throw zAns
                        }
                        // ERROR
                        maStack.push(zAns) // スタックPUSH
                    }
                } else if zTokn == "*" {
                    if 2 <= maStack.count {
                        // N2
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum2, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum2=%s", cNum2)
                        // N1
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum1=%s", cNum1)
                        //----------------------------
                        stringMultiply(cAns, cNum1, cNum2)
                        AzLOG("BCD> cAns=%s", cAns)
                        let zAns = String(cString: Int8(cAns), encoding: .ascii)
                        AzLOG("-[*]- zAns=%@", zAns)
                        if zAns?.hasPrefix("@") ?? false {
                            throw zAns
                        }
                        // ERROR
                        maStack.push(zAns) // スタックPUSH
                    }
                } else if zTokn == "/" {
                    if 2 <= maStack.count {
                        // N2
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum2, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum2=%s", cNum2)
                        // N1
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum1=%s", cNum1)
                        //----------------------------
                        stringDivision(cAns, cNum1, cNum2)
                        AzLOG("BCD> cAns=%s", cAns)
                        let zAns = String(cString: Int8(cAns), encoding: .ascii)
                        AzLOG("-[/]- zAns=%@", zAns)
                        if zAns?.hasPrefix("@") ?? false {
                            if zAns?.hasPrefix("@0") ?? false {
                                throw NSLocalizedString("@Divide by zero", comment: "")
                            }
                        }
                        maStack.push(zAns) // スタックPUSH
                    }
                } else if zTokn == "-" {
                    if 1 <= maStack.count {
                        // N2
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum2, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum2=%s", cNum2)
                        // N1
                        if 1 <= maStack.count {
                            zNum = maStack.pop() as? String // スタックからPOP
                            strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                            AzLOG("BCD> cNum1=%s", cNum1)
                        } else {
                            strcpy(cNum1, Int8("0.0\0"))
                        }
                        //----------------------------
                        stringSubtract(cAns, cNum1, cNum2)
                        AzLOG("BCD> cAns=%s", cAns)
                        let zAns = String(cString: Int8(cAns), encoding: .ascii)
                        AzLOG("-[-]- zAns=%@", zAns)
                        if zAns?.hasPrefix("@") ?? false {
                            throw zAns
                        }
                        // ERROR
                        maStack.push(zAns) // スタックPUSH
                    }
                } else if zTokn == "+" {
                    if 1 <= maStack.count {
                        // N2
                        zNum = maStack.pop() as? String // スタックからPOP
                        strcpy(cNum2, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                        AzLOG("BCD> cNum2=%s", cNum2)
                        // N1
                        if 1 <= maStack.count {
                            zNum = maStack.pop() as? String // スタックからPOP
                            strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                            AzLOG("BCD> cNum1=%s", cNum1)
                        } else {
                            strcpy(cNum1, Int8("0.0\0"))
                        }
                        //----------------------------
                        stringAddition(cAns, cNum1, cNum2)
                        AzLOG("BCD> stringAddition() cAns=%s", cAns)
                        let zAns = String(cString: Int8(cAns), encoding: .ascii)
                        AzLOG("-[+]- zAns=%@", zAns)
                        if zAns?.hasPrefix("@") ?? false {
                            throw zAns
                        }
                        // ERROR
                        maStack.push(zAns) // スタックPUSH
                    }
                } else {
                    // 数値
                    maStack.push(zTokn) // 数値をスタックPUSH
                }
            }

            // スタックに残った最後が答え
            if maStack.count == 1 {
                zNum = maStack.pop() as? String // スタックからPOP
                AzLOG("Ans: zNum = %@", zNum)
                // PRECISION Overflow check
                var iIntLen: Int
                let rg = (zNum as NSString?)?.range(of: NUM_DECI)
                if rg?.location != NSNotFound {
                    iIntLen = rg?.location ?? 0
                } else {
                    iIntLen = zNum?.count ?? 0
                }
                if zNum?.hasPrefix(OP_SUB) ?? false {
                    iIntLen -= 1
                }
                if PRECISION < iIntLen {
                    //@throw @"@Overflow";  // 先頭を@にすると stringFormatter() で変換されずに@以降が返されてドラムに表示される
                    throw NSLocalizedString("@Overflow", comment: "")
                }
                // 丸め処理
                strcpy(cNum1, Int8(zNum?.cString(using: String.Encoding.ascii.rawValue) ?? 0))
                stringRounding(cAns, cNum1, PRECISION, MiSegDecimal, MiSegRound)
                AzLOG("BCD> stringRounding() cAns=%s", cAns)
                zAnswer = String(cString: Int8(cAns), encoding: .ascii) ?? ""
                //[zAnswer retain]; // retainCount=1
            } else {
                throw "@ERROR1"
                //@"[maStack count] != 1";
            }
        }, catch: { exception in
            if let exception = exception as? NSException {
                print("Calc:Exception: \(exception.name()): \(exception.reason())\n")
                GA_TRACK_EVENT_ERROR(exception.description(), 0)
                zAnswer = "" // nilにすると、戻り値を使った setString:で落ちる
            }
            if let msg = exception as? String {
                print("Calc:@throw: \(msg)\n")
                GA_TRACK_EVENT_ERROR(msg, 0)
                zAnswer = msg //@"";  // nilにすると、戻り値を使った setString:で落ちる
            }
        }, finallyBlock: {
            //[autoPool release];
            //-------------------------------------------------localPool END
            maRpn = nil
            maStack = nil
        })
        //if ([zAnswer retainCount]==1) 
        //	[zAnswer autorelease];  // @""ならば不要だから
        return zAnswer
    }
}

// MARK: - Stack method

//[0.3]-----------------------------------------------------NSMutableArray Stack Method
extension [AnyHashable] {
    func push(_ obj: Any?) {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            if let obj = obj as? AnyHashable {
                append(obj)
            }
        }
    }

    func pop() -> Any? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {
            //id lastObject = [[[self lastObject] retain] autorelease];
            let lastObject = last
            if lastObject != nil {
                //[[lastObject retain] autorelease];
                removeLast()
            }
            return lastObject // nil if [self count] == 0
        }
    }
}