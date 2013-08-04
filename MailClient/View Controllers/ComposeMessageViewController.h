//
//  ComposeMessageViewController.h
//  MailClient
//
//  Created by Barney on 8/4/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "JSTokenField.h"

@interface ComposeMessageViewController : UIViewController <JSTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bodyView;

- (IBAction)cancel:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end
