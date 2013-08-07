//
//  PopoverContentViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GoogleMailAccount;


@protocol DeleteAccountDelegate <NSObject>
@optional
- (void)accountDeleted:(GoogleMailAccount *)account;
@end


@interface PopoverContentViewController : UITableViewController

@property (nonatomic, retain) GoogleMailAccount *account;
@property (nonatomic, assign) id <DeleteAccountDelegate> delegate;

@end
