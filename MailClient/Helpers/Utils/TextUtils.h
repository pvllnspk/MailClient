//
//  TextUtils.h
//  MailClient
//
//  Created by Barney on 8/10/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextUtils : NSObject

+ (BOOL)isEmpty:(NSString*) string;
+ (NSString *)isEmpty:(NSString*)string replaceWith:(NSString*)replaceString;

@end
