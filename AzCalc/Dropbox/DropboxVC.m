//
//  DropboxView.m
//  AzCalc-Xc4.2
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//

#import "Global.h"
#import "DropboxVC.h"
#import "AzCalcViewController.h"		// delegate GvCalcRollLoad

#define TAG_ACTION_Save			109
#define TAG_ACTION_Retrieve		118

#define USER_KEYBOARD_FILENAME		@"DropboxFileName"

@implementation DropboxVC
@synthesize delegate;
@synthesize mLocalPath;


#pragma mark - Alert

- (void)alertIndicatorOn:(NSString*)zTitle
{
	[alert_ setTitle:zTitle];
	[alert_ show];
	[activityIndicator_ setFrame:CGRectMake((alert_.bounds.size.width-50)/2, alert_.frame.size.height-75, 50, 50)];
	[activityIndicator_ startAnimating];
}

- (void)alertIndicatorOff
{
	[activityIndicator_ stopAnimating];
	[alert_ dismissWithClickedButtonIndex:alert_.cancelButtonIndex animated:YES];
}

- (void)alertCommError
{
	UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CommError", nil) 
												   message:NSLocalizedString(@"CommErrorMsg", nil) 
												  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
	[alv show];
}

#pragma mark - Dropbox DBRestClient

- (DBRestClient *)restClient
{
	if (!restClient_) {
		restClient_ = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient_.delegate = self;
	}
	return restClient_;
}


#pragma mark - IBAction

- (IBAction)ibBuClose:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuSave:(UIButton *)button
{
	NSString *filename = [ibTfName.text stringByDeletingPathExtension]; // 拡張子を除く
	if ([filename length] < 3) {
		UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NameLeast", nil) 
													  message:NSLocalizedString(@"NameLeastMsg", nil)  
													  delegate:nil cancelButtonTitle:nil 
											 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
		[alv show];
		return;
	}
	
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure", nil) 
													delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
									  destructiveButtonTitle:nil 
											otherButtonTitles:NSLocalizedString(@"SaveKeyboard", nil), nil];
	as.tag = TAG_ACTION_Save;
	[as showInView:self.view];
	[ibTfName resignFirstResponder]; // キーボードを隠す
}

- (IBAction)ibSegSort:(UISegmentedControl *)segment
{
	[self alertIndicatorOn:NSLocalizedString(@"Communicating", nil)];
	[[self restClient] loadMetadata:mRootPath];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	bPad = (320 < self.view.frame.size.width);
	if (bPad) {
		mRootPath = @"/iPad/";
	} else {
		mRootPath = @"/iPhone/";
	}

	//ibTfName.delegate = self;   IBにて定義済み
	//ibTableView.delegate = self;
	
	ibTfName.keyboardType = UIKeyboardTypeDefault;
	ibTfName.returnKeyType = UIReturnKeyDone;
	
	// alertIndicatorOn: alertIndicatorOff: のための準備
	alert_ = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil]; // deallocにて解放
	//[self.view addSubview:mAlert];　　alertIndicatorOn:にてaddSubviewしている。
	activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator_.frame = CGRectMake(0, 0, 50, 50);
	[alert_ addSubview:activityIndicator_];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	ibTfName.text = [userDef objectForKey:USER_KEYBOARD_FILENAME];
	if ([ibTfName.text length] < 3) {
		ibTfName.text = @"MyKeybord";
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	GA_TRACK_EVENT(@"Dropbox",@"View",@"viewDidAppear", 0);
	
	[self alertIndicatorOn:NSLocalizedString(@"Communicating", nil)];
	// Dropbox/App/CalcRoll 一覧表示
	[[self restClient] loadMetadata:mRootPath];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

#pragma mark unload

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
	if (restClient_) {
		restClient_.delegate = nil;
	}
	didSelectRowAtIndexPath_ = nil;
	alert_ = nil;
	metadatas_ = nil;
}


#pragma mark - Dropbox <DBRestClientDelegate>

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata 
{	// メタデータ読み込み成功
    if (metadata.isDirectory) {
#ifdef DEBUG
        NSLog(@"Folder '%@' contains:", metadata.path);
		for (DBMetadata *file in metadata.contents) {
			NSLog(@"\t%@", file.filename);
		}
#endif
		metadatas_ = nil;
		if (0 < [metadata.contents count]) {
			//mMetadatas = [[NSMutableArray alloc] initWithArray:metadata.contents];
			metadatas_ = [NSMutableArray new];
			for (DBMetadata *dbm in metadata.contents) {
				if ([[dbm.filename pathExtension] caseInsensitiveCompare:CALCROLL_EXT]==NSOrderedSame) { // 大小文字区別なく比較する
					[metadatas_ addObject:dbm];
				}
			}
			// Sorting
			if (ibSegSort.selectedSegmentIndex==0) { // Name Asc
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"filename" ascending:YES];
				NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
				[metadatas_ sortUsingDescriptors:sorting]; // 降順から昇順にソートする
			} else { // Date Desc
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
				NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
				[metadatas_ sortUsingDescriptors:sorting]; // 降順から昇順にソートする
			}
			[ibTableView reloadData];
		}
	}
	// 必ず通すこと
	[self alertIndicatorOff];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error 
{	// メタデータ読み込み失敗
    NSLog(@"Error loading metadata: %@", error);
	metadatas_ = nil;
	[ibTableView reloadData];
	//
	[self alertIndicatorOff];
	[self alertCommError];
}


- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath 
{	// ファイル読み込み成功
    NSLog(@"File loaded into path: %@", localPath);
	// mKmPages リセット
	[delegate GvCalcRollLoad:localPath]; // .CalcRoll - Plist file
	//
	[self alertIndicatorOff];
	// 閉じる
	[self dismissModalViewControllerAnimated:YES];
	// Done
	UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QuoteDone", nil)
												   message:nil
												  delegate:nil
										 cancelButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
	[alv	show];
	GA_TRACK_EVENT(@"Dropbox",@"Action",@"Loaded OK", 0);
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error 
{	// ファイル読み込み失敗
    NSLog(@"There was an error loading the file - %@", error);
	NSString *zz = [NSString stringWithFormat:@"loadFileFailedWithError: %@", error.description];
	GA_TRACK_EVENT_ERROR(zz,0);
	[self alertIndicatorOff];
	[self alertCommError];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
			  from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{	// ファイル書き込み成功
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
	// Dropbox/App/CalcRoll 一覧表示
	[[self restClient] loadMetadata:mRootPath];
	[self alertIndicatorOff];
	UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SaveDone", nil) 
												   message:nil  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
	[alv show];
	GA_TRACK_EVENT(@"Dropbox",@"Action",@"Saved OK", 0);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error 
{	// ファイル書き込み失敗
    NSLog(@"File upload failed with error - %@", error);
	NSString *zz = [NSString stringWithFormat:@"uploadFileFailedWithError: %@", error.description];
	GA_TRACK_EVENT_ERROR(zz,0);
	[self alertIndicatorOff];
	[self alertCommError];
}



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			if (0 < [metadatas_ count]) {
				return [metadatas_ count];
			} else {
				return 1;
			}
	}
    return 0;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 1:
			return NSLocalizedString(@"Dropbox Save", nil);
		case 2:
			return NSLocalizedString(@"Dropbox Load", nil);
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return NSLocalizedString(@"Dropbox", nil);
		case 1:
			return NSLocalizedString(@"Dropbox", nil);
		case 2:
			return @"(C) 2011 Azukid";
	}
	return nil;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier];
    }
	
	switch (indexPath.section) {
		case 0: {
			if (metadatas_==nil) {
				cell.textLabel.text = @"  Please wait.";
			}
			else if (0 < [metadatas_ count]) {
				DBMetadata *dbm = [metadatas_ objectAtIndex:indexPath.row];
				cell.textLabel.text = [dbm.filename stringByDeletingPathExtension]; // 拡張子を除く
			} else {
				cell.textLabel.text = NSLocalizedString(@"NoFile", nil);
			}
		} break;
	}
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0<=indexPath.row && indexPath.row<[metadatas_ count]) 
	{
		didSelectRowAtIndexPath_ = nil;
		DBMetadata *dbm = [metadatas_ objectAtIndex:indexPath.row];
		if (dbm) {
			didSelectRowAtIndexPath_ = [indexPath copy];
			NSLog(@"dbm.filename=%@", dbm.filename);
			ibTfName.text = [dbm.filename stringByDeletingPathExtension];
			NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
			[userDef setObject:ibTfName.text  forKey:USER_KEYBOARD_FILENAME];
			[userDef synchronize];
			//
			UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure", nil) 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											   destructiveButtonTitle:NSLocalizedString(@"ChangeKeyboard", nil) 
													otherButtonTitles:nil];
			as.tag = TAG_ACTION_Retrieve;
			[as showInView:self.view];
		}
		else {
			[ibTableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択解除
		}
	}
	else {
		[ibTableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択解除
	}
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder]; // キーボードを隠す
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string 
{
	// senderは、MtfName だけ
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
	// 置き換えた後の長さをチェックする
	if ([text length] <= 40) {
		//appDelegate.AppUpdateSave = YES; // 変更あり
		//self.navigationItem.rightBarButtonItem.enabled = YES; // 変更あり [Save]有効
		return YES;
	} else {
		return NO;
	}
}


#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (didSelectRowAtIndexPath_) {
		@try {
			[ibTableView deselectRowAtIndexPath:didSelectRowAtIndexPath_ animated:YES]; // 選択解除
		}
		@catch (NSException *exception) {
			NSLog(@"ERROR");
			GA_TRACK_EVENT_ERROR(@"Exception",0);
		}
	}

	if (buttonIndex==actionSheet.cancelButtonIndex) return; // CANCEL
	
	switch (actionSheet.tag) {
		case TAG_ACTION_Save:	// 保存
			if (mLocalPath) {
				GA_TRACK_EVENT(@"Dropbox",@"Action",@"Save", 0);
				NSString *filename = [ibTfName.text stringByDeletingPathExtension]; // 拡張子を除く
				filename = [filename stringByAppendingFormat:@".%@", [mLocalPath pathExtension]]; // 拡張子を付ける
				NSLog(@"mLocalPath=%@, filename=%@", mLocalPath, filename);
				[self alertIndicatorOn:NSLocalizedString(@"Communicating", nil)];
				[[self restClient] uploadFile:filename toPath:mRootPath withParentRev:nil fromPath:mLocalPath];
			}
			break;
		case TAG_ACTION_Retrieve:		// このキーボードを採用する。
			if (didSelectRowAtIndexPath_ && didSelectRowAtIndexPath_.row < [metadatas_ count]) {
				DBMetadata *dbm = [metadatas_ objectAtIndex:didSelectRowAtIndexPath_.row];
				if (dbm) {
					GA_TRACK_EVENT(@"Dropbox",@"Action",@"Load", 0);
					NSLog(@"dbm.path=%@ --> mLocalPath=%@", dbm.path, mLocalPath);
					[self alertIndicatorOn:NSLocalizedString(@"Communicating", nil)];
					[[self restClient] loadFile:dbm.path intoPath:mLocalPath]; // DownLoad開始 ---> delagate loadedFile:
				}
			}
			break;

	/*	case TAG_ACTION_Delete:		// このファイルを削除する。
			break;　*/
	}
}


@end
