//
//  DropboxView.m
//  AzCalc-Xc4.2
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//

#import "DropboxVC.h"

@implementation DropboxVC

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


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

}

- (IBAction)ibSegSort:(UISegmentedControl *)segment
{
	
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//ibTfName.delegate = self;   IBにて定義済み
	//ibTableView.delegate = self;
	
	[[self restClient] loadMetadata:@"/"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
	[mMetadatas release], mMetadatas = nil;
    [super dealloc];
}


#pragma mark - Dropbox <DBRestClientDelegate>

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata 
{
    if (metadata.isDirectory) {
#ifdef DEBUG
        NSLog(@"Folder '%@' contains:", metadata.path);
		for (DBMetadata *file in metadata.contents) {
			NSLog(@"\t%@", file.filename);
		}
#endif
		[mMetadatas release];
		mMetadatas = [[NSArray alloc] initWithArray:metadata.contents];
		[ibTableView reloadData];
	}
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error 
{
    NSLog(@"Error loading metadata: %@", error);
	[mMetadatas release];
	mMetadatas = nil;
	[ibTableView reloadData];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
									   reuseIdentifier:CellIdentifier] autorelease];
    }
	
	switch (indexPath.section) {
		case 0: {
			if (0 < [mMetadatas count]) {
				DBMetadata *dbm = [mMetadatas objectAtIndex:indexPath.row];
				cell.detailTextLabel.text = dbm.filename;
			} else {
				cell.detailTextLabel.text = NSLocalizedString(@"Loading", nil);
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
	[ibTableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択解除
	switch (indexPath.section) {
		case 0: { // CLOSE
			[self dismissModalViewControllerAnimated:YES];
		} break;
			
		case 1: { // SAVE
			switch (indexPath.row) {
				case 0:
					break;
				case 1:
					break;
			}
		} break;
			
		case 2: {	// LOAD
		} break;
	}
}

@end
