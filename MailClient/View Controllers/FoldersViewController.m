//
//  DetailViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "FoldersViewController.h"
#import "NSSet+Additions.h"
#import "NSString+Additions.h"


#if 1 // Set to 1 to enable DetailViewController Logging
#define DVCLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define DVCLog(x, ...)
#endif

@interface FoldersViewController()

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//Left Panel
@property (weak, nonatomic) IBOutlet UITableView *messagesTableView;

//Right Panel
@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet DTAttributedTextView *bodyTextView;

@end;

@implementation FoldersViewController
{
    CTCoreFolder *_folder;
   
    NSMutableArray *_messages;
    NSMutableArray *_searchResults;
    
    UIActivityIndicatorView *_messagesSpinner;
    UIActivityIndicatorView *_messageSpinner;
    
    UIRefreshControl *_refreshControl;
    
    dispatch_queue_t _backgroundQueue;
}

-(void)setFolder:(CTCoreFolder *)folder
{
    DVCLog(@"setFolder %@",folder);
    
    if (_folder != folder){
        _folder = folder;
        
        [self updateMessages];
    }
}

- (void)updateMessages
{
    DVCLog(@"updateMessages %@",[_folder path]);
    
    if (_folder) {
        
        [_messages removeAllObjects];
        [self.messagesTableView reloadData];
        [self showMessagesSpinner];
        
        dispatch_async(_backgroundQueue, ^{
            
            DLog(@"attempt to fetch messages from folder %@",[_folder path]);
            _messages = [_folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
            _searchResults = [_messages mutableCopy];
                       
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DLog(@"Success %d",[_messages count]);
                
                [self hideMessagesSpinner];
                [self.messagesTableView reloadData];
                
            });
        });
        
        [_messagesTableView reloadData];
        
        //restore tableview scroll
//        [_messagesTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        [_refreshControl endRefreshing];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DVCLog(@"viewDidLoad");
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [_refreshControl addTarget:self action:@selector(updateMessages) forControlEvents:UIControlEventValueChanged];
    [_messagesTableView addSubview:_refreshControl];
    
    
    for (UIView *subview in _searchBar.subviews){
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            [subview removeFromSuperview];
            break;
        }
    }
    [_searchBar setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
    
    
    [_topBarView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
    
//    [_messagesTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//	[_messagesTableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
//	[_messagesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _backgroundQueue = dispatch_queue_create("dispatch_queue_#2", 0);
    
    [self initMessagesSpinner];
    [self initMessageSpinner];
    
    [self updateMessages];
    
    [self hideBodyView];
}


#pragma mark
#pragma mark Left Panel Table View

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
        //        cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"copymove-cell-bg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
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
    
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"copymove-cell-bg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setMessage:[_searchResults objectAtIndex:indexPath.row]];
}

#pragma mark
#pragma mark Panels Spinners

-(void) initMessagesSpinner
{
    DVCLog(@"initMessagesSpinner");
    _messagesSpinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _messagesSpinner.center = CGPointMake(self.messagesTableView.bounds.size.width / 2.0f, self.messagesTableView.bounds.size.height / 2.0f);
    _messagesSpinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _messagesSpinner.hidesWhenStopped = YES;
    [_messagesSpinner setColor:[UIColor grayColor]];
    [self.messagesTableView addSubview:_messagesSpinner];
}

-(void) showMessagesSpinner
{
    DVCLog(@"showMessagesSpinner");
    [_messagesSpinner startAnimating];
}

-(void) hideMessagesSpinner
{
    DVCLog(@"hideMessagesSpinner");
    [_messagesSpinner stopAnimating];
}

-(void) initMessageSpinner
{
    DVCLog(@"initMessagesSpinner");
    _messageSpinner = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _messageSpinner.center = CGPointMake(self.rootView.bounds.size.width / 2.0f, self.rootView.bounds.size.height / 2.0f);
    _messageSpinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                         | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _messageSpinner.hidesWhenStopped = YES;
    [_messageSpinner setColor:[UIColor grayColor]];
    [self.rootView addSubview:_messageSpinner];
}

-(void) showMessageSpinner
{
    self.bodyView.hidden = YES;
    DVCLog(@"showMessagesSpinner");
    [_messageSpinner startAnimating];
}

-(void) hideMessageSpinner
{
    self.bodyView.hidden = NO;
    DVCLog(@"hideMessagesSpinner");
    [_messageSpinner stopAnimating];
}

#pragma mark
#pragma mark Misc

-(void) setMessage:(CTCoreMessage *)message
{
    DVCLog(@"setMessage: %@",message.subject);
    
    [self showMessageSpinner];
    [self.subjectLabel setText:message.subject];
    [self.fromLabel setText:[message.from toStringSeparatingByComma]];
    [self.toLabel setText:[message.to toStringSeparatingByComma]];
    [self.dateLabel setText:[NSDateFormatter localizedStringFromDate:message.senderDate
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterFullStyle]];
    
    NSString *body = [message htmlBody];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica"};
    DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                               options:builderOptions
                                                                                    documentAttributes:nil];
    self.bodyTextView.attributedString = @"";
    
    dispatch_async(_backgroundQueue, ^{
        
        DLog(@"attempt to fetch a message body");
        BOOL isHTML = '\0';
        NSString *body = [message htmlBody];
        
        NSData *emtyData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        DTHTMLAttributedStringBuilder *emptyStringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                                   options:builderOptions
                                                                                        documentAttributes:nil];
        self.bodyTextView.attributedString = [emptyStringBuilder generatedAttributedString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"Success isHTML: %s",isHTML? "true" : "false");
            
            self.bodyTextView.attributedString = [stringBuilder generatedAttributedString];
            self.bodyTextView.contentInset = UIEdgeInsetsMake(20, 15, 15, 15);
            self.bodyTextView.textDelegate = self;
            
            [self hideMessageSpinner];
            [self hideMessagesSpinner];
            [self.messagesTableView reloadData];
            
        });
    });
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                          viewForLink:(NSURL *)url
                           identifier:(NSString *)identifier
                                frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self
                   action:@selector(linkButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;
}

#pragma mark - Events

- (IBAction)linkButtonClicked:(DTLinkButton *)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}


-(void)showBodyView
{
    DVCLog(@"showBodyView");
    _bodyView.hidden = NO;
}

-(void)hideBodyView
{
    DVCLog(@"hideBodyView");
    _bodyView.hidden = YES;
}


#pragma mark
#pragma mark UISearchDisplayController Delegate Methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchResults removeAllObjects];
    
    if(searchText && searchText.length>0){
        for(CTCoreMessage *message in _messages){
            if([message.subject contains:searchText]){
                [_searchResults addObject:message];
            }
        }
    }else{
        [_searchResults addObjectsFromArray:_messages];
    }
    
    DVCLog(@"filterContentForSearchText %@  -  %d", searchText,[_searchResults count]);
    [_messagesTableView reloadData];
}




@end
