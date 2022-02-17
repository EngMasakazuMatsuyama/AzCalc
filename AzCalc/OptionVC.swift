//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  OptionVC.swift
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/19.
//  Copyright 2010 AzukiSoft. All rights reserved.
//
// ---------------------------------------------------------------------------------
// "OptionVC.xib" は、"MainWindow.xib" にて読み込まれる！！！
// ---------------------------------------------------------------------------------

//
//  OptionVC.swift
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/19.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

import UIKit

class OptionVC: UIViewController {
    @IBOutlet var ibLbVolume: UILabel!
    @IBOutlet var ibLbTax: UILabel!
    @IBOutlet var ibSliderVolume: UISlider!
    @IBOutlet var ibSliderTax: UISlider!
    @IBOutlet var ibSegGroupingSeparator: UISegmentedControl!
    @IBOutlet var ibSegGroupingType: UISegmentedControl!
    @IBOutlet var ibSegDecimalSeparator: UISegmentedControl!
    @IBOutlet var ibSegButtonDesign: UISegmentedControl!

    private var MfTaxRate: Float = 0.0
    private var MfTaxRateModify: Float = 0.0

    /*
     // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
        if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
            // Custom initialization
        }
        return self;
    }
    */

    /*
    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    - (void)viewDidLoad {
        [super viewDidLoad];
    }
    */

    /*
    // Override to allow orientations other than the default portrait orientation.
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        // Return YES for supported orientations
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    */

    // MARK: - View dealloc



    // MARK: - View lifecicle

    // viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA_TRACK_PAGE("OptionVC")

        let defaults = UserDefaults.standard

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


    // MARK: - IBAction

    // 同じ処理が、SettingVC.m (iPad用) にも存在する
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
        var f = floorf((MfTaxRate + ibSliderTax.value) * 10.0) / 10.0 //[1.0.5] 小数1位までにする
        if f < 0.1 {
            f = 0.0
        } else if 99.8 < f {
            f = 99.9
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
        // (0) 9,9
        // (1) 9'9
        // (2) 9 9
        // (3) 9.9
    }

    @IBAction func ibSegGroupingType(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_GroupingType)
        // (0)   123 123  International
        // (1) 12 12 123  India
        // (2) 1234 1234  Kanji zone
    }

    @IBAction func ibSegDecimalSeparator(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_DecimalSeparator)
        // (0) 0.0
        // (1) 0·0
        // (2) 0,0
    }

    @IBAction func ibSegButtonDesign(_ segment: UISegmentedControl?) {
        UserDefaults.standard.set(segment?.selectedSegmentIndex ?? 0, forKey: GUD_ButtonDesign)
        // (0) Roll
        // (1) Round rect
        // (2) Rect
    }

    @IBAction func ibBuOK(_ button: UIButton?) {
        dismissModalViewController(animated: true)
    }
}