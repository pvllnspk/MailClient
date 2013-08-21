//
//  DetailViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MessageViewController.h"
#import "NSString+Additions.h"
#import "ComposeMessageViewController.h"
#import "MCBarButtonItem.h"
#import "MailAttributesView.h"
#import "TimeExecutionTracker.h"
#import "TextUtils.h"
#import "BaseMailbox.h"
#import "TextUtils.h"

@interface MessageViewController() <UISplitViewControllerDelegate, DTAttributedTextContentViewDelegate>

@property (weak, nonatomic) IBOutlet MailAttributesView *messageHeaderView;
@property (weak, nonatomic) IBOutlet DTAttributedTextView *messageBodyView;

@end

@implementation MessageViewController
{
    UIActivityIndicatorView *_spinner;
    
    UIPopoverController *_popoverController;
    
    CTCoreMessage *_message;
    CTCoreFolder *_folder;
    BaseMailbox *_account;
}


- (void) setMessage:(CTCoreMessage *)message forFolder:(CTCoreFolder*) folder andAccount: (BaseMailbox*)account;
{
    [_messageHeaderView->subjectField setText:@""];
    
    if(message){
        
        if (_message != message) {
            _message = message;
            _folder = folder;
            _account = account;
            
            [self updateMessage];
        }
        
        if (_popoverController != nil) {
            [_popoverController dismissPopoverAnimated:YES];
        }
    }else{
        
        [self hideBody];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViews];
    
    [self hideBody];
    
    [self updateMessage];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem];
        #pragma clang diagnostic pop
    }
}

-(void) initViews
{
    [_messageHeaderView->fromField setUserInteractionEnabled:NO];
    [_messageHeaderView->toField setUserInteractionEnabled:NO];
    [_messageHeaderView->ccField setUserInteractionEnabled:NO];
    [_messageHeaderView->subjectField setUserInteractionEnabled:NO];
    
    _messageBodyView.contentInset = UIEdgeInsetsMake(10,10,10,10);
    
    [self initSpinner];
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


- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(MCBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Mailboxes", @"Mailboxes");
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               MCCOLOR_TITLE,UITextAttributeTextColor,
                                               MCCOLOR_TITLE_SHADOW, UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               MCFONT_TITLE, UITextAttributeFont, nil];
    [barButtonItem setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    _popoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(MCBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    _popoverController = nil;
}


-(void) showSpinner
{
    [self hideBody];
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [self showBody];
    [_spinner stopAnimating];
}


-(void) hideBody
{
    [self clearMessage];
    
    if(_messageHeaderView)
        [_messageHeaderView setHidden:YES];
    
    if(_messageBodyView)
        [_messageBodyView setHidden:YES];
}

-(void) showBody
{
    if(_messageHeaderView)
        [_messageHeaderView setHidden:NO];
    
    if(_messageBodyView)
        [_messageBodyView setHidden:NO];
}


-(void)clearMessage
{    
    [_messageHeaderView->fromField removeAllTokens];
    [_messageHeaderView->toField removeAllTokens];
    [_messageHeaderView->ccField removeAllTokens];
    [_messageHeaderView->subjectField setText:@""];
    
    _messageBodyView.attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
}


-(void) updateMessage
{    
    if(_message){
        
        [self showSpinner];
        
        [self updateMessageHeader];


        dispatch_async([AppDelegate serialBackgroundQueue], ^{
            
            DLog(@"Attempt to fetch a message body.");
            
            CTCoreFolder *folder = [_account folderWithPath:_folder.path];
            CTCoreMessage *message = [folder messageWithUID:[_message uid]];
            
            NSString *body = [message htmlBody];
            
            NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica"};
            NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                                       options:builderOptions
                                                                                            documentAttributes:nil];
            NSAttributedString *attrString = [stringBuilder generatedAttributedString];
            
            if([TextUtils isEmpty:[attrString string]]){
                attrString = [[NSAttributedString alloc] initWithString:[TextUtils isEmpty:message.body replaceWith:@""]];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DLog(@"Success.");
                
                _messageBodyView.attributedString = attrString;
                _messageBodyView.contentInset = UIEdgeInsetsMake(20, 15, 15, 15);
                _messageBodyView.textDelegate = self;
                
                [self hideSpinner];
            });
        });
    }
}

-(void) updateMessageHeader
{
    NSArray *fromArray = [_message.from allObjects];
    for(NSString *fromObj in fromArray){
        [_messageHeaderView->fromField addTokenWithTitle:[NSString stringWithFormat:@"%@",fromObj] representedObject:[NSString stringWithFormat:@"%@",fromObj]];
    }
    
    NSArray *toArray = [_message.to allObjects];
    for(NSString *toObj in toArray){
        [_messageHeaderView->toField addTokenWithTitle:[NSString stringWithFormat:@"%@",toObj] representedObject:[NSString stringWithFormat:@"%@",toObj]];
    }
    
    NSArray *ccArray = [_message.cc allObjects];
    for(NSString *ccObj in ccArray){
        [_messageHeaderView->ccField addTokenWithTitle:[NSString stringWithFormat:@"%@",ccObj] representedObject:[NSString stringWithFormat:@"%@",ccObj]];
    }
    
    [_messageHeaderView->subjectField setText:_message.subject];
}


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

- (IBAction)linkButtonClicked:(DTLinkButton *)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toComposeMessage"]){
        
        ComposeMessageViewController *composeMessageViewController = segue.destinationViewController;
        [composeMessageViewController setSender:_account.emailAddress];
    }
}

-(void)dealloc
{
    _messageHeaderView = nil;
    _messageBodyView = nil;
    _spinner = nil;
    _popoverController = nil;
    _message = nil;
    _folder = nil;
    _account = nil;
}


@end
