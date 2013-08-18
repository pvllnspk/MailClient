//
//  AddAccountViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseMailbox;

@protocol AddAccountDelegate <NSObject>
@optional
- (void)accountAdded:(BaseMailbox *)account;
@end

@interface AddAccountViewController : UIViewController

@property (nonatomic, assign) id <AddAccountDelegate> delegate;

@end
