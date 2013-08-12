//
//  TextUtils.m
//  MailClient
//
//  Created by Barney on 8/10/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "TextUtils.h"

@implementation TextUtils

+ (BOOL)isEmpty:(NSString*) string {
    
    if([string length] == 0 || ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)isEmpty:(NSString*)string replaceWith:(NSString*)replaceString
{
    if([self isEmpty:string])
        return replaceString;
    
    return string;
}

@end
