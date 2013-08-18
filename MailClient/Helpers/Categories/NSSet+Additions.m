//
//  NSSet+Additions.m
//  MailClient
//
//  Created by Barney on 7/26/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "NSSet+Additions.h"

@implementation NSSet (Additions)

- (NSString *)toStringSeparatingByComma
{
    return [[self allObjects] componentsJoinedByString:@", "];
}

@end
