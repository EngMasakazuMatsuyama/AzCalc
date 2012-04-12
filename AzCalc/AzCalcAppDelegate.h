//
//  AzCalcAppDelegate.h
//  AzCalc
//
//  Created by 松山 和正 on 10/07/08.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AzCalcViewController;
@class SettingVC;
//@class InformationVC;
@class OptionVC;

@interface AzCalcAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow		*window;
    AzCalcViewController *viewController;
	SettingVC		*ibSettingVC;
	//InformationVC	*ibInformationVC;
	OptionVC		*ibOptionVC;
	
	// Drumオブジェクト共有変数
	//double			dMemory;		// [103:MRC] [104:M-] [105:M+]

	BOOL			bChangeKeyboard;	// YES=キー変更モード
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet AzCalcViewController *viewController;
@property (nonatomic) IBOutlet SettingVC *ibSettingVC;
//@property (nonatomic) IBOutlet InformationVC *ibInformationVC;
@property (nonatomic) IBOutlet OptionVC *ibOptionVC;

//@property (nonatomic, assign) double	dMemory;
@property (nonatomic, assign) BOOL		bChangeKeyboard;


@end

