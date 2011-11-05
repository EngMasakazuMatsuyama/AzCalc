//
//  DropboxVC.h
//  AzCalc-Xc4.2
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DBRestClientDelegate>
{
	IBOutlet UIButton		*ibBuClose;
	IBOutlet UIButton		*ibBuSave;
	IBOutlet UITextField	*ibTfName;

	IBOutlet UISegmentedControl	*ibSegSort;
	IBOutlet UITableView	*ibTableView;

	
	DBRestClient	*restClient;
	NSArray			*mMetadatas;
}

- (IBAction)ibBuClose:(UIButton *)button;
- (IBAction)ibBuSave:(UIButton *)button;
- (IBAction)ibSegSort:(UISegmentedControl *)segment;

@end
