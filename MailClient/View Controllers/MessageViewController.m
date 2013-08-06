//
//  DetailViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MessageViewController.h"
#import "NSSet+Additions.h"
#import "NSString+Additions.h"
#import "ComposeMessageViewController.h"


@implementation MessageViewController
{
    UIActivityIndicatorView *_spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViews];
    
    [self hideBodyView];
}


-(void) initViews
{
    [_topBarView setBackgroundColor:BACKGROUND_COLOR];
    
    [self initSpinner];
}

-(void) initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.rootView.bounds.size.width / 2.0f, self.rootView.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.rootView addSubview:_spinner];
}


-(void) showSpinner
{
    [self hideBodyView];
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [self showBodyView];
    [_spinner stopAnimating];
}


-(void) setMessage:(CTCoreMessage *)message
{
    [self showSpinner];
    
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
    
    self.bodyTextView.attributedString = [[NSAttributedString alloc] initWithString:@""];
    
    dispatch_async([AppDelegate serialGlobalBackgroundQueue], ^{
        
        DLog(@"Attempt to fetch a message body.");
        
        BOOL isHTML = '\0';
        NSString *body = [message htmlBody];
        
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


-(void)showBodyView
{
    _bodyView.hidden = NO;
}

-(void)hideBodyView
{
    _bodyView.hidden = YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toComposeMessage"]){
        ComposeMessageViewController *composeMessageViewController = segue.destinationViewController;
       //
    }
}

@end
