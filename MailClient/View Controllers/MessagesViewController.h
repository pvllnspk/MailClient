//
//  MessagesViewController.h
//  MailClient
//
//  Created by Barney on 8/6/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CloseReplaceControllerDelegate <NSObject>
@optional
- (void)closeReplaceController;
@end

@interface MessagesViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)returnToMailboxes:(id)sender;
-(void) setFolder:(CTCoreFolder*) folder;

@property (nonatomic, assign) id <CloseReplaceControllerDelegate> delegate;

@end
