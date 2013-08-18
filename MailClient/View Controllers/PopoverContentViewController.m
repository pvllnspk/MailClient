//
//  PopoverContentViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "PopoverContentViewController.h"

@implementation PopoverContentViewController
{
    NSMutableArray *_rows;
    PopoverType _popoverType;
}

- (id)initWithType:(PopoverType)popoverType
{
    self = [super init];
    if (self) {
        
        [self.tableView  setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.tableView  setBackgroundColor:BACKGROUND_COLOR];
        [self.tableView  setRowHeight:45.0f];
        [self.tableView  setShowsVerticalScrollIndicator:NO];
        [self.tableView  setDelegate:self];
        [self.tableView  setDataSource:self];
        
        _popoverType = popoverType;
        
        [self initData];
        [self initPopover];
    }
    return self;
}


- (void) initData
{
    _rows = [NSMutableArray array];
    
    switch (_popoverType) {
        case PopoverDeleteAccount:
            
            [_rows addObject:@"Delete this mailbox"];
            break;
            
        case PopoverReplyEmail:
            
            [_rows addObject:@"Reply to this message"];
            break;
            
        case PopoverChooseSender:
            
            [_rows addObjectsFromArray:_mailboxes];
            break;
            
        default:
            break;
    }
}

- (void) initPopover
{
    NSInteger rowsCount = [_rows count];
    NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                           heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger totalRowsHeight = rowsCount * singleRowHeight;
    
    CGFloat largestLabelWidth = 0;
    for (NSString *row in _rows) {
        CGSize labelSize = [row sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
        if (labelSize.width > largestLabelWidth) {
            largestLabelWidth = labelSize.width;
        }
    }
    
    CGFloat popoverWidth = largestLabelWidth + 100;
    self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopoverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_popoverType) {
        case PopoverDeleteAccount:
            
            if(_delegateDeleteAccount){
                [_delegateDeleteAccount accountDeleted:_account];
            }
            break;
            
        case PopoverReplyEmail:
            
            if(_delegateReplyEmail){
                [_delegateReplyEmail replyEmailPressed:_account];
            }
            break;
            
        case PopoverChooseSender:
            
            if(_delegateChooseSender){
                [_delegateChooseSender senderChoosed:[_mailboxes objectAtIndex:indexPath.row]];
            }
            break;
            
        default:
            break;
    }
}

@end
