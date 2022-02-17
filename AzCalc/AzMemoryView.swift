//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  AzMemoryView.swift
//  AzCalc-0.2
//
//  Created by 松山 和正 on 10/08/11.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

import Foundation

class AzMemoryView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private var picView: UIPickerView?
    private var maMemorys: [AnyHashable]? // in NSString

    func memoryCopy(_ zNum: String?) {
    }

    func memoryPaste() -> String? {
    }

    func memoryClear(_ zNum: String?) {
    }

    //@synthesize iPage, iCol, iRow, iColorNo, fFontSize, bDirty;


    deinit {
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
            // OK
            AzLOG("AzMemoryView: init OK")
            //
            picView = UIPickerView(frame: frame)
            if let picView = picView {
                addSubview(picView)
            }
            picView?.delegate = self
            picView?.dataSource = self
            picView?.showsSelectionIndicator = true
            picView?.isHidden = false
            picView?.backgroundColor = UIColor.clear
            //
    }

    //-----------------------------------------------------------Picker
    func numberOfComponents(in pickerView: UIPickerView?) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing reView: UIView?
    ) -> UIView {
        var vi = reView // Viewが再利用されるため
        var lb: UILabel? = nil
        let sz = pickerView.rowSize(forComponent: component)

        if vi == nil {
            vi = UIView(frame: CGRect(x: 0, y: 0, width: sz.width, height: 30))
            // addSubview
            lb = UILabel(frame: CGRect(x: 5, y: 0, width: sz.width - 10, height: 30))
            lb?.tag = 992
            lb?.backgroundColor = UIColor.clear
            lb?.adjustsFontSizeToFitWidth = true
            lb?.minimumFontSize = 6
            lb?.baselineAdjustment = .alignBaselines
            if let lb = lb {
                vi?.addSubview(lb)
            }
        }
        if lb == nil {
            lb = vi?.viewWithTag(992) as? UILabel
        }
        lb?.textAlignment = UITextAlignmentLeft
        lb?.font = UIFont.systemFont(ofSize: 20)
        lb?.text = NSLocalizedString("Drum Calculator", comment: "")

        return vi!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //[self.nextResponder touchesBegan:touches withEvent:event]; // ibPickerへ受け流す
        AzLOG("AzMemoryView: touchesBegan")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}