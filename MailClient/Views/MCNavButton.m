//
//  MCNavButton.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MCNavButton.h"

@implementation MCNavButton

-(void)awakeFromNib
{
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               MCCOLOR_TITLE,UITextAttributeTextColor,
                                               MCCOLOR_TITLE_SHADOW, UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               MCFONT_TITLE, UITextAttributeFont, nil];
    
    
//    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Title" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
}

@end
