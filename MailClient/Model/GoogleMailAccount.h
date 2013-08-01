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

@property(nonatomic, retain) NSError *connectionError;

-(id)initWithFullName:(NSString*)fullName emailAddress:(NSString*)emailAddress password:(NSString*)password;
-(BOOL) connect;
-(NSArray*)subscribedFolders;

@end
