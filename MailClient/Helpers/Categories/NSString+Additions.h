//
//  NSString+Additions.h
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL) contains:(NSString*) substring;
- (NSString *) md5;
- (BOOL) endsWith:(NSString*)string;

@end
