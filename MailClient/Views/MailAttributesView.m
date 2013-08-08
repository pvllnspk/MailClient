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
#define NAVIGATION_BAR_HEIGHT 22

@implementation MailAttributesView
{
    UIView *_selectionView;
    CGFloat *_selectionViewWidth;
    
    JSTokenField *_fromField;
	JSTokenField *_toField;
	JSTokenField *_ccField;
    UITextField *_subjectField;
    UITextView *_messageBodyView;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectionViewWidth = &frame.size.width;
        
        [self initView];
    }
    return self;
}

-(void)initView
{
    static CGRect sectionSize;
    sectionSize = CGRectMake(0, NAVIGATION_BAR_HEIGHT , *(_selectionViewWidth), ROW_HEIGHT * 4);
    _selectionView = [[UIView alloc] initWithFrame:sectionSize];
    [_selectionView setBackgroundColor:[UIColor clearColor]];
    
    _fromField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, *(_selectionViewWidth), ROW_HEIGHT)];
	[[_fromField label] setText:@"From:"];
	[_fromField setDelegate:self];
	[_selectionView addSubview:_fromField];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, _fromField.bounds.size.height-1, _fromField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_fromField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
	
	_toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, ROW_HEIGHT, *(_selectionViewWidth), ROW_HEIGHT)];
	[[_toField label] setText:@"To:"];
	[_toField setDelegate:self];
	[_selectionView addSubview:_toField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, _toField.bounds.size.height-1, _toField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
	
	_ccField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 2 * ROW_HEIGHT, *(_selectionViewWidth), ROW_HEIGHT)];
	[[_ccField label] setText:@"CC:"];
	[_ccField setDelegate:self];
	[_selectionView addSubview:_ccField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, _ccField.bounds.size.height-1, _ccField.bounds.size.width, 1)];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_ccField addSubview:separator];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
    
    _subjectField = [[UITextField alloc] initWithFrame:CGRectMake(0, 3 * ROW_HEIGHT, *(_selectionViewWidth), ROW_HEIGHT)];
    _subjectField.borderStyle = UITextBorderStyleNone;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2 * ROW_HEIGHT, 40)];
    label.text = @" Subject:";
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    [label setTextColor:TEXT_COLOR_PRIMARY];
    _subjectField.leftViewMode = UITextFieldViewModeAlways;
    _subjectField.leftView = label;
    [_subjectField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_selectionView addSubview:_subjectField];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 4 * ROW_HEIGHT, *(_selectionViewWidth), 1)];
    [separator setBackgroundColor:[UIColor lightGrayColor]];
    [_selectionView addSubview:separator];
    
    [self addSubview:_selectionView];
    
}

@end
