//
//  MasterViewController.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MCTreeTableViewCell.h"
#import "AddAccountViewController.h"
#import "PopoverContentViewController.h"
#import "MessagesViewController.h"

@class MessageViewController;

@interface MailboxesViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, AddAccountDelegate, DeleteAccountDelegate, CloseChildControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MessageViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
