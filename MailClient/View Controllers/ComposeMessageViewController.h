//
//  ComposeMessageViewController.h
//  MailClient
//
//  Created by Barney on 8/4/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topBar;

- (IBAction)cancel:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end
