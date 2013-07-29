//
//  DetailViewController.h
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UISearchDisplayDelegate,
UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

-(void) setFolder:(CTCoreFolder*) folder;

@end
