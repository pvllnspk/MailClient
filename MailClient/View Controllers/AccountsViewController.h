//
//  MasterViewController.h
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTreeTableViewCell.h"
#import "AddAccountViewController.h"

@class FoldersViewController;

@interface AccountsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddAccountDelegate ,UIGestureRecognizerDelegate>

@property (strong, nonatomic) FoldersViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;

@end
