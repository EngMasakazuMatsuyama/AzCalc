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

@interface InformationVC : UIViewController  <MFMailComposeViewControllerDelegate>
{
	IBOutlet UILabel*	ibLbProductName;
	IBOutlet UILabel*	ibLbVersion;
	IBOutlet UIImageView*	ibImgIcon;
}

- (IBAction)ibBuContact:(UIButton *)button;
- (IBAction)ibBuOK:(UIButton *)button;

@end
