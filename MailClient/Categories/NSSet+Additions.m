//
//  NSSet+Additions.m
//  MailClient
//
//  Created by Barney on 7/26/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "NSSet+Additions.h"

@implementation NSSet (Additions)

-(NSString *)toStringSeparatingByComma
{
    NSMutableString *resultString = [NSMutableString new];
    NSEnumerator *enumerator = [self objectEnumerator];
    NSString* value;
    while ((value = [enumerator nextObject])) {
        [resultString appendFormat:[NSString stringWithFormat:@" %@ ,",value]];
    }
    
    NSRange lastComma = [resultString rangeOfString:@"," options:NSBackwardsSearch];
    if(lastComma.location != NSNotFound) {
        resultString = [resultString stringByReplacingCharactersInRange:lastComma
                                                             withString: @""];
    }
    return resultString;
}

@end
