//  Converted to Swift 5.5 by Swiftify v5.5.24623 - https://swiftify.com/
//
//  AzCalcAppDelegate.swift
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

import UIKit

@UIApplicationMain
class AzCalcAppDelegate: NSObject, UIApplicationDelegate {



    //InformationVC	*ibInformationVC;

    // Drumオブジェクト共有変数
    //double			dMemory;		// [103:MRC] [104:M-] [105:M+]

 // YES=キー変更モード

    @IBOutlet var window: UIWindow?
    @IBOutlet var viewController: AzCalcViewController!
    @IBOutlet var ibSettingVC: SettingVC!
    //@property (nonatomic) IBOutlet InformationVC *ibInformationVC;
    @IBOutlet var ibOptionVC: OptionVC!
    //@property (nonatomic, assign) double	dMemory;
    var bChangeKeyboard = false

    deinit {
        GANTracker.shared().stopTracker()
    }

    // MARK: - Application lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.

        GA_INIT_TRACKER("UA-30305032-2", 10, nil) //-2:CalcRoll
        GA_TRACK_EVENT("Device", "model", UIDevice.current.model, 0)
        GA_TRACK_EVENT("Device", "systemVersion", UIDevice.current.systemVersion, 0)

        //-------------------------------------------------Option Setting Defult
        // User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
        // registerDefaultsメソッドを使い，初期値を指定します。
        // [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        // ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
        // このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
        let azOptDef = [
            GUD_Drums : "-1",
            GUD_CalcMethod : "0",
            GUD_Decimal : "3",
            GUD_Round : "3",
            GUD_ReverseDrum : "1",
            GUD_GroupingSeparator : NSLocalizedString("GUD_GroupingSeparator", comment: ""),
            GUD_GroupingType : NSLocalizedString("GUD_GroupingType", comment: ""),
            GUD_DecimalSeparator : NSLocalizedString("GUD_DecimalSeparator", comment: ""),
            GUD_TaxRate : NSLocalizedString("GUD_TaxRate", comment: ""),
            GUD_AudioVolume : "0",
            GUD_ButtonDesign : "0"
        ]

        let userDefaults = UserDefaults.standard
        if let azOptDef = azOptDef as? [String : Any] {
            userDefaults.register(defaults: azOptDef)
        } // 未定義のKeyのみ更新される
        userDefaults.synchronize() // plistへ書き出す

        //dMemory = 0.0;
        bChangeKeyboard = false

        // Add the view controller's view to the window and display.
        window?.addSubview(viewController.view)
        window?.makeKeyAndVisible()

        /// AZDropboxへ
        /// //[1.1.0]Dropbox
        /// DBSession* dbSession = [[DBSession alloc]
        /// initWithAppKey:@"62f2rrofi788410"
        /// appSecret:@"s07scm6ifi1o035"
        /// root:kDBRootAppFolder];
        /// [DBSession setSharedSession:dbSession];

        return true
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        // CalcRoll free と Stable が共存している場合、free から戻ったとき Stableが呼ばれる。
        if url.isFileURL {
            // .calcroll ファイルをタッチしたとき、
            print("File loaded into [url path]=\(url.path)")
            if url.pathExtension.lowercased() == CALCROLL_EXT {
                // ファイル・タッチ対応
                // mKmPages リセット
                if viewController.gzCalcRollLoad(url.path) == nil {
                    // .CalcRoll - Plist file
                    return true
                }
            } else {
                let alv = UIAlertView(title: NSLocalizedString("AlertExtension", comment: ""), message: NSLocalizedString("AlertExtensionMsg", comment: ""), delegate: nil, cancelButtonTitle: "", otherButtonTitles: NSLocalizedString("Roger", comment: ""))
                alv.show()
            }
        } else if DBSession.shared().handleOpen(url) {
            //OAuth結果：urlに認証キーが含まれる
            return true
        }
        // Add whatever other url handling code your app requires here
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        //iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //iOS4: アプリケーションがバックグラウンドになったら呼ばれる
        #if GD_Ad_ENABLED
        viewController.adShow(false)
        #endif
        applicationWillTerminate(application) //iOS3以前の終了処理
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //iOS4: アプリケーションがバックグラウンドから復帰する直前に呼ばれる
        #if GD_Ad_ENABLED
        viewController.adShow(true)
        #endif
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //iOS4: アプリケーションがアクティブになったら呼ばれる。起動時にもviewDidLoadの後にコールされる。
        // この時点で viewController.view は表示されている。
        viewController.gvMemoryLoad() // メモリボタン関係を復帰させる
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // バックグラウンド実行中にアプリが終了された場合に呼ばれる。
        // ただしアプリがサスペンド状態の場合アプリを終了してもこのメソッドは呼ばれない。

        // iOS3互換のためにはここが必要。　iOS4以降、applicationDidEnterBackground から呼び出される。
        viewController.gvMemorySave() // メモリボタン関係を保存する

        let userDefaults = UserDefaults.standard
        userDefaults.synchronize() // plistへ書き出す
    }

    // MARK: -
    // MARK: Memory management

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        /*
             Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
             */
    }
    /*
    - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
    	NSLog(@"touchesBegan: touches=%@", touches);
    }

    - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
    {
    	NSLog(@"touchesMoved: touches=%@", touches);
    }

    - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
    {
    	NSLog(@"touchesEnded: touches=%@", touches);
    }
    */
}

//#import "InformationVC.h"
//#import "DropboxVC.h"