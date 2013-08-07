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

@implementation MessagesViewController
{
    CTCoreFolder *_folder;
    
    NSMutableArray *_messages;
    NSMutableArray *_searchResults;
    
    UIActivityIndicatorView *_spinner;
    
    UIRefreshControl *_refreshControl;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViews];
}


-(void) initViews
{    
    [self initSeacrhBar];
    [self initRefreshControl];
    [self initSpinner];
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
    _spinner.center = CGPointMake(_tableView.bounds.size.width / 2.0f, _tableView.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [_tableView addSubview:_spinner];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CTCoreMessage *message = [_searchResults objectAtIndex:indexPath.row];
    UILabel *fromLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *subjectLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:104];
    [subjectLabel setText:message.subject];
    [fromLabel setText:[message.from toStringSeparatingByComma]];
    [dateLabel setText:[NSDateFormatter localizedStringFromDate:message.senderDate
                                                      dateStyle:NSDateFormatterShortStyle
                                                      timeStyle:nil]];
    BOOL isHTML;
    NSString *shortBody = [message bodyPreferringPlainText:&isHTML];
    shortBody = [shortBody substringToIndex: MIN(100, [shortBody length])];
    [descriptionLabel setText:shortBody];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self setMessage:[_searchResults objectAtIndex:indexPath.row]];
}


-(void)setFolder:(CTCoreFolder *)folder
{
    if (_folder != folder){
        
        _folder = folder;
        [self updateMessages];
    }
}

- (void)updateMessages
{
    if (_folder) {
        
        [self showSpinner];
        
        dispatch_async([AppDelegate serialBackgroundQueue], ^{
            
            DLog(@"Attempt to fetch messages from folder %@ .",[_folder path]);
            
            _messages = [NSMutableArray arrayWithArray:[_folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope]];
            _searchResults = [_messages mutableCopy];
            
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
    [_messages removeAllObjects];
    [_tableView reloadData];
    
    [_spinner startAnimating];
}

-(void) hideSpinner
{
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
    
    [_tableView reloadData];
}


- (IBAction)returnToMailboxes:(id)sender
{
    DLog(@"returnToMailboxes");
    
    if(_delegate)
        [_delegate closeChildController];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toComposeMessage"]){
        // segue.destinationViewController;
    }
}


@end
