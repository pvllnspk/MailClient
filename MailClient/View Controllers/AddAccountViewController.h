//
//  AddAccountViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GoogleMailAccount;


@protocol AddAccountDelegate <NSObject>
@optional
- (void)accountAdded:(GoogleMailAccount *)account;
@end


@interface AddAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id <AddAccountDelegate> delegate;



@end
