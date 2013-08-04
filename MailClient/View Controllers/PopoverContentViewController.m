//
//  PopoverViewController.m
//  MailClient
//
//  Created by Barney on 8/4/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "PopoverContentViewController.h"

@implementation PopoverContentViewController
{
    UITableView *_tableView;
    NSMutableArray *_rows;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}

-(void)viewDidLoad
{
    _rows = [NSMutableArray array];
    [_rows addObject:@"Delete this account"];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    _tableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[_tableView  setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[_tableView  setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
	[_tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView  setRowHeight:65.0f];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    NSInteger rowsCount = [_rows count];
    NSInteger singleRowHeight = [_tableView.delegate tableView:_tableView
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    cell.textLabel.text = [_rows objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath 1");
    
    
    if(_delegate){
        DLog(@"didSelectRowAtIndexPath 2 %@",_account);
        
        [_delegate accountDeleted:_account];
    }
}

@end
