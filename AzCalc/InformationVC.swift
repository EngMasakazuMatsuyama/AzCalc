//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  InformationVC.swift
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/18.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

import MessageUI
import UIKit

class InformationVC: UIViewController, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {
    @IBOutlet var ibLbProductName: UILabel!
    @IBOutlet var ibLbVersion: UILabel!
    @IBOutlet var ibImgIcon: UIImageView!
    @IBOutlet var ibBuPaidApp: UIButton! // 非表示にするため

    // MARK: - View dealloc



    // MARK: - View lifecicle

    /*
     // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
     - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
     {
     self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
     if (self) {
     // Custom initialization
     }
     return self;
     }
     */

    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        GA_TRACK_PAGE("InformationVC")

        //ibLbProductName.text = NSLocalizedString(@"Product Title",nil);

        let zVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        #if AzSTABLE
        if 72 <= ibImgIcon.frame.size.width {
            ibImgIcon.image = UIImage(named: "Icon72s1.png")
        } else {
            ibImgIcon.image = UIImage(named: "Icon57s1.png")
        }
        ibLbVersion.text = "Version \(zVersion ?? "")"
        //
        ibBuPaidApp.isHidden = true // 有料版 AppStore 非表示
        #else
        if 72 <= ibImgIcon.frame.size.width {
            ibImgIcon.image = UIImage(named: "Icon72free.png")
        } else {
            ibImgIcon.image = UIImage(named: "Icon57free.png")
        }
        ibLbVersion.text = "Version \(zVersion ?? "")\nFree"
        #endif
    }

    /*
     // viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
     - (void)viewWillAppear:(BOOL)animated 
     {
     [super viewWillAppear:animated];
     }
     */


    // MARK:  View 回転

    // Override to allow orientations other than the default portrait orientation.
    override var shouldAutorotate: Bool {
        if interfaceOrientation.isPortrait {
            return true // タテは常にOK
        } else if 72 <= ibImgIcon.frame.size.width {
            return true // iPad
        }
        return false
        //NG//if (700 < self.view.frame.size.height) return YES; // 小窓タイプなので、これでは判断できない
    }

    // MARK: - IBAction

    @IBAction func ibBu(toSupport button: UIButton?) {
        let alert = UIAlertView(title: NSLocalizedString("ToSupportSite", comment: ""), message: NSLocalizedString("ToSupportSite msg", comment: ""), delegate: self /* clickedButtonAtIndexが呼び出される */, cancelButtonTitle: "＜Back", otherButtonTitles: "Go safari＞")
        alert.tag = ALERT_ToSupportSite
        alert.show()
        //[alert autorelease];
    }

    @IBAction func ibBuPaidApp(_ button: UIButton?) {
        //alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
        let alert = UIAlertView(title: NSLocalizedString("AppStore Paid", comment: ""), message: NSLocalizedString("AppStore Paid msg", comment: ""), delegate: self /* clickedButtonAtIndexが呼び出される */, cancelButtonTitle: "＜Back", otherButtonTitles: "Go safari＞")
        alert.tag = ALERT_APP_PAID
        alert.show()
        //[alert autorelease];
    }

    @IBAction func ibBuContact(_ button: UIButton?) {
        //メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
        if !MFMailComposeViewController.canSendMail() {
            //[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
            //alertBox( NSLocalizedString(@"Contact NoMail",nil), NSLocalizedString(@"Contact NoMail msg",nil), @"OK" );
            let alert = UIAlertView(title: NSLocalizedString("Contact NoMail", comment: ""), message: NSLocalizedString("Contact NoMail msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
            alert.show()
            return
        }

        //alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
        let alert = UIAlertView(title: NSLocalizedString("Contact mail", comment: ""), message: NSLocalizedString("Contact mail msg", comment: ""), delegate: self /* clickedButtonAtIndexが呼び出される */, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.tag = ALERT_CONTACT
        alert.show()
        //[alert autorelease];
    }

    @IBAction func ibBuOK(_ button: UIButton?) {
        dismissModalViewController(animated: true)
    }

    // MARK: - delegate

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 1 {
            return // Cancel
        }
        // OK
        switch alertView.tag {
        case ALERT_ToSupportSite:
            //NSURL *url = [NSURL URLWithString:@"http://azukisoft.seesaa.net/"];
            let url = URL(string: "http://calcroll.tumblr.com/")
            if let url = url {
                UIApplication.shared.openURL(url)
            }
        case ALERT_APP_PAID:
            // Paid App Store																															432480691
            let url = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432480691&mt=8")
            if let url = url {
                UIApplication.shared.openURL(url)
            }
        case ALERT_CONTACT:
            // Post commens
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self

            // To: 宛先
            let toRecipients = ["post@azukid.com"]
            picker.setToRecipients(toRecipients)
            //[picker setCcRecipients:nil];
            //[picker setBccRecipients:nil];

            // Subject: 件名
            var zSubj = NSLocalizedString("Product Title", comment: "")
            #if AzSTABLE
            //zSubj = [zSubj stringByAppendingString:@" Stable"];
            #else
            zSubj = zSubj + " Free"
            #endif
            picker.setSubject(zSubj)

            // Body: 本文
            let zVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
            let zBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String //（ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
            var zBody = "Product: \(zSubj)\n"
            #if AzSTABLE
            zBody = zBody + "Version: \(zVersion ?? "") (\(zBuild ?? "")) Stable\n"
            #else
            zBody = zBody + "Version: \(zVersion ?? "") (\(zBuild ?? ""))\n"
            #endif
            let device = UIDevice.current
            let deviceID = device.platformString()
            zBody = zBody + "Device: \(deviceID ?? "")   iOS: \(UIDevice.current.systemVersion)\n" // OSの現在のバージョン

            let languages = NSLocale.preferredLanguages
            if let object = NSLocale.current[NSLocale.Key.identifier] {
                zBody = zBody + "Locale: \(object) (\(languages[0]))\n\n"
            }

            zBody = zBody + NSLocalizedString("Contact message", comment: "")
            picker.setMessageBody(zBody, isHTML: false)

            presentModalViewController(picker, animated: true)
        default:
            break
        }
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        switch result {
        case .cancelled:
            //キャンセルした場合
            break
        case .saved:
            //保存した場合
            break
        case .sent:
            //送信した場合
            //alertBox( NSLocalizedString(@"Contact Sent",nil), NSLocalizedString(@"Contact Sent msg",nil), @"OK" );
            let alert = UIAlertView(title: NSLocalizedString("Contact Sent", comment: ""), message: NSLocalizedString("Contact Sent msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
            alert.show()
        case .failed:
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
            //alertBox( NSLocalizedString(@"Contact Failed",nil), NSLocalizedString(@"Contact Failed msg",nil), @"OK" );
            let alert = UIAlertView(title: NSLocalizedString("Contact Failed", comment: ""), message: NSLocalizedString("Contact Failed msg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: "OK")
            alert.show()
        default:
            break
        }
        dismissModalViewController(animated: true)
    }
}

let ALERT_ToSupportSite = 19
let ALERT_APP_PAID = 28
let ALERT_CONTACT = 37