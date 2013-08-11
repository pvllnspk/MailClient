//
//  DetailViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MessageViewController.h"
#import "NSSet+Additions.h"
#import "NSString+Additions.h"
#import "ComposeMessageViewController.h"
#import "MCNavButton.h"
#import "MailAttributesView.h"
#import "TimeExecutionTracker.h"


@implementation MessageViewController
{
    UIActivityIndicatorView *_spinner;
    
    UIPopoverController *_popoverController;
    
    CTCoreMessage *_message;
    
    MailAttributesView *_mailAttributesView;
    DTAttributedTextView *_messageBodyView;
}


-(void) setMessage:(CTCoreMessage *)message
{
    if(message){
        
        if (_message != message) {
            _message = message;
            
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
    _mailAttributesView = [[MailAttributesView alloc]initWithTopPadding:0];
    [self.view addSubview:_mailAttributesView];
    
    [_mailAttributesView->fromField setUserInteractionEnabled:NO];
    [_mailAttributesView->toField setUserInteractionEnabled:NO];
    [_mailAttributesView->ccField setUserInteractionEnabled:NO];
    [_mailAttributesView->subjectField setUserInteractionEnabled:NO];
    
    _messageBodyView= [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, _mailAttributesView.frame.size.height, self.view.frame.size.width, 1000)];
    _messageBodyView.contentInset = UIEdgeInsetsMake(5,5,5,5);
    [self.view addSubview:_messageBodyView];
    
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


- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(MCNavButton *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
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

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(MCNavButton *)barButtonItem
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
    
    if(_mailAttributesView)
        [_mailAttributesView setHidden:YES];
    
    if(_messageBodyView)
        [_messageBodyView setHidden:YES];
}

-(void) showBody
{
    if(_mailAttributesView)
        [_mailAttributesView setHidden:NO];
    
    if(_messageBodyView)
        [_messageBodyView setHidden:NO];
}


-(void)clearMessage
{    
    [_mailAttributesView->fromField removeAllTokens];
    [_mailAttributesView->toField removeAllTokens];
    [_mailAttributesView->ccField removeAllTokens];
    [_mailAttributesView->subjectField setText:@""];
    
    _messageBodyView.attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
}


-(void) updateMessage
{    
    if(_message){
        
        [self showSpinner];
        
        [self updateMessageHeader];


        dispatch_async([AppDelegate serialBackgroundQueue], ^{
            
            DLog(@"Attempt to fetch a message body.");
            
            BOOL isHTML = '\0';
            NSString *body = [_message htmlBody];
            
            
            DLog(@"body  [[  %@  ]]",body);
            
            
            NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica"};
            
            NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                                       options:builderOptions
                                                                                            documentAttributes:nil];
            NSAttributedString *attrString = [stringBuilder generatedAttributedString];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DLog(@"Success. Is HTML ? : %s",isHTML? "true" : "false");
                DLog(@"Success. [ %@ ]",attrString);
                
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
        [_mailAttributesView->fromField addTokenWithTitle:[NSString stringWithFormat:@"%@",fromObj] representedObject:[NSString stringWithFormat:@"%@",fromObj]];
    }
    
    NSArray *toArray = [_message.to allObjects];
    for(NSString *toObj in toArray){
        [_mailAttributesView->toField addTokenWithTitle:[NSString stringWithFormat:@"%@",toObj] representedObject:[NSString stringWithFormat:@"%@",toObj]];
    }
    
    NSArray *ccArray = [_message.cc allObjects];
    for(NSString *ccObj in ccArray){
        [_mailAttributesView->ccField addTokenWithTitle:[NSString stringWithFormat:@"%@",ccObj] representedObject:[NSString stringWithFormat:@"%@",ccObj]];
    }
    
    [_mailAttributesView->subjectField setText:_message.subject];
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
        //
    }
}


@end
