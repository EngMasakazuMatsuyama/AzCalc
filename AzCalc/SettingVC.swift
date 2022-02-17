//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  SettingVC.swift
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// ---------------------------------------------------------------------------------
// "SettingVC.xib" は、"MainWindow.xib" にて読み込まれる！！！
// ---------------------------------------------------------------------------------

//
//  SetringVC.m
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {
    @IBOutlet var ibSegDrums: UISegmentedControl!
    @IBOutlet var ibSegCalcMethod: UISegmentedControl!
    @IBOutlet var ibSegDecimal: UISegmentedControl!
    @IBOutlet var ibSegRound: UISegmentedControl!
    @IBOutlet var ibSegReverseDrum: UISegmentedControl!
    // Option-iPad
    @IBOutlet var ibLbVolume: UILabel!
    @IBOutlet var ibSliderVolume: UISlider!
    @IBOutlet var ibLbTax: UILabel!
    @IBOutlet var ibSliderTax: UISlider!
    @IBOutlet var ibSegGroupingSeparator: UISegmentedControl!
    @IBOutlet var ibSegGroupingType: UISegmentedControl!
    @IBOutlet var ibSegDecimalSeparator: UISegmentedControl!
    @IBOutlet var ibSegButtonDesign: UISegmentedControl!

    private var appDelegate: AzCalcAppDelegate? // initにて = (AzCalcAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Option-iPad
    private var MfTaxRate: Float = 0.0
    private var MfTaxRateModify: Float = 0.0

    // MARK: - View dealloc



    // MARK: - View lifecicle

    override func loadView() {
        super.loadView()
        appDelegate = UIApplication.shared.delegate as? AzCalcAppDelegate
    }

    // viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA_TRACK_PAGE("SettingVC")

        let defaults = UserDefaults.standard

        ibSegDrums.selectedSegmentIndex = defaults.integer(forKey: GUD_Drums)
        ibSegCalcMethod.selectedSegmentIndex = defaults.integer(forKey: GUD_CalcMethod)
        ibSegDecimal.selectedSegmentIndex = defaults.integer(forKey: GUD_Decimal)
        ibSegRound.selectedSegmentIndex = defaults.integer(forKey: GUD_Round)
        ibSegReverseDrum.selectedSegmentIndex = defaults.integer(forKey: GUD_ReverseDrum)

        // Options
        let iVol = defaults.integer(forKey: GUD_AudioVolume)
        ibLbVolume.text = "\(iVol)"

        MfTaxRate = defaults.float(forKey: GUD_TaxRate)
        MfTaxRateModify = MfTaxRate
        ibLbTax.text = String(format: "%.1f%%", MfTaxRate)

        ibSegGroupingSeparator.selectedSegmentIndex = defaults.integer(forKey: GUD_GroupingSeparator)
        ibSegGroupingType.selectedSegmentIndex = defaults.integer(forKey: GUD_GroupingType)
        ibSegDecimalSeparator.selectedSegmentIndex = defaults.integer(forKey: GUD_DecimalSeparator)
        ibSegButtonDesign.selectedSegmentIndex = defaults.integer(forKey: GUD_ButtonDesign)
    }

    // viewDidAppear はView表示直後に呼ばれる

    // MARK:  View 回転

    // 回転サポート
    override var shouldAutorotate: Bool {
        if interfaceOrientation.isPortrait {
            return true // タテは常にOK
        } else if 700 < view.frame.size.height {
            return true // iPad
        }
        return false
    }

    // MARK: - IBAction

    @IBAction func ibSegDrums(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_Drums)
    }

    @IBAction func ibSegCalcMethod(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_CalcMethod)
    }

    @IBAction func ibSegDecimal(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_Decimal)
    }

    @IBAction func ibSegRound(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_Round)
    }

    @IBAction func ibSegReverseDrum(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_ReverseDrum)
    }

    // Option-iPad
    // 同じ処理が、OptionVC.m (iPhone用) にも存在する
    @IBAction func ibSliderVolumeChange(_ slider: UISlider?) {
        var iVol = Int(ibSliderVolume.value)
        if iVol < 0 {
            iVol = 0
        } else if 10 < iVol {
            iVol = 10
        }
        ibSliderVolume.value = Float(iVol)
        ibLbVolume.text = "\(iVol)"
    }

    @IBAction func ibSliderVolumeTouchUp(_ slider: UISlider?) {
        UserDefaults.standard.set(Int(ibSliderVolume.value), forKey: GUD_AudioVolume)
    }

    @IBAction func ibSliderTaxChange(_ slider: UISlider?) {
        //float f = MfTaxRate + floorf(ibSliderTax.value * 10.0) / 10.0; // 小数1位までにする
        var f = floorf((MfTaxRate + ibSliderTax.value) * 10.0) / 10.0 // 小数1位までにする
        if f < 0.1 {
            f = 0.00
        } else if 99.8 < f {
            f = 99.90
        }

        MfTaxRateModify = f
        ibLbTax.text = String(format: "%.2f%%", MfTaxRateModify)
    }

    @IBAction func ibSliderTaxTouchUp(_ slider: UISlider?) {
        MfTaxRate = MfTaxRateModify
        UserDefaults.standard.set(MfTaxRate, forKey: GUD_TaxRate)
        ibLbTax.text = String(format: "%.2f%%", MfTaxRate)
        ibSliderTax.value = 0 // Center
    }

    @IBAction func ibSegGroupingSeparator(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_GroupingSeparator)
    }

    @IBAction func ibSegGroupingType(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_GroupingType)
    }

    @IBAction func ibSegDecimalSeparator(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_DecimalSeparator)
    }

    @IBAction func ibSegButtonDesign(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_ButtonDesign)
        // (0) Roll
        // (1) Round rect
        // (2) Rect
    }

    @IBAction func ibBuOK(_ button: UIButton?) {
        let userDefaults = UserDefaults.standard
        userDefaults.synchronize() // plistへ書き出す
        appDelegate?.bChangeKeyboard = false

        dismissModalViewController(animated: true)
    }

    @IBAction func ibBuKeyboardEdit(_ button: UIButton?) {
        let userDefaults = UserDefaults.standard
        userDefaults.synchronize() // plistへ書き出す
        appDelegate?.bChangeKeyboard = true

        dismissModalViewController(animated: true)
    }

    @IBAction func ibBuPageFlip(_ button: UIButton?) {
        appDelegate?.ibOptionVC.modalTransitionStyle = .partialCurl // めくれ上がる
        //appDelegate.ibInformationVC.view.hidden = YES;
        //appDelegate.ibSettingVC.view.hidden = NO;
        appDelegate?.ibOptionVC.view.isHidden = false
        presentModalViewController(appDelegate?.ibOptionVC, animated: true)
    }

    @IBAction func ibBuDropbox(_ button: UIButton?) {
        appDelegate?.bChangeKeyboard = false
        //[self dismissModalViewControllerAnimated:YES];
        appDelegate?.viewController.gvDropbox(self)
    }
}

//#import "InformationVC.h"