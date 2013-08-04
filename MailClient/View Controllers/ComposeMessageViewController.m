//
//  ComposeMessageViewController.m
//  MailClient
//
//  Created by Barney on 8/4/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "ComposeMessageViewController.h"

@implementation ComposeMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [_topBar setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]/*#fff9f4*/];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendMessage:(id)sender
{
    
}

@end
