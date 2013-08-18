//
//  MessagesViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MessagesViewController.h"
#import "NSString+Additions.h"
#import "NSSet+Additions.h"
#import "NSString+Additions.h"
#import "TimeExecutionTracker.h"
#import "NSDate-Utilities.h"
#import "TextUtils.h"
#import "MessageViewController.h"
#import "PopoverContentViewController.h"
#import "ComposeMessageViewController.h"
#import "BaseMailbox.h"

@interface MessagesViewController() <UISearchDisplayDelegate ,UISearchBarDelegate, UIGestureRecognizerDelegate,
                                    UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ReplyEmailDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController
{
    CTCoreFolder *_folder;
    BaseMailbox *_account;
    
    NSMutableArray *_messages;
    NSMutableArray *_searchResults;
    
    UIActivityIndicatorView *_spinner;
    
    UIRefreshControl *_refreshControl;
    
    NSMutableDictionary *_messagesDescriptions;
    
    UIPopoverController *_popoverController;
    
    dispatch_queue_t backgroundQueue;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViews];
    
    backgroundQueue = dispatch_queue_create("dispatch_queue_#2", 0);
    _messagesDescriptions = [NSMutableDictionary dictionary];
    
    [self showSpinner];
}


-(void) initViews
{    
    [self initSeacrhBar];
    [self initRefreshControl];
    [self initSpinner];
    [self initPopover];
}

-(void) initSeacrhBar
{
    for (UIView *subview in _searchBarView.subviews){
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            [subview removeFromSuperview];
            break;
        }
    }
    [_searchBarView setBackgroundColor:BACKGROUND_COLOR];
}

-(void) initRefreshControl
{
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [_refreshControl addTarget:self action:@selector(updateMessages) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
}

-(void) initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}


-(void) initPopover
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                initWithTarget:self action:@selector(tableViewLongPress:)];
    
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    longPressGestureRecognizer.delegate = self;
    [_tableView addGestureRecognizer:longPressGestureRecognizer];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CTCoreMessage *message = [_searchResults objectAtIndex:indexPath.row];
    [(UILabel *)[cell viewWithTag:103] setText:[TextUtils isEmpty:message.subject replaceWith:@"[no subject]"]];
    [(UILabel *)[cell viewWithTag:101] setText:[message.from toStringSeparatingByComma]];
    [(UILabel *)[cell viewWithTag:102] setText:[self getUserFriendlyDate:message.senderDate]];
    
    if([_messagesDescriptions valueForKey:[NSString stringWithFormat:@"%d",message.hash]] == nil){
        
        [(UILabel *)[cell viewWithTag:104] setText:@"Loading ..."];
        
        if (_tableView.dragging == NO && _tableView.decelerating == NO){
            
            [self loadMessageDescription:message forIndexPath:indexPath];
        }
    }else{
        
        [(UILabel *)[cell viewWithTag:104] setText:[_messagesDescriptions valueForKey:[NSString stringWithFormat:@"%d",message.hash]]];
    }
    
    return cell;
}

- (NSString*)getUserFriendlyDate:(NSDate *)date
{
    if([date isToday]){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm a"];
        
        return [formatter stringFromDate:[NSDate date]];
        
    }else if([date isYesterday]){
        
        return @"Yesterday";
        
    }else{
        return [NSDateFormatter localizedStringFromDate:date
                                              dateStyle:NSDateFormatterShortStyle
                                              timeStyle:NSDateFormatterNoStyle];
    }
}


- (void) loadMessageDescription:(CTCoreMessage *)message forIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(backgroundQueue, ^{
        
        BOOL isHTML;
        NSString *shortBody = [message bodyPreferringPlainText:&isHTML];
        shortBody = [shortBody substringToIndex: MIN(100, [shortBody length])];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [_messagesDescriptions setValue:[TextUtils isEmpty:shortBody replaceWith:@"[no body]"] forKey:[NSString stringWithFormat:@"%d",message.hash]];
            [(UILabel *)[cell viewWithTag:104] setText:[TextUtils isEmpty:shortBody replaceWith:@"[no body]"]];
            //[cell setNeedsLayout];
        });
    });
}

- (void)loadMessageDescriptionForOnscreenRows
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        CTCoreMessage *message = [_searchResults objectAtIndex:indexPath.row];
        
        if([_messagesDescriptions valueForKey:[NSString stringWithFormat:@"%d",message.hash]] == nil){
            {
                [self loadMessageDescription:message forIndexPath:indexPath];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate){
        
        [self loadMessageDescriptionForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadMessageDescriptionForOnscreenRows];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageViewController *messageViewController =  (MessageViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [messageViewController setMessage:[_searchResults objectAtIndex:indexPath.row] forFolder:_folder andAccount:_account];
}


- (void) setFolder:(CTCoreFolder*) folder forAccount: (BaseMailbox*)account;
{
    if (_folder != folder){
        
        _folder = folder;
        _account = account;
        
        [self.navigationItem.leftBarButtonItem setTitle:@" / "];
        [self.navigationItem setTitle:folder.path];
        
        [self updateMessages];
    }
}

- (void)updateMessages
{
    if (_folder) {
        
        dispatch_async([AppDelegate serialBackgroundQueue], ^{
            
            DLog(@"Attempt to fetch messages from folder %@ .",[_folder path]);
            
            _messages = [NSMutableArray arrayWithArray:[_folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope]];
            _searchResults = [_messages mutableCopy];
            _searchResults = [NSMutableArray arrayWithArray:[[_searchResults reverseObjectEnumerator] allObjects]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideSpinner];
                [_tableView reloadData];
                
                DLog(@"Success. Fetched %d messages.",[_messages count]);
                
            });
        });
        
        if(_refreshControl && [_refreshControl isRefreshing]){
            
            [_refreshControl endRefreshing];
        }
    }
}


-(void) showSpinner
{
    [_tableView setHidden:YES];
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [_tableView setHidden:NO];
    [_spinner stopAnimating];
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{    
    [_searchResults removeAllObjects];
    
    if(searchText && searchText.length > 0){
        
        for(CTCoreMessage *message in _messages){
            
            if([message.subject contains:searchText]){
                [_searchResults addObject:message];
            }
        }
    }else{
        
        [_searchResults addObjectsFromArray:_messages];
    }
    
     _searchResults = [NSMutableArray arrayWithArray:[[_searchResults reverseObjectEnumerator] allObjects]];
    [_tableView reloadData];
}


- (IBAction)returnToMailboxes:(id)sender
{
    if(_delegate)
        [_delegate closeChildController];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toComposeMessage"]){
        
        ComposeMessageViewController *composeMessageViewController = segue.destinationViewController;
        [composeMessageViewController setSender:_account.emailAddress];
    }
}

- (IBAction)back:(id)sender
{
    MessageViewController *messageViewController =  (MessageViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [messageViewController setMessage:nil forFolder:nil andAccount:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableViewLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        CGPoint point = [gestureRecognizer locationInView:_tableView];
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
        
        if (indexPath){
            
            UITableViewCell *cell = (UITableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
                
                PopoverContentViewController *popoverContentViewController = [[PopoverContentViewController alloc]initWithType:PopoverReplyEmail];
                popoverContentViewController.delegateReplyEmail = self;
                popoverContentViewController.account = _account;
            
                CGRect cellFrame = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
                cellFrame.size.height = cell.frame.size.height / 2;
                _popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContentViewController];
                
                [_popoverController presentPopoverFromRect:cellFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

        }
    }
}

-(void)replyEmailPressed:(BaseMailbox *)account
{
    [[self.splitViewController.viewControllers[1] topViewController] performSegueWithIdentifier: @"toComposeMessage" sender: self];
    [_popoverController dismissPopoverAnimated:YES];
}


- (IBAction)swipe:(id)sender
{
    UISwipeGestureRecognizer *swipe = sender;
    if (swipe.state == UIGestureRecognizerStateRecognized)
    {
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
        {
            [self back:nil];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
