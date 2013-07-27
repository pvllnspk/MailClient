//
//  NSString+Additions.m
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

-(BOOL) contains:(NSString*) substring
{
    return ([self rangeOfString:substring].location != NSNotFound);
}

@end
