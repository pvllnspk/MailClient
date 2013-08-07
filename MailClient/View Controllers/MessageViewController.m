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


@implementation MessageViewController
{
    UIActivityIndicatorView *_spinner;
    
    UIPopoverController *_popoverController;
    
    CTCoreMessage *_message;
}

@synthesize mailboxesBtn;

-(void) setMessage:(CTCoreMessage *)message
{
    if (_message != message) {
        _message = message;
        
        [self updateMessage];
    }

    if (_popoverController != nil) {
        [_popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViews];
    
    [self updateMessage];
}


-(void) initViews
{    
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


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(MCNavButton *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               MCCOLOR_TITLE,UITextAttributeTextColor,
                                               MCCOLOR_TITLE_SHADOW, UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               MCFONT_TITLE, UITextAttributeFont, nil];
    
    
    //    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Title" style:UIBarButtonItemStyleBordered target:nil action:nil];
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
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [_spinner stopAnimating];
}


-(void) updateMessage
{
    if(_message){
        
        [self showSpinner];
        
        
        NSString *body = [_message htmlBody];
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica"};
        DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                                   options:builderOptions
                                                                                        documentAttributes:nil];
        
        self.bodyTextView.attributedString = [[NSAttributedString alloc] initWithString:@""];
        
        dispatch_async([AppDelegate serialBackgroundQueue], ^{
            
            DLog(@"Attempt to fetch a message body.");
            
            BOOL isHTML = '\0';
            NSString *body = [_message htmlBody];
            
            NSData *emtyData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
            DTHTMLAttributedStringBuilder *emptyStringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data
                                                                                                            options:builderOptions
                                                                                                 documentAttributes:nil];
            self.bodyTextView.attributedString = [emptyStringBuilder generatedAttributedString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DLog(@"Success. Is HTML ? : %s",isHTML? "true" : "false");
                
                self.bodyTextView.attributedString = [stringBuilder generatedAttributedString];
                self.bodyTextView.contentInset = UIEdgeInsetsMake(20, 15, 15, 15);
                self.bodyTextView.textDelegate = self;
                
                [self hideSpinner];
            });
        });
    }
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
