//
//  AzCalcAppDelegate.m
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Global.h"
#import "AzCalcAppDelegate.h"
#import "AzCalcViewController.h"
#import "SettingVC.h"
//#import "InformationVC.h"
#import "OptionVC.h"
//#import "DropboxVC.h"


@implementation AzCalcAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize ibSettingVC;
@synthesize ibOptionVC;
@synthesize bChangeKeyboard;


- (void)dealloc
{
	//[[GANTracker sharedTracker] stopTracker];
}

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // Override point for customization after application launch.

	GA_INIT_TRACKER(@"UA-30305032-2", 10, nil);	//-2:CalcRoll
	GA_TRACK_EVENT(@"Device", @"model", [[UIDevice currentDevice] model], 0);
	GA_TRACK_EVENT(@"Device", @"systemVersion", [[UIDevice currentDevice] systemVersion], 0);
	
	//-------------------------------------------------Option Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *azOptDef = [[NSDictionary alloc] initWithObjectsAndKeys: // 直後にreleaseしている
							  @"-1",	GUD_Drums,		// "-1"⇒ 初期値：iPhone="1" iPad="2"
							  @"0",		GUD_CalcMethod,
							  @"3",		GUD_Decimal,
							  @"3",		GUD_Round,
							  @"1",		GUD_ReverseDrum,
							  NSLocalizedString(@"GUD_GroupingSeparator",nil),	GUD_GroupingSeparator,
							  NSLocalizedString(@"GUD_GroupingType",nil),		GUD_GroupingType,
							  NSLocalizedString(@"GUD_DecimalSeparator",nil),	GUD_DecimalSeparator,
							  NSLocalizedString(@"GUD_TaxRate",nil),			GUD_TaxRate,
							  @"0",		GUD_AudioVolume,	// 0〜10
							  @"0",		GUD_ButtonDesign,	//[1.0.10] 0=Drum, 1=RoundRect, 2=Rect
							  nil];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:azOptDef];	// 未定義のKeyのみ更新される
	[userDefaults synchronize]; // plistへ書き出す
	
	//dMemory = 0.0;
	bChangeKeyboard = NO;
	
	// Add the view controller's view to the window and display.
	//iOS6-NG//[window addSubview:viewController.view];
	[window setRootViewController:viewController];  //iOS6対応
    [window makeKeyAndVisible];
	
/*** AZDropboxへ
	//[1.1.0]Dropbox
	DBSession* dbSession = [[DBSession alloc]
							 initWithAppKey:@"62f2rrofi788410"
							 appSecret:@"s07scm6ifi1o035"
							 root:kDBRootAppFolder];
	[DBSession setSharedSession:dbSession];*/
    
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{	// CalcRoll free と Stable が共存している場合、free から戻ったとき Stableが呼ばれる。
	if ([url isFileURL]) {	// .calcroll ファイルをタッチしたとき、
		NSLog(@"File loaded into [url path]=%@", [url path]);
		if ([[[url pathExtension] lowercaseString] isEqualToString:CALCROLL_EXT]) {	// ファイル・タッチ対応
			// mKmPages リセット
			if ([viewController GzCalcRollLoad:[url path]]==nil) { // .CalcRoll - Plist file
				return YES;
			}
		} else {
			UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertExtension", nil)
														   message:NSLocalizedString(@"AlertExtensionMsg", nil)
														  delegate:nil
												 cancelButtonTitle:nil
												 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
			[alv	show];
		}
	}
//    else if ([[DBSession sharedSession] handleOpenURL:url]) { //OAuth結果：urlに認証キーが含まれる
//        return YES;
//    }
    // Add whatever other url handling code your app requires here
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドになったら呼ばれる
#ifdef GD_Ad_ENABLED
	[viewController adShow:NO];
#endif
	[self applicationWillTerminate:application]; //iOS3以前の終了処理
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドから復帰する直前に呼ばれる
#ifdef GD_Ad_ENABLED
	[viewController adShow:YES];
#endif
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブになったら呼ばれる。起動時にもviewDidLoadの後にコールされる。
	// この時点で viewController.view は表示されている。
	[viewController GvMemoryLoad]; // メモリボタン関係を復帰させる
}


- (void)applicationWillTerminate:(UIApplication *)application 
{	// バックグラウンド実行中にアプリが終了された場合に呼ばれる。
	// ただしアプリがサスペンド状態の場合アプリを終了してもこのメソッドは呼ばれない。
	
	// iOS3互換のためにはここが必要。　iOS4以降、applicationDidEnterBackground から呼び出される。
	[viewController GvMemorySave]; // メモリボタン関係を保存する
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize]; // plistへ書き出す
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
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


@end
