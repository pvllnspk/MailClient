//
//  AddAccountViewController.h
//  MailClient
//
//  Created by Barney on 7/31/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleMailAccount;

// Delegate
@protocol AddAccountDelegate <NSObject>
@optional
- (void)accountAdded:(GoogleMailAccount *)account;
@end

@interface AddAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <AddAccountDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@end
