//
//  InformationVC.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/18.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InformationVC : UIViewController  <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	IBOutlet UILabel*	ibLbProductName;
	IBOutlet UILabel*	ibLbVersion;
	IBOutlet UIImageView*	ibImgIcon;
	IBOutlet UIButton*	ibBuPaidApp;
}

//- (IBAction)ibBuIcon:(UIButton *)button;
- (IBAction)ibBuPaidApp:(UIButton *)button;
- (IBAction)ibBuContact:(UIButton *)button;
- (IBAction)ibBuOK:(UIButton *)button;

@end
