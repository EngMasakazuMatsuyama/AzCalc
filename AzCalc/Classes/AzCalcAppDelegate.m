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
#import "InformationVC.h"
#import "OptionVC.h"

@implementation AzCalcAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize ibSettingVC;
@synthesize ibInformationVC;
@synthesize ibOptionVC;
@synthesize dMemory;


#pragma mark -
#pragma mark Application lifecycle

- (void)dealloc 
{
	[ibOptionVC release];
	[ibInformationVC release];
	[ibSettingVC release];
    [viewController release];
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // Override point for customization after application launch.

	//-------------------------------------------------Option Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *azOptDef = [[NSDictionary alloc] initWithObjectsAndKeys: // 直後にreleaseしている
							  @"1",		GUD_Drums,		// "0"⇒(1) "1"⇒(2)
							  @"0",		GUD_CalcMethod,
							  @"3",		GUD_Decimal,
							  @"3",		GUD_Round,
							  @"1",		GUD_ReverseDrum,
							  NSLocalizedString(@"GUD_GroupingSeparator",nil),	GUD_GroupingSeparator,
							  @"3",		GUD_GroupingSize,
							  NSLocalizedString(@"GUD_DecimalSeparator",nil),	GUD_DecimalSeparator,
							  nil];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:azOptDef];	// 未定義のKeyのみ更新される
	[userDefaults synchronize]; // plistへ書き出す
	[azOptDef release];
	
	dMemory = 0.0;
	
	// Add the view controller's view to the window and display.
	[window addSubview:ibOptionVC.view];
	[window addSubview:ibInformationVC.view];
	[window addSubview:ibSettingVC.view];
	[window addSubview:viewController.view];
	// TopView
	//	[window bringSubviewToFront:viewController.view];
	// 
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults synchronize]; // plistへ書き出す
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */

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


@end
