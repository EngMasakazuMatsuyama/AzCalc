//
//  InformationVC.h
//  AzCalc-0.0
//
//  Created by 松山 和正 on 10/07/18.
//  Copyright 2010 AzukiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InformationVC : UIViewController 
{
	IBOutlet UILabel *ibLbProductName;
	IBOutlet UILabel *ibLbVersion;
}

- (IBAction)ibBuOK:(UIButton *)button;

@end
