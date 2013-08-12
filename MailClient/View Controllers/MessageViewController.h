//
//  DetailViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMailbox.h"

@interface MessageViewController : UIViewController <UISplitViewControllerDelegate ,DTAttributedTextContentViewDelegate>

- (void) setMessage:(CTCoreMessage *)message forFolder:(CTCoreFolder*) folder andAccount: (BaseMailbox*)account;

@end
