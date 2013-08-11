//
//  PopoverContentViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleMailAccount;

typedef enum { PopoverDeleteAccount, PopoverReplyEmail} PopoverType;

@protocol DeleteAccountDelegate <NSObject>
@optional
- (void)accountDeleted:(GoogleMailAccount *)account;
@end

@protocol ReplyEmailDelegate <NSObject>
@optional
- (void)replyEmailPressed:(GoogleMailAccount *)account;
@end

@interface PopoverContentViewController : UITableViewController

- (id)initWithType:(PopoverType)popoverType;

@property (nonatomic, retain) GoogleMailAccount *account;

@property (nonatomic, assign) id <DeleteAccountDelegate> delegateDeleteAccount;
@property (nonatomic, assign) id <ReplyEmailDelegate> delegateReplyEmail;

@end
