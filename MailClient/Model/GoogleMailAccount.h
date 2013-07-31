//
//  GoogleMailAccount.h
//  MailClient
//
//  Created by Barney on 8/1/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleMailAccount : NSObject

@property(nonatomic,copy) NSString *fullName;
@property(nonatomic,copy) NSString *emailAddress;
@property(nonatomic,copy) NSString *password;

//sync
-(BOOL) connect;

@end
