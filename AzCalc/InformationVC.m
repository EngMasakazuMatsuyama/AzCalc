//
//  InformationVC.m
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/18.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "InformationVC.h"
#import "UIDevice-Hardware.h"

#define ALERT_ToSupportSite	19
#define ALERT_APP_PAID			28
#define ALERT_CONTACT			37

@implementation InformationVC


#pragma mark - View dealloc

- (void)dealloc 
{
    [super dealloc];
}


#pragma mark - View lifecicle

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
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//ibLbProductName.text = NSLocalizedString(@"Product Title",nil);
	
	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#ifdef AzSTABLE
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72s1.png"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57s1.png"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@", zVersion];
	//
	ibBuPaidApp.hidden = YES;  // 有料版 AppStore 非表示
#else
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72free.png"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57free.png"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@\nFree", zVersion];
#endif
}

/*
 // viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
 - (void)viewWillAppear:(BOOL)animated 
 {
 [super viewWillAppear:animated];
 }
 */


#pragma mark  View 回転

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) return YES; // タテは常にOK
	else if (72 <= ibImgIcon.frame.size.width) return YES; // iPad
	return NO;
	//NG//if (700 < self.view.frame.size.height) return YES; // 小窓タイプなので、これでは判断できない
}


#pragma mark - IBAction

- (IBAction)ibBuToSupport:(UIButton *)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ToSupportSite",nil)
													message:NSLocalizedString(@"ToSupportSite msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"＜Back"
										  otherButtonTitles:@"Go safari＞", nil];
	alert.tag = ALERT_ToSupportSite;
	[alert show];
	[alert autorelease];
}

- (IBAction)ibBuPaidApp:(UIButton *)button
{
	//alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AppStore Paid",nil)
													message:NSLocalizedString(@"AppStore Paid msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"＜Back"
										  otherButtonTitles:@"Go safari＞", nil];
	alert.tag = ALERT_APP_PAID;
	[alert show];
	[alert autorelease];
}

- (IBAction)ibBuContact:(UIButton *)button
{
	//メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
    if (![MFMailComposeViewController canSendMail]) {
		//[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
		//alertBox( NSLocalizedString(@"Contact NoMail",nil), NSLocalizedString(@"Contact NoMail msg",nil), @"OK" );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Contact NoMail",nil)
														message:NSLocalizedString(@"Contact NoMail msg",nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
        return;
    }

	//alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact mail",nil)
													message:NSLocalizedString(@"Contact mail msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_CONTACT;
	[alert show];
	[alert autorelease];
}

- (IBAction)ibBuOK:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark - delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_ToSupportSite: {
			//NSURL *url = [NSURL URLWithString:@"http://azukisoft.seesaa.net/"];
			NSURL *url = [NSURL URLWithString:@"http://calcroll.tumblr.com/"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;

		case ALERT_APP_PAID: { // Paid App Store																															432480691
			NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432480691&mt=8"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;
			
		case ALERT_CONTACT: { // Post commens
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			
			// To: 宛先
			NSArray *toRecipients = [NSArray arrayWithObject:@"CalcRoll@azukid.com"];
			[picker setToRecipients:toRecipients];
			//[picker setCcRecipients:nil];
			//[picker setBccRecipients:nil];
			
			// Subject: 件名
			NSString* zSubj = NSLocalizedString(@"Product Title",nil);
#ifdef AzSTABLE
			//zSubj = [zSubj stringByAppendingString:@" Stable"];
#else
			zSubj = [zSubj stringByAppendingString:@" Free"];
#endif
			[picker setSubject:zSubj];  
			
			// Body: 本文
			NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
			NSString *zBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; //（ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
			NSString* zBody = [NSString stringWithFormat:@"Product: %@\n",  zSubj];
#ifdef AzSTABLE
			zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@) Stable\n",  zVersion, zBuild];
#else
			zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@)\n",  zVersion, zBuild];
#endif
			UIDevice *device = [UIDevice currentDevice];
			NSString* deviceID = [device platformString];	
			zBody = [zBody stringByAppendingFormat:@"Device: %@   iOS: %@\n\n", 
					 deviceID,
					 [[UIDevice currentDevice] systemVersion]]; // OSの現在のバージョン

			NSArray *languages = [NSLocale preferredLanguages];
			zBody = [zBody stringByAppendingFormat:@"Locale: %@ (%@)\n\n",
					 [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
					 [languages objectAtIndex:0]];
			
			zBody = [zBody stringByAppendingString:NSLocalizedString(@"Contact message",nil)];
			[picker setMessageBody:zBody isHTML:NO];
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}	break;
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error 
{
    switch (result){
        case MFMailComposeResultCancelled:
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            break;
        case MFMailComposeResultSent: {
            //送信した場合
			//alertBox( NSLocalizedString(@"Contact Sent",nil), NSLocalizedString(@"Contact Sent msg",nil), @"OK" );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact Sent",nil)
															message:NSLocalizedString(@"Contact Sent msg",nil)
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		} break;
        case MFMailComposeResultFailed: {
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
			//alertBox( NSLocalizedString(@"Contact Failed",nil), NSLocalizedString(@"Contact Failed msg",nil), @"OK" );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact Failed",nil)
															message:NSLocalizedString(@"Contact Failed msg",nil)
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
        } break;
        default:
            break;
    }
	[self dismissModalViewControllerAnimated:YES];
}

@end
