//
//  DetailViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMailbox.h"
#import "MailAttributesView.h"

@interface MessageViewController : UIViewController <UISplitViewControllerDelegate, DTAttributedTextContentViewDelegate>

@property (weak, nonatomic) IBOutlet MailAttributesView *messageHeaderView;
@property (weak, nonatomic) IBOutlet DTAttributedTextView *messageBodyView;

- (void) setMessage:(CTCoreMessage *)message forFolder:(CTCoreFolder*) folder andAccount: (BaseMailbox*)account;

@end
