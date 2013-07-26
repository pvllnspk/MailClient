//
//  DetailViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "DetailViewController.h"
#import "NSSet+Additions.h"

#if 1 // Set to 1 to enable DetailViewController Logging
#define DVCLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define DVCLog(x, ...)
#endif

@interface DetailViewController()

//Left Panel
@property (weak, nonatomic) IBOutlet UITableView *messagesTableView;

//Right Panel
@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyLabel;

@end;

@implementation DetailViewController
{
    CTCoreFolder *_folder;
    NSArray *_messages;
    UIActivityIndicatorView *_messagesSpinner;
    
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
        
        [self showMessagesSpinner];
        
        dispatch_async(_backgroundQueue, ^{
            
            DLog(@"attempt to fetch messages from folder %@",[_folder path]);
            _messages = [_folder messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
                       
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DLog(@"Success %d",[_messages count]);
                DLog(@"Messages %@",_messages);
                
                [self hideMessagesSpinner];
                [self.messagesTableView reloadData];
                
            });
        });
        
        [self.messagesTableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DVCLog(@"viewDidLoad");
    
    _backgroundQueue = dispatch_queue_create("dispatch_queue_#2", 0);
    
    [self initMessagesSpinner];
    
    [self updateMessages];
    
    [self hideBodyView];
}


#pragma mark
#pragma mark Left Panel Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return[_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CTCoreMessage *message = [_messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message subject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setMessage:[_messages objectAtIndex:indexPath.row]];
}

#pragma mark
#pragma mark Left Panel Spinner

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


#pragma mark
#pragma mark Misc

-(void) setMessage:(CTCoreMessage *)message
{
    DVCLog(@"setMessage: %@",message.subject);
    
    [self showBodyView];
    [self.subjectLabel setText:message.subject];
    [self.fromLabel setText:[message.from toStringSeparatingByComma]];
    [self.toLabel setText:[message.to toStringSeparatingByComma]];
    [self.dateLabel setText:[NSDateFormatter localizedStringFromDate:message.senderDate
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterFullStyle]];
    [self.bodyLabel setText:@"Loading ..."];
    
    dispatch_async(_backgroundQueue, ^{
        
        DLog(@"attempt to fetch a message body");
        BOOL isHTML;
//        NSString *body = [message bodyPreferringPlainText:&isHTML];
        NSString *body = [message htmlBody];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"Success %d",[_messages count]);
            [self.bodyLabel setText:body];
            
            [self hideMessagesSpinner];
            [self.messagesTableView reloadData];
            
        });
    });
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

@end
