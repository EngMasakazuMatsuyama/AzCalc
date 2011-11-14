//
//  DropboxView.m
//  AzCalc-Xc4.2
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//

#import "DropboxVC.h"
#import "AzCalcViewController.h"

#define TAG_ACTION_Save			109
#define TAG_ACTION_Retrieve		118

#define USER_KEYBOARD_FILENAME		@"DropboxFileName"

@implementation DropboxVC
@synthesize delegate;
@synthesize mLocalPath;


#pragma mark - Alert

- (void)alertIndicatorOn:(NSString*)zTitle
{
	[mAlert setTitle:zTitle];
	[mAlert show];
	[mActivityIndicator setFrame:CGRectMake((mAlert.bounds.size.width-50)/2, mAlert.frame.size.height-75, 50, 50)];
	[mActivityIndicator startAnimating];
}

- (void)alertIndicatorOff
{
	[mActivityIndicator stopAnimating];
	[mAlert dismissWithClickedButtonIndex:mAlert.cancelButtonIndex animated:YES];
}

- (void)alertCommError
{
	UIAlertView *alv = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CommError", nil) 
												   message:NSLocalizedString(@"CommErrorMsg", nil) 
												  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil] autorelease];
	[alv show];
}

#pragma mark - Dropbox DBRestClient

- (DBRestClient *)restClient 
{
	if (!restClient) {
		restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
	return restClient;
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
		UIAlertView *alv = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NameLeast", nil) 
													  message:NSLocalizedString(@"NameLeastMsg", nil)  
													  delegate:nil cancelButtonTitle:nil 
											 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil] autorelease];
		[alv show];
		return;
	}
	
	UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure", nil) 
													delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
									  destructiveButtonTitle:nil 
											otherButtonTitles:NSLocalizedString(@"SaveKeyboard", nil), nil] autorelease];
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
	[mAlert release];
	mAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil]; // deallocにて解放
	//[self.view addSubview:mAlert];　　alertIndicatorOn:にてaddSubviewしている。
	[mActivityIndicator release];
	mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	mActivityIndicator.frame = CGRectMake(0, 0, 50, 50);
	[mAlert addSubview:mActivityIndicator];
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
	[mDidSelectRowAtIndexPath release], mDidSelectRowAtIndexPath = nil;
	[mActivityIndicator release];
	[mAlert release];
	[mMetadatas release], mMetadatas = nil;
    [super dealloc];
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
		[mMetadatas release], mMetadatas = nil;
		if ([metadata.contents count]<=0) return;
		
		//mMetadatas = [[NSMutableArray alloc] initWithArray:metadata.contents];
		mMetadatas = [NSMutableArray new];
		for (DBMetadata *dbm in metadata.contents) {
			if ([[dbm.filename pathExtension] caseInsensitiveCompare:@"CalcRoll"]==NSOrderedSame) { // 大小文字区別なく比較する
				[mMetadatas addObject:dbm];
			}
		}
		// Sorting
		if (ibSegSort.selectedSegmentIndex==0) { // Name Asc
			NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"filename" ascending:YES];
			NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
			[sort1 release];
			[mMetadatas sortUsingDescriptors:sorting]; // 降順から昇順にソートする
			[sorting release];
		} else { // Date Desc
			NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
			NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
			[sort1 release];
			[mMetadatas sortUsingDescriptors:sorting]; // 降順から昇順にソートする
			[sorting release];
		}
		[ibTableView reloadData];
	}
	//
	[self alertIndicatorOff];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error 
{	// メタデータ読み込み失敗
    NSLog(@"Error loading metadata: %@", error);
	[mMetadatas release];
	mMetadatas = nil;
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
	UIAlertView *alv = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QuoteDone", nil)
												   message:nil
												  delegate:nil
										 cancelButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil] autorelease];
	[alv	show];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error 
{	// ファイル読み込み失敗
    NSLog(@"There was an error loading the file - %@", error);
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
	UIAlertView *alv = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SaveDone", nil) 
												   message:nil  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil] autorelease];
	[alv show];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error 
{	// ファイル書き込み失敗
    NSLog(@"File upload failed with error - %@", error);
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
			if (0 < [mMetadatas count]) {
				return [mMetadatas count];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];
    }
	
	switch (indexPath.section) {
		case 0: {
			if (0 < [mMetadatas count]) {
				DBMetadata *dbm = [mMetadatas objectAtIndex:indexPath.row];
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
	if (0<=indexPath.row && indexPath.row<[mMetadatas count]) 
	{
		[mDidSelectRowAtIndexPath release], mDidSelectRowAtIndexPath = nil;
		DBMetadata *dbm = [mMetadatas objectAtIndex:indexPath.row];
		if (dbm) {
			mDidSelectRowAtIndexPath = [indexPath copy];
			NSLog(@"dbm.filename=%@", dbm.filename);
			ibTfName.text = [dbm.filename stringByDeletingPathExtension];
			NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
			[userDef setObject:ibTfName.text  forKey:USER_KEYBOARD_FILENAME];
			[userDef synchronize];
			//
			UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure", nil) 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											   destructiveButtonTitle:NSLocalizedString(@"ChangeKeyboard", nil) 
													otherButtonTitles:nil] autorelease];
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
    NSMutableString *text = [[textField.text mutableCopy] autorelease];
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
	if (mDidSelectRowAtIndexPath) {
		@try {
			[ibTableView deselectRowAtIndexPath:mDidSelectRowAtIndexPath animated:YES]; // 選択解除
		}
		@catch (NSException *exception) {
			NSLog(@"ERROR");
		}
	}

	if (buttonIndex==actionSheet.cancelButtonIndex) return; // CANCEL
	
	switch (actionSheet.tag) {
		case TAG_ACTION_Save:	// 保存
			if (mLocalPath) {
				NSString *filename = [ibTfName.text stringByDeletingPathExtension]; // 拡張子を除く
				filename = [filename stringByAppendingFormat:@".%@", [mLocalPath pathExtension]]; // 拡張子を付ける
				NSLog(@"mLocalPath=%@, filename=%@", mLocalPath, filename);
				[self alertIndicatorOn:NSLocalizedString(@"Communicating", nil)];
				[[self restClient] uploadFile:filename toPath:mRootPath withParentRev:nil fromPath:mLocalPath];
			}
			break;
		case TAG_ACTION_Retrieve:		// このキーボードを採用する。
			if (mDidSelectRowAtIndexPath && mDidSelectRowAtIndexPath.row < [mMetadatas count]) {
				DBMetadata *dbm = [mMetadatas objectAtIndex:mDidSelectRowAtIndexPath.row];
				if (dbm) {
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
