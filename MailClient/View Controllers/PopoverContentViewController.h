//
//  PopoverContentViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseMailbox;

typedef enum { PopoverDeleteAccount, PopoverReplyEmail, PopoverChooseSender} PopoverType;

@protocol DeleteAccountDelegate <NSObject>
@optional
- (void)accountDeleted:(BaseMailbox *)account;
@end

@protocol ReplyEmailDelegate <NSObject>
@optional
- (void)replyEmailPressed:(BaseMailbox *)account;
@end

@protocol ChooseSenderDelegate <NSObject>
@optional
- (void)senderChoosed:(NSString *)sender;
@end

@interface PopoverContentViewController : UITableViewController

- (id)initWithType:(PopoverType)popoverType;

@property (nonatomic, retain) BaseMailbox *account;
@property (nonatomic, retain) NSArray *mailboxes;

@property (nonatomic, assign) id <DeleteAccountDelegate> delegateDeleteAccount;
@property (nonatomic, assign) id <ReplyEmailDelegate> delegateReplyEmail;
@property (nonatomic, assign) id <ChooseSenderDelegate> delegateChooseSender;

@end
