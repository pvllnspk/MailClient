//
//  MasterViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MailboxesViewController.h"
#import "MCTreeTableViewCell.h"
#import "MCTreeItem.h"
#import "AddAccountViewController.h"
#import "GoogleMailAccount.h"
#import "PopoverContentViewController.h"
#import "MessagesViewController.h"


@implementation MailboxesViewController
{
    UIActivityIndicatorView *_spinner;
    
    NSMutableArray* _accounts;
    NSMutableDictionary* _subFolders;
    
    NSMutableArray* _accountsTreeItems;
    NSMutableDictionary* _subFoldersTreeItems;
    
    NSMutableArray* _displayedTreeItems;
    
    UIPopoverController *_popoverController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self initViews];    
    
    if(LOAD_TEST_ACCOUNT_AT_START){
        
        [self loadTestAccount];
    }
}


-(void) initData
{
    _accounts = [NSMutableArray array];
    _subFolders = [NSMutableDictionary dictionary];
    _accountsTreeItems = [NSMutableArray array];
    _subFoldersTreeItems = [NSMutableDictionary dictionary];
}

-(void) initViews
{
    [_topBarView setBackgroundColor:BACKGROUND_COLOR];
    
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_tableView setBackgroundColor:BACKGROUND_COLOR];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView setRowHeight:65.0f];
    
    [self initSpinner];
    [self initPopover];
}

-(void) initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}

-(void) initPopover
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(tableViewLongPress:)];
    
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    longPressGestureRecognizer.delegate = self;
    [_tableView addGestureRecognizer:longPressGestureRecognizer];
}


-(void) loadTestAccount
{
    [self showSpinner];
    
    dispatch_async([AppDelegate serialGlobalBackgroundQueue], ^{
        
        DLog(@"Attempt to connect to the test account.");
        
        GoogleMailAccount *account = [[GoogleMailAccount alloc]
                                      initWithFullName:@"iosmailclienttest" emailAddress:@"iosmailclienttest@gmail.com" password:@"testiosmailclienttest"];
        BOOL success = [account connect];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            
            if (success){
                
                DLog(@"Success.");
                [self accountAdded:account];
            }
            else{
                
                DLog(@"Failed with error %@ .",account.connectionError);
            }
        });
    });
}


-(void) showSpinner
{
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [_spinner stopAnimating];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_displayedTreeItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mailboxesTableViewCell"];
	if (!cell)
		cell = [[MCTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mailboxesTableViewCell"];
	
	MCTreeItem *treeItem = [_displayedTreeItems objectAtIndex:indexPath.row];
	cell.treeItem = treeItem;
	
	if ([treeItem.path isEqualToString:@"/"]){
        cell.countLabel.hidden = YES;
        cell.iconButton.hidden = YES;
    }
	else{
        cell.countLabel.hidden = YES;
        cell.iconButton.hidden = NO;
    }

	[cell.titleTextField setText:[treeItem base]];
	[cell.titleTextField sizeToFit];
    
	[cell setLevel:[treeItem submersionLevel]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    NSMutableArray *selectedTreeItems = [NSMutableArray array];
	
	MCTreeTableViewCell *cell = (MCTreeTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    if(![cell.treeItem.path isEqualToString:@"/"]){
        
        [self tableViewAction:tableView withIndexPath:indexPath];
    }
	
	NSInteger insertTreeItemIndex = [_displayedTreeItems indexOfObject:cell.treeItem];
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
		
		for (MCTreeItem *tmp2TreeItem in _displayedTreeItems) {
			if ([tmp2TreeItem isEqualToSelectingItem:tmpTreeItem]) {
				contains = YES;
				
				[self selectingItemsToDelete:tmp2TreeItem saveToArray:treeItemsToRemove];
				
				removeIndexPaths = [self removeIndexPathForTreeItems:(NSMutableArray *)treeItemsToRemove];
			}
		}
		
		if (!contains) {
			[tmpTreeItem setSubmersionLevel:tmpTreeItem.submersionLevel];
			[_displayedTreeItems insertObject:tmpTreeItem atIndex:insertTreeItemIndex];
			
			NSIndexPath *indexPth = [NSIndexPath indexPathForRow:insertTreeItemIndex inSection:0];
			[insertIndexPaths addObject:indexPth];
		}
	}
    
    for (MCTreeItem *tmp2TreeItem in treeItemsToRemove) {
        [_displayedTreeItems removeObject:tmp2TreeItem];
        
        for (MCTreeItem *tmp3TreeItem in selectedTreeItems) {
            if ([tmp3TreeItem isEqualToSelectingItem:tmp2TreeItem]) {
                [selectedTreeItems removeObject:tmp2TreeItem];
                break;
            }
        }
    }
	
	if ([insertIndexPaths count])
		[_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
	
	if ([removeIndexPaths count])
		[_tableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
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
        
        MCTreeItem *treeNode = [_displayedTreeItems objectAtIndex:i];
		for (MCTreeItem *tmpTreeItem in treeItemsToRemove) {
			if ([treeNode isEqualToSelectingItem:tmpTreeItem])
				[result addObject:indexPath];
		}
	}
	return result;  
}

- (void)tableViewAction:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    MCTreeItem *treeItem = [_displayedTreeItems objectAtIndex:indexPath.row];
    
    for(GoogleMailAccount * account in _accounts){
        if([account.emailAddress isEqualToString:[treeItem.path stringByReplacingOccurrencesOfString:@"/" withString:@""]]){
            
            CTCoreFolder *folder = [account folderWithPath:treeItem.base];
            [self performSegueWithIdentifier: @"toMessages" sender: folder];
            
            return;
        }
    }
}


-(void)accountAdded:(GoogleMailAccount *)account
{
    BOOL alreadyAdded = FALSE;
    
    for(GoogleMailAccount *existAccount in _accounts){
        if([existAccount.emailAddress isEqualToString:account.emailAddress]){
            alreadyAdded = TRUE;
            break;
        }
    }
    
    if(!alreadyAdded){
        
        [_accounts addObject:account];
        [_subFolders setObject:[account subscribedFolders] forKey:account.emailAddress];
        
        [self refreshTableViewTree];
    }
}

-(void)accountDeleted:(GoogleMailAccount *)account
{
    [_accounts removeObject:account];
    [_subFolders removeObjectForKey:account.emailAddress];
    [self refreshTableViewTree];
    
    [_popoverController dismissPopoverAnimated:YES];
}


-(void) refreshTableViewTree
{
    [_accountsTreeItems removeAllObjects];
    [_subFoldersTreeItems removeAllObjects];
    
    for(GoogleMailAccount *account in _accounts){
        
        MCTreeItem *accountTreeItem = [[MCTreeItem alloc] init];
        [accountTreeItem setBase:account.emailAddress];
        [accountTreeItem setPath:@"/"];
        [accountTreeItem setSubmersionLevel:0];
        [accountTreeItem setParentSelectingItem:nil];
        
         NSMutableArray *children = [[NSMutableArray alloc]init];
        
        for(NSString *folder in [_subFolders objectForKey:account.emailAddress]){
            
            MCTreeItem *childItem = [[MCTreeItem alloc] init];
            [childItem setBase:folder];
            [childItem setPath:[NSString stringWithFormat:@"/%@",account.emailAddress]];
            [childItem setSubmersionLevel:1];
            [childItem setParentSelectingItem:accountTreeItem];
            [childItem setNumberOfSubitems:0];
            
            [children addObject:childItem];
        }
        
        [accountTreeItem setAncestorSelectingItems:children];
        [accountTreeItem setNumberOfSubitems:[children count]];
        
        [_accountsTreeItems addObject:accountTreeItem];
        [_subFoldersTreeItems setValue:children forKey:[NSString stringWithFormat:@"/%@",accountTreeItem.base]];
    }
    
    _displayedTreeItems = [self listItemsAtPath:@"/"];
    [_tableView reloadData];
}

- (NSMutableArray *)listItemsAtPath:(NSString *)path
{
	if ([path isEqualToString:@"/"]) {
		return [NSMutableArray arrayWithArray:_accountsTreeItems];
	} else {
		return [NSMutableArray arrayWithArray:[_subFoldersTreeItems objectForKey:path]];
	}
}


-(void)tableViewLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        CGPoint point = [gestureRecognizer locationInView:_tableView];
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
        
        if (indexPath){
            
            MCTreeTableViewCell *cell = (MCTreeTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
            
            if([cell.treeItem.path isEqualToString:@"/"]){
                
                PopoverContentViewController *popoverContentViewController = [[PopoverContentViewController alloc]init];
                popoverContentViewController.delegate = self;
                
                MCTreeItem *treeItem = [_displayedTreeItems objectAtIndex:indexPath.row];
                
                for(GoogleMailAccount * account in _accounts){
                    
                    if([account.emailAddress isEqualToString:treeItem.base]){
                        popoverContentViewController.account = account;
                        break;
                    }
                }
                
                CGRect cellFrame = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
                cellFrame.size.height = cell.frame.size.height/2;
                _popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContentViewController];
                
                [_popoverController presentPopoverFromRect:cellFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            }
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toAddAccount"]){
        
        AddAccountViewController *addAccountViewController = segue.destinationViewController;
        addAccountViewController.delegate = self;
        
    }
    else
        if([segue.identifier isEqualToString:@"toMessages"]){
            
            MessagesViewController *messagesViewController = segue.destinationViewController;
            messagesViewController.delegate = self;
            [messagesViewController setFolder:(CTCoreFolder *)sender];
        }
}

-(void)closeReplaceController
{
    DLog(@"closeReplaceController");
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}


@end
