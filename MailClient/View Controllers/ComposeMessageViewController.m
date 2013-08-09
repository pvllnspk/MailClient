//
//  ComposeMessageViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "ComposeMessageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Additions.h"
#import "TimeExecutionTracker.h"
#import "MailAttributesView.h"


@implementation ComposeMessageViewController
{
    NSMutableArray *_toRecipients;
	NSMutableArray *_ccRecipients;
	
    MailAttributesView *_mailAttributesView;
    UITextView *_messageBodyView;
    
    UIActivityIndicatorView *_spinner;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self initViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
}


-(void)initData
{
    _toRecipients = [NSMutableArray array];
    _ccRecipients = [NSMutableArray array];
    
    _messageBodyView.text = @"";
}

-(void) initViews
{
    _mailAttributesView = [[MailAttributesView alloc]initWithFrame:self.view.frame];
    _mailAttributesView.delegate = self;
    [self.view addSubview:_mailAttributesView];
    
    _messageBodyView= [[UITextView alloc] initWithFrame:CGRectMake(0, _mailAttributesView.frame.size.height, self.view.frame.size.width, 1000)];
    
    [_messageBodyView setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    _messageBodyView.contentInset = UIEdgeInsetsMake(5,5,5,5);
    [self.view addSubview:_messageBodyView];
    
    [self initSpinner];
}

-(void) initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width * 3.0f / 5.0f, 34.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}


-(void) showSpinner
{
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    [_spinner stopAnimating];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendMessage:(id)sender
{
    
    NSMutableSet *toRecipients = [NSMutableSet set];
    NSMutableSet *ccRecipients = [NSMutableSet set];
    
    for(NSDictionary *recipient in _toRecipients){
        [toRecipients addObject:[CTCoreAddress addressWithName:[recipient valueForKey:@"email"] email:[recipient valueForKey:@"email"]]];
    }
    
    for(NSDictionary *recipient in _ccRecipients){
        [ccRecipients addObject:[CTCoreAddress addressWithName:[recipient valueForKey:@"email"] email:[recipient valueForKey:@"email"]]];
    }
    
    
    if([toRecipients count] == 0){
        
        [self sendingEmailFailed];
        return;
    }
    
    [self showSpinner];
    
    dispatch_async([AppDelegate serialBackgroundQueue], ^{
        
        DLog(@"attempt to send an email");
        [TimeExecutionTracker startTrackingWithName:@"sending an email"];
        
        CTCoreMessage *msg = [[CTCoreMessage alloc] init];
        
        [msg setTo:toRecipients];
        [msg setCc:ccRecipients];
        [msg setSubject:_mailAttributesView->subjectField.text];
        [msg setBody:_messageBodyView.text];
        
        NSError *error;
        BOOL success = [CTSMTPConnection sendMessage:msg
                                              server:@"smtp.gmail.com"
                                            username:@"iosmailclienttest@gmail.com"
                                            password:@"testiosmailclienttest"
                                                port:587
                                      connectionType:CTSMTPConnectionTypeStartTLS
                                             useAuth:YES
                                               error:&error];
        
        
        [TimeExecutionTracker stopTrackingAndPrint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            
            if (success){
                
                DLog(@"Succes...");
                [self sendingEmailSuccessed];
            }
            else{
                
                DLog(@"Failed...");
                [self sendingEmailFailed];
            }
        });
    });
}

-(void)sendingEmailSuccessed
{
    [self cancel:nil];
}

-(void)sendingEmailFailed
{
    CABasicAnimation *movingAnimation =[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [movingAnimation setDuration:0.2];
    [movingAnimation setRepeatCount:1];
    [movingAnimation setAutoreverses:YES];
    [movingAnimation setFromValue:[NSNumber numberWithFloat:-5]];
    [movingAnimation setToValue:[NSNumber numberWithFloat:5]];
    [self.view.layer addAnimation:movingAnimation forKey:@"animateLayer"];
}


- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	NSDictionary *recipient = [NSDictionary dictionaryWithObject:title forKey:@"email"];
    
    if(tokenField==_mailAttributesView->toField){
     	[_toRecipients addObject:recipient];
    }else if(tokenField==_mailAttributesView->ccField){
        [_ccRecipients addObject:recipient];
    }
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj
{
    NSDictionary *recipient = [NSDictionary dictionaryWithObject:title forKey:@"email"];
    
    if(tokenField==_mailAttributesView->toField){
     	[_toRecipients removeObject:recipient];
    }else if(tokenField==_mailAttributesView->ccField){
        [_ccRecipients removeObject:recipient];
    }
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++){
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]]){
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length]){
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    
    return NO;
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
    if ([[note object] isEqual:_mailAttributesView->toField]){
		[UIView animateWithDuration:0.0
						 animations:^{
							 [_mailAttributesView->ccField setFrame:CGRectMake(0,
                                                                               [_mailAttributesView->toField frame].size.height + [_mailAttributesView->toField frame].origin.y,
                                                                               [_mailAttributesView->ccField frame].size.width, [_mailAttributesView->ccField frame].size.height)];
						 }
						 completion:nil];
	}
}


@end
