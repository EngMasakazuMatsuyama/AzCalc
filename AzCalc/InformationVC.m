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


@implementation InformationVC

- (void)dealloc {
    [super dealloc];
}


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

- (IBAction)ibBuContact:(UIButton *)button
{
	//メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
    if (![MFMailComposeViewController canSendMail]) {
		//[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
		alertBox( NSLocalizedString(@"Contact NoMail",nil), NSLocalizedString(@"Contact NoMail msg",nil), @"OK" );
        return;
    }

	alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
	
	// To: 宛先
	NSArray *toRecipients = [NSArray arrayWithObject:@"CalcRoll@azukid.com"];
	[picker setToRecipients:toRecipients];
    //[picker setCcRecipients:nil];
	//[picker setBccRecipients:nil];
	
	// Subject: 件名
	NSString* zSubj = [NSString stringWithFormat:@"%@ %@ ", 
					   NSLocalizedString(@"Product Title",nil), 
					   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
#ifdef AzSTABLE
	zSubj = [zSubj stringByAppendingString:@"Stable"];
#else
	zSubj = [zSubj stringByAppendingString:@"Free"];
#endif
	
	UIDevice *device = [UIDevice currentDevice];
	NSString* deviceID = [device platform];	
	zSubj = [zSubj stringByAppendingFormat:@" [%@-%@]", 
			 deviceID, 
			 [[ UIDevice currentDevice ] systemVersion]]; // OSの現在のバージョン
	
	[picker setSubject:zSubj];  

    // Body: 本文
    [picker setMessageBody:NSLocalizedString(@"Contact message",nil) isHTML:NO];
	
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    switch (result){
        case MFMailComposeResultCancelled:
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            break;
        case MFMailComposeResultSent:
            //送信した場合
			alertBox( NSLocalizedString(@"Contact Sent",nil), NSLocalizedString(@"Contact Sent msg",nil), @"OK" );
            break;
        case MFMailComposeResultFailed:
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
			alertBox( NSLocalizedString(@"Contact Failed",nil), NSLocalizedString(@"Contact Failed msg",nil), @"OK" );
            break;
        default:
            break;
    }
	[self dismissModalViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//ibLbProductName.text = NSLocalizedString(@"Product Title",nil);

	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; // "Bundle version"
#ifdef AzSTABLE
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72s1.png"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57s1.png"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@\nStable", zVersion];
#else
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72free.png"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57free.png"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@\nFree", zVersion];
#endif
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	//NG//if (700 < self.view.frame.size.height) return YES; // 小窓タイプなので、これでは判断できない
	if (72 <= ibImgIcon.frame.size.width) return YES; // iPad
	return NO;
}


/*
// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}
*/


- (IBAction)ibBuOK:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
