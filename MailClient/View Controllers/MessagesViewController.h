//
//  MessagesViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseMailbox;

@protocol CloseChildControllerDelegate <NSObject>
@optional
- (void)closeChildController;
@end

@interface MessagesViewController : UIViewController

@property (nonatomic, assign) id <CloseChildControllerDelegate> delegate;

- (IBAction) returnToMailboxes:(id)sender;
- (void) setFolder:(CTCoreFolder*) folder forAccount: (BaseMailbox*)account;
- (IBAction)swipe:(id)sender;

@end
