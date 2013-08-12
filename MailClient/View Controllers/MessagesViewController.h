//
//  MessagesViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMailbox.h"
#import "PopoverContentViewController.h"


@protocol CloseChildControllerDelegate <NSObject>
@optional
- (void)closeChildController;
@end


@interface MessagesViewController : UIViewController <UISearchDisplayDelegate ,UISearchBarDelegate, UIGestureRecognizerDelegate,
                                                    UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ReplyEmailDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id <CloseChildControllerDelegate> delegate;

- (IBAction) returnToMailboxes:(id)sender;
- (void) setFolder:(CTCoreFolder*) folder forAccount: (GoogleMailbox*)account;

@end
