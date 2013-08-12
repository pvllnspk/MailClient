//
//  PopoverContentViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleMailbox;

typedef enum { PopoverDeleteAccount, PopoverReplyEmail} PopoverType;

@protocol DeleteAccountDelegate <NSObject>
@optional
- (void)accountDeleted:(GoogleMailbox *)account;
@end

@protocol ReplyEmailDelegate <NSObject>
@optional
- (void)replyEmailPressed:(GoogleMailbox *)account;
@end

@interface PopoverContentViewController : UITableViewController

- (id)initWithType:(PopoverType)popoverType;

@property (nonatomic, retain) GoogleMailbox *account;

@property (nonatomic, assign) id <DeleteAccountDelegate> delegateDeleteAccount;
@property (nonatomic, assign) id <ReplyEmailDelegate> delegateReplyEmail;

@end
