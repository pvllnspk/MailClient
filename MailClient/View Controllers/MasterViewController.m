//
//  MasterViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MCTreeTableViewCell.h"
#import "MCTreeItem.h"
#import "AddAccountViewController.h"
#import "GoogleMailAccount.h"


@implementation MasterViewController
{
    UIActivityIndicatorView *_spinner;
    
    NSMutableArray* _accounts;
    NSMutableDictionary* _subFolders;
    
    NSMutableArray* _accountsTreeItems;
    NSMutableDictionary* _subFoldersTreeItems;
    
    NSMutableArray* _displayedTreeItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _accounts = [[NSMutableArray alloc]init];
    _subFolders = [[NSMutableDictionary alloc]init];
    _accountsTreeItems = [[NSMutableArray alloc]init];
    _subFoldersTreeItems = [[NSMutableDictionary alloc]init];
    
    [_topBarView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
    
	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_tableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView setRowHeight:65.0f];
    
    [self initSpinner];
    
    [self loadTestAccount];
}

-(void) loadTestAccount
{
    [self showSpinner];
    
    dispatch_async([AppDelegate serialGlobalBackgroundQueue], ^{
        
        DLog(@"attempt to connect to the gmail account");
        
        GoogleMailAccount *account = [[GoogleMailAccount alloc]
                                      initWithFullName:@"iosmailclienttest" emailAddress:@"iosmailclienttest@gmail.com" password:@"testiosmailclienttest"];
        BOOL success = [account connect];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!success){
                
                DLog(@"Failed %@",account.connectionError);
            }
            else{
                
                DLog(@"Success");
                [self accountAdded:account];
            }
            
            [self hideSpinner];
        });
    });
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
    MCTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectingTableViewCell"];
	if (!cell)
		cell = [[MCTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectingTableViewCell"];
	
	MCTreeItem *treeItem = [_displayedTreeItems objectAtIndex:indexPath.row];
	
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
	[self.detailViewController setFolder:[_displayedTreeItems objectAtIndex:(indexPath.row)-1]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *selectedTreeItems = [NSMutableArray array];
	
	MCTreeTableViewCell *cell = (MCTreeTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    if([cell.treeItem.path isEqualToString:@"/"]){
        //
    }else{
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
                NSLog(@"%@", tmp3TreeItem.base);
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toAddAccount"]){
        AddAccountViewController *addAccountViewController = segue.destinationViewController;
        addAccountViewController.delegate = self;
    }
}

-(void)accountAdded:(GoogleMailAccount *)account
{
    [_accounts addObject:account];
    [_subFolders setObject:[account subscribedFolders] forKey:account.emailAddress];
    
    [self refreshTableViewTree];
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


@end
