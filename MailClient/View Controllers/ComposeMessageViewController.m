//
//  ComposeMessageViewController.m
//  MailClient
//
//  Created by Barney on 8/4/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "ComposeMessageViewController.h"

@implementation ComposeMessageViewController
{
    NSMutableArray *_toRecipients;
	NSMutableArray *_ccRecipients;
    NSMutableString *_subject;
    NSMutableString *_messageBody;
	
	JSTokenField *_toField;
	JSTokenField *_ccField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_topBar setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]/*#fff9f4*/];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
	
	_toRecipients = [NSMutableArray array];
    _ccRecipients = [NSMutableArray array];
    _subject = [NSMutableString new];
    _messageBody = [NSMutableString new];
	
	_toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, 1040, 35)];
	[[_toField label] setText:@"To:"];
	[_toField setDelegate:self];
	[_bodyView addSubview:_toField];
    
    UIView *separator1 = [[UIView alloc] initWithFrame:CGRectMake(0, _toField.bounds.size.height-1, _toField.bounds.size.width, 1)];
    [separator1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toField addSubview:separator1];
    [separator1 setBackgroundColor:[UIColor lightGrayColor]];
	
	_ccField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 35, 1040, 35)];
	[[_ccField label] setText:@"CC:"];
	[_ccField setDelegate:self];
	[_bodyView addSubview:_ccField];
    
    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(0, _ccField.bounds.size.height-1, _ccField.bounds.size.width, 1)];
    [separator2 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_ccField addSubview:separator2];
    [separator2 setBackgroundColor:[UIColor lightGrayColor]];
    
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 70, 1040, 35)];
    textField.borderStyle = UITextBorderStyleNone;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    label.text = @" Subject:";
    [label setTextColor:MCCOLOR_TITLE];
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = label;
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    [_bodyView addSubview:textField];
    
    UIView *separator3 = [[UIView alloc] initWithFrame:CGRectMake(0, 105, 1040, 1)];
    [separator3 setBackgroundColor:[UIColor lightGrayColor]];
    [_bodyView addSubview:separator3];
    
    
    UITextView *textView= [[UITextView alloc] initWithFrame:CGRectMake(0, 106, 1040, 1000)];
    [textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
    textView.contentInset = UIEdgeInsetsMake(5,5,5,5);
    [_bodyView addSubview:textView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
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
    
}


#pragma mark -
#pragma mark JSTokenFieldDelegate


- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
	[_toRecipients addObject:recipient];
	NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, _toRecipients);
    
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
	[_toRecipients removeObjectAtIndex:index];
	NSLog(@"Deleted token %d\n%@", index, _toRecipients);
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length])
	{
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    
    return NO;
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
	if ([[note object] isEqual:_toField])
	{
		[UIView animateWithDuration:0.0
						 animations:^{
							 [_ccField setFrame:CGRectMake(0, [_toField frame].size.height + [_toField frame].origin.y, [_ccField frame].size.width, [_ccField frame].size.height)];
						 }
						 completion:nil];
	}
}


@end
