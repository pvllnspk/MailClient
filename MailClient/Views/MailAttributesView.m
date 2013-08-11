//
//  MailAttributesView.m
//  MailClient
//
//  Created by Barney on 8/8/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MailAttributesView.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "JSTokenField.h"

#define ROW_HEIGHT 35
#define ROW_WIDTH 780
#define MESSAGE_BODY_PADDING 5

@implementation MailAttributesView
{
    UIView *_selectionView;
}

-(id)initWithTopPadding:(CGFloat)topPadding
{
    CGRect frameRect = CGRectMake(0, topPadding , ROW_WIDTH, 4 * ROW_HEIGHT + topPadding + MESSAGE_BODY_PADDING);
    self = [super initWithFrame:frameRect];
    if (self) {
        
        [self initView];
    }
    return self;
}


-(void)initView
{
    CGRect sectionSize = CGRectMake(0, 0 , 800, ROW_HEIGHT * 4);
    _selectionView = [[UIView alloc] initWithFrame:sectionSize];
    [_selectionView setBackgroundColor:[UIColor clearColor]];
    
    fromField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT)];
	[[fromField label] setText:@"From:"];
	[fromField setDelegate:self];
	[_selectionView addSubview:fromField];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, fromField.bounds.size.height-1, fromField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [fromField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
	
	toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT)];
	[[toField label] setText:@"To:"];
	[toField setDelegate:self];
	[_selectionView addSubview:toField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, toField.bounds.size.height-1, toField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [toField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
	
	ccField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 2 * ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT)];
	[[ccField label] setText:@"CC:"];
	[ccField setDelegate:self];
	[_selectionView addSubview:ccField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, ccField.bounds.size.height-1, ccField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [ccField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
    
    subjectField = [[UITextField alloc] initWithFrame:CGRectMake(0, 3 * ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT)];
    subjectField.borderStyle = UITextBorderStyleNone;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2 * ROW_HEIGHT, 40)];
    label.text = @" Subject:";
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    [label setTextColor:TEXT_COLOR_PRIMARY];
    subjectField.leftViewMode = UITextFieldViewModeAlways;
    subjectField.leftView = label;
    [subjectField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_selectionView addSubview:subjectField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 4 * ROW_HEIGHT, ROW_WIDTH, 1)];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
    [_selectionView addSubview:separator];
    
    [self addSubview:_selectionView];
    
}

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
    [_delegate tokenField:tokenField didAddToken:title representedObject:obj];
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj
{
    [_delegate tokenField:tokenField didRemoveToken:title representedObject:obj];
}

-(BOOL)tokenField:(JSTokenField *)tokenField shouldRemoveToken:(NSString *)title representedObject:(id)obj
{
    return [_delegate tokenField:tokenField shouldRemoveToken:title representedObject:obj];
}


@end
