//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  KeyButton.swift
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

import Foundation

let KeyUNIT_DELIMIT = ";" // "SI基本単位;変換式;逆変換式"

//---------------------------------------------------------Tag
//----------AzKeyMaster.plist の Tag 定義と一致させること。
let KeyTAG_STANDARD_Start = 0
let KeyTAG_DECIMAL = 16 // [.]小数点
let KeyTAG_00 = 17 // [00]
let KeyTAG_000 = 18 // [000]
let KeyTAG_SIGN = 20 // [+/-]
let KeyTAG_PERC = 30 // [%]
let KeyTAG_PERM = 31 // [‰]パーミル
let KeyTAG_ROOT = 32 // [√]
let KeyTAG_LEFT = 33 // [(]
let KeyTAG_RIGHT = 34 // [)]


let KeyTAG_ANSWER = 100 // [=]回答
let KeyTAG_PLUS = 101 // [+]
let KeyTAG_MINUS = 102 // [-]
let KeyTAG_MULTI = 103 // [×]
let KeyTAG_DIVID = 104 // [÷]
let KeyTAG_GT = 105 // [GT] Ground Total

let KeyTAG_AC = 200 // [AC] All Clear
let KeyTAG_BS = 201 // [BS] Back Clear
let KeyTAG_SC = 202 // [SC] Section Clear
let KeyTAG_AddTAX = 210 // [+Tax]
let KeyTAG_SubTAX = 211 // [-Tax]
let KeyTAG_STANDARD_End = 299

let KeyTAG_MEMORY_Start = 300
let KeyTAG_MCLEAR = 300 // [MClear]
let KeyTAG_MCOPY = 301 // [Memory]
let KeyTAG_MPASTE = 302 // [Paste] ibBuMemory
let KeyTAG_M_PLUS = 311 // [M+]
let KeyTAG_M_MINUS = 312 // [M-]
let KeyTAG_M_MULTI = 313 // [M×]
let KeyTAG_M_DIVID = 314 // [M÷]
let KeyTAG_MEMORY_End = 399

let KeyTAG_MSTORE_Start = 400
let KeyTAG_MSTORE_M1 = 401 // [M1]
let KeyTAG_MSTORE_M2 = 402
let KeyTAG_MSTORE_M3 = 403
let KeyTAG_MSTORE_M4 = 404
let KeyTAG_MSTORE_M5 = 405
let KeyTAG_MSTORE_M6 = 406
let KeyTAG_MSTORE_M7 = 407
let KeyTAG_MSTORE_M8 = 408
let KeyTAG_MSTORE_M9 = 409
let KeyTAG_MSTORE_M10 = 410
let KeyTAG_MSTORE_M11 = 411
let KeyTAG_MSTORE_M12 = 412
let KeyTAG_MSTORE_M13 = 413
let KeyTAG_MSTORE_M14 = 414
let KeyTAG_MSTORE_M15 = 415
let KeyTAG_MSTORE_M16 = 416
let KeyTAG_MSTORE_M17 = 417
let KeyTAG_MSTORE_M18 = 418
let KeyTAG_MSTORE_M19 = 419
let KeyTAG_MSTORE_M20 = 420
let KeyTAG_MSTROE_End = 499

let KeyTAG_FUNC_Start = 500
//#define KeyTAG_FUNC_iCloud			501
//#define KeyTAG_FUNC_Dropbox		502	＜＜＜ SettingVCにボタン設置することにした。
//#define KeyTAG_FUNC_Evernote		503
let KeyTAG_FUNC_End = 599

let KeyTAG_UNIT_Start = 1000 //-----------------SI基本単位換算
let KeyTAG_UNIT_kg = 1000 // [kg]			1kg
let KeyTAG_UNIT_g = 1001 // [g]				0.001kg = 1000mg
let KeyTAG_UNIT_mg = 1002 // [mg]			0.000001kg = 0.001g
let KeyTAG_UNIT_t = 1003 // [t]		トン		1000kg
let KeyTAG_UNIT_kt = 1010 // [kt]	カラット	0.0002kg
let KeyTAG_UNIT_ozav = 1011 // [oz] オンス常用	0.028349523125kg
let KeyTAG_UNIT_lbav = 1012 // [lb] ポンド常用	0.45359237kg
let KeyTAG_UNIT_KANN = 1013 // [貫]				3.75kg
let KeyTAG_UNIT_MONN = 1014 // [匁]				0.00375kg

let KeyTAG_UNIT_m = 1100 // [m]				1m
let KeyTAG_UNIT_cm = 1101 // [cm]			0.01m
let KeyTAG_UNIT_mm = 1102 // [mm]			0.001m
let KeyTAG_UNIT_km = 1103 // [km]			1000m
let KeyTAG_UNIT_Adm = 1110 // [Adm]	海里		1852m
let KeyTAG_UNIT_yard = 1111 // [yd]	ヤード	0.9144m
let KeyTAG_UNIT_foot = 1112 // [ft]	フィート	0.3048m
let KeyTAG_UNIT_inch = 1113 // [in]	インチ	0.254m
let KeyTAG_UNIT_mile = 1114 // [mi]	マイル	1609.344m
let KeyTAG_UNIT_SHAKU = 1115 // [尺]		曲尺		0.303m
let KeyTAG_UNIT_SUNN = 1116 // [寸]		曲寸		0.0303m
let KeyTAG_UNIT_RI = 1117 // [里]		里		3927m

let KeyTAG_UNIT_m2 = 1200 // [㎡]				1㎡
let KeyTAG_UNIT_cm2 = 1201 // [c㎡]			0.0001㎡
let KeyTAG_UNIT_are = 1202 // [a]		アール	100㎡
let KeyTAG_UNIT_ha = 1203 // [ha]	㌶		10000㎡
let KeyTAG_UNIT_km2 = 1204 // [k㎡]			1000000㎡
let KeyTAG_UNIT_mm2 = 1205 // [m㎡]			0.000001㎡
let KeyTAG_UNIT_acre = 1210 // [ac]	エーカー	4046.8564224㎡
let KeyTAG_UNIT_sqft = 1211 // [sqft]	平方ft	0.09290304㎡
let KeyTAG_UNIT_sqin = 1212 // [sqin]	平方in	0.00064516㎡
let KeyTAG_UNIT_TUBO = 1213 // [坪]				3.305785㎡
let KeyTAG_UNIT_UNE = 1214 // [畝]				99.17355㎡
let KeyTAG_UNIT_TAN = 1215 // [反]				991.7355㎡

let KeyTAG_UNIT_m3 = 1300 // [㎥]				1㎥
let KeyTAG_UNIT_cm3 = 1301 // [c㎡]			0.000001㎡
let KeyTAG_UNIT_L = 1302 // [L]		リットル	0.001㎡
let KeyTAG_UNIT_dL = 1303 // [dL]	デシL	0.0001㎡
let KeyTAG_UNIT_mL = 1304 // [mL]	ミリL	0.00001㎡
let KeyTAG_UNIT_cc = 1305 // [cc]			0.00001㎡
let KeyTAG_UNIT_cuin = 1310 // [cuin]	立方in	0.0016387064㎡
let KeyTAG_UNIT_cuft = 1311 // [cuft]	立方ft	0.028316846592㎡
let KeyTAG_UNIT_galus = 1312 // [galus]	ガロン	0.003785411784㎡
let KeyTAG_UNIT_bbl = 1313 // [bbl] バレル石油	1.58987294928㎡
let KeyTAG_UNIT_GOU = 1314 // [合]				0.00018039㎡
let KeyTAG_UNIT_MASU = 1315 // [升]				0.0018039㎡
let KeyTAG_UNIT_TOU = 1316 // [斗]				0.018039㎡

let KeyTAG_UNIT_rad = 1400 // [rad]			1rad
let KeyTAG_UNIT_rDO = 1401 // [°]		度		PI/180rad
let KeyTAG_UNIT_rMI = 1402 // [']		分		PI/10800rad = PI/180/60rad
let KeyTAG_UNIT_rSE = 1403 // ["]		秒		PI/648000rad = PI/180/60/60rad

let KeyTAG_UNIT_K = 1500 // [K]		ケルビン	1K
let KeyTAG_UNIT_C = 1501 // [°C]	摂氏		(#+273.15)K
let KeyTAG_UNIT_F = 1502 // [°F]	華氏		((#+459.67)/1.8)K

let KeyTAG_UNIT_s = 1600 // [s]		秒		1s
let KeyTAG_UNIT_ms = 1601 // [ms]	ミリ秒	0.001s
let KeyTAG_UNIT_min = 1602 // [min]	分		60s
let KeyTAG_UNIT_h = 1603 // [h]		時		3600s
let KeyTAG_UNIT_d = 1604 // [d]		日		86400s
let KeyTAG_UNIT_wk = 1605 // [wk]	週		604800s

let KeyTAG_UNIT_End = 2999


//----------------------------------------------------Alpha
let KeyALPHA_DEFAULT_ON = 0.8 // 標準ボタン
let KeyALPHA_DEFAULT_OFF = 0.2 // 無機能ボタン
let KeyALPHA_MSTORE_ON = 0.8 // メモリ値あり
let KeyALPHA_MSTORE_OFF = 0.5 // メモリ値なし


class KeyButton: UIButton {






 // YES=キー配置変更あり ⇒ 保存が必要

    var rzUnit: String?
    var iPage = 0
    var iCol = 0
    var iRow = 0
    var iColorNo = 0
    var fFontSize: Float = 0.0
    var bDirty = false

    // MARK: - <NSCoding> シリアライズ

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        iPage = (decoder.decodeObject(forKey: "iPage") as? NSNumber)?.intValue ?? 0
        iCol = (decoder.decodeObject(forKey: "iCol") as? NSNumber)?.intValue ?? 0
        iRow = (decoder.decodeObject(forKey: "iRow") as? NSNumber)?.intValue ?? 0
        iColorNo = (decoder.decodeObject(forKey: "iColorNo") as? NSNumber)?.intValue ?? 0
        fFontSize = (decoder.decodeObject(forKey: "fFontSize") as? NSNumber)?.floatValue ?? 0.0
        bDirty = (decoder.decodeObject(forKey: "bDirty") as? NSNumber)?.boolValue ?? false
        rzUnit = decoder.decodeObject(forKey: "RzUnit") as? String
    }

    override func encode(with encoder: NSCoder) {
        super.encode(with: encoder)
        encoder.encode(NSNumber(value: iPage), forKey: "iPage")
        encoder.encode(NSNumber(value: iCol), forKey: "iCol")
        encoder.encode(NSNumber(value: iRow), forKey: "iRow")
        encoder.encode(NSNumber(value: iColorNo), forKey: "iColorNo")
        encoder.encode(NSNumber(value: fFontSize), forKey: "fFontSize")
        encoder.encode(NSNumber(value: bDirty), forKey: "bDirty")
        encoder.encode(rzUnit, forKey: "RzUnit")
    }

    // MARK: - UIButton lifecicle


    override init(frame: CGRect) {
        super.init(frame: frame)
            // OK
            rzUnit = nil
            iPage = 0
            iCol = 0
            iRow = 0
            iColorNo = 0
            fFontSize = 10
            bDirty = false
            //bu.contentMode = UIViewContentModeScaleToFill;
            //bu.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);  変化なしだった。
            //self.imageView.contentMode = UIViewContentModeScaleToFill;
            //self.imageView.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);
    }
}