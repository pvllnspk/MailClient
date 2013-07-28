//
//  MasterViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MCTreeTableViewCell.h"
#import "MCTreeItem.h"

#if 1 // Set to 1 to enable MasterViewController Logging
#define MVCLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MVCLog(x, ...)
#endif

@implementation MasterViewController
{
    NSMutableArray *_mailboxes;
    NSMutableArray *_mailfolders;
    NSArray *_subscrubedFoldersArray;
    UIActivityIndicatorView *_spinner;
    
    MCTreeItem *_item0;
    NSMutableArray *_childItems;
}


#pragma mark
#pragma mark View Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    MVCLog(@"viewDidLoad");
    
    [_topBarView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
    
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_tableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView setRowHeight:65.0f];
    
    [self initSpinner];
    [self showSpinner];
    
    [self loadTestAccount];
}


#pragma mark
#pragma mark Misc

-(void) loadTestAccount
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("dispatch_queue_#1", 0);
    dispatch_async(backgroundQueue, ^{
        
        DLog(@"attempt to connect to the gmail account");
        
        CTCoreAccount *account = [[CTCoreAccount alloc] init];
        BOOL success = [account connectToServer:@"imap.gmail.com"
                                           port:993
                                 connectionType:CTConnectionTypeTLS
                                       authType:CTImapAuthTypePlain
                                          login:@"iosmailclienttest@gmail.com"
                                       password:@"testiosmailclienttest"];
        
        
        if (!success){
            DLog(@"Failed %@",account.lastError);
        }
        else{
            DLog(@"Success");
            
            NSSet *subscrubedFolders = [account subscribedFolders];
            _subscrubedFoldersArray = [subscrubedFolders allObjects];
            
            _mailfolders = [[NSMutableArray alloc]init];
            for(NSString *mailbox in _subscrubedFoldersArray){
                CTCoreFolder *folder = [account folderWithPath:mailbox];
                [_mailfolders addObject:folder];
            }
        }
        
        [self initTableViewTree];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            [self.tableView reloadData];
//            [[_tableView delegate] tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
        });
    });
}


#pragma mark
#pragma mark Table View Tree

-(void) initTableViewTree
{
    _item0 = [[MCTreeItem alloc] init];
	[_item0 setBase:@"iosmailclienttest@gmail.com"];
	[_item0 setPath:@"/"];
	[_item0 setSubmersionLevel:0];
	[_item0 setParentSelectingItem:nil];
    
    _childItems = [[NSMutableArray alloc]init];
    
    NSLog(@" _mailfolders %@ ",_mailfolders);
    
    for(NSString *folder in _subscrubedFoldersArray){
        MCTreeItem *childItem = [[MCTreeItem alloc] init];
        [childItem setBase:folder];
        [childItem setPath:@"/iosmailclienttest@gmail.com"];
        [childItem setSubmersionLevel:1];
        [childItem setParentSelectingItem:_item0];
        [childItem setNumberOfSubitems:0];
        
        [_childItems addObject:childItem];
    }
    
	[_item0 setAncestorSelectingItems:[NSMutableArray arrayWithArray:_childItems]];
	[_item0 setNumberOfSubitems:[_childItems count]];
    
    _mailboxes = [self listItemsAtPath:@"/"];
}

- (NSMutableArray *)listItemsAtPath:(NSString *)path {
	
	NSLog(@"%@", path);
	if ([path isEqualToString:@"/"]) {
		return [NSMutableArray arrayWithObject:_item0];
	} else if ([path isEqualToString:@"/iosmailclienttest@gmail.com"]) {
		return [NSMutableArray arrayWithArray:_childItems];
	} else {
		return [NSMutableArray array];
	}
}


#pragma mark
#pragma mark Spinner

-(void) initSpinner
{
    MVCLog(@"initSpinner");
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}

-(void) showSpinner
{
    MVCLog(@"showSpinner");
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    MVCLog(@"hideSpinner");
    [_spinner stopAnimating];
}


#pragma mark
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MVCLog(@"numberOfRowsInSection %d",[_mailboxes count]);
    return [_mailboxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectingTableViewCell"];
	if (!cell)
		cell = [[MCTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectingTableViewCell"];
	
	MCTreeItem *treeItem = [_mailboxes objectAtIndex:indexPath.row];
	
	cell.treeItem = treeItem;
	
	if ([treeItem.path isEqualToString:@"/"]){
        cell.countLabel.hidden = YES;
        cell.iconButton.hidden = YES;
    }
	else{
        cell.countLabel.hidden = YES;
        cell.iconButton.hidden = NO;
        [cell.countLabel setText:[NSString stringWithFormat:@"%d", [treeItem numberOfSubitems]]];
    }

	
	[cell.titleTextField setText:[treeItem base]];
	[cell.titleTextField sizeToFit];
    
	[cell setLevel:[treeItem submersionLevel]];
	
	return cell;
    
}

- (void)selectingItemsToDelete:(MCTreeItem *)selItems saveToArray:(NSMutableArray *)deleteSelectingItems
{
	for (MCTreeItem *obj in selItems.ancestorSelectingItems) {
		[self selectingItemsToDelete:obj saveToArray:deleteSelectingItems];
	}
	
	[deleteSelectingItems addObject:selItems];
}

- (NSMutableArray *)removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove
{
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSInteger i = 0; i < [_tableView numberOfRowsInSection:0]; ++i) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		MCTreeTableViewCell *cell = (MCTreeTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        
		for (MCTreeItem *tmpTreeItem in treeItemsToRemove) {
			if ([cell.treeItem isEqualToSelectingItem:tmpTreeItem])
				[result addObject:indexPath];
		}
	}
	return result;
}


- (void)tableViewAction:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
	[self.detailViewController setFolder:[_mailfolders objectAtIndex:(indexPath.row)-1]];
}


#pragma mark
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *selectedTreeItems = [NSMutableArray array];
	
	MCTreeTableViewCell *cell = (MCTreeTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.treeItem.path isEqualToString:@"/"]){
        //
    }else{
        [self tableViewAction:tableView withIndexPath:indexPath];
    }
	
	NSInteger insertTreeItemIndex = [_mailboxes indexOfObject:cell.treeItem];
	NSMutableArray *insertIndexPaths = [NSMutableArray array];
	NSMutableArray *insertselectingItems = [self listItemsAtPath:[cell.treeItem.path stringByAppendingPathComponent:cell.treeItem.base]];
	
	NSMutableArray *removeIndexPaths = [NSMutableArray array];
	NSMutableArray *treeItemsToRemove = [NSMutableArray array];
	
	for (MCTreeItem *tmpTreeItem in insertselectingItems) {
		[tmpTreeItem setPath:[cell.treeItem.path stringByAppendingPathComponent:cell.treeItem.base]];
		[tmpTreeItem setParentSelectingItem:cell.treeItem];
		
		[cell.treeItem.ancestorSelectingItems removeAllObjects];
		[cell.treeItem.ancestorSelectingItems addObjectsFromArray:insertselectingItems];
		
		insertTreeItemIndex++;
		
		BOOL contains = NO;
		
		for (MCTreeItem *tmp2TreeItem in _mailboxes) {
			if ([tmp2TreeItem isEqualToSelectingItem:tmpTreeItem]) {
				contains = YES;
				
				[self selectingItemsToDelete:tmp2TreeItem saveToArray:treeItemsToRemove];
				
				removeIndexPaths = [self removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove];
			}
		}
		
		for (MCTreeItem *tmp2TreeItem in treeItemsToRemove) {
			[_mailboxes removeObject:tmp2TreeItem];
			
			for (MCTreeItem *tmp3TreeItem in selectedTreeItems) {
				if ([tmp3TreeItem isEqualToSelectingItem:tmp2TreeItem]) {
					NSLog(@"%@", tmp3TreeItem.base);
					[selectedTreeItems removeObject:tmp2TreeItem];
					break;
				}
			}
		}
		
		if (!contains) {
			[tmpTreeItem setSubmersionLevel:tmpTreeItem.submersionLevel];
			
			[_mailboxes insertObject:tmpTreeItem atIndex:insertTreeItemIndex];
			
			NSIndexPath *indexPth = [NSIndexPath indexPathForRow:insertTreeItemIndex inSection:0];
			[insertIndexPaths addObject:indexPth];
		}
	}
	
	if ([insertIndexPaths count])
		[_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
	
	if ([removeIndexPaths count])
		[_tableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

@end
