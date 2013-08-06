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
#import "PopoverContentViewController.h"
#import "MessagesViewController.h"

@interface MailboxesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, AddAccountDelegate, DeleteAccountDelegate ,CloseReplaceControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
