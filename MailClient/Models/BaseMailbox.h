//
//  BaseMailbox.h
//  MailClient
//
//  Created by Barney on 8/12/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseMailbox : NSObject

@property(nonatomic,copy) NSString *fullName;
@property(nonatomic,copy) NSString *emailAddress;
@property(nonatomic,copy) NSString *password;

@property(nonatomic, retain) NSError *connectionError;

- (id) initWithFullName:(NSString*)fullName emailAddress:(NSString*)emailAddress password:(NSString*)password;
- (BOOL) connect;
- (NSArray*) subscribedFolders;
- (CTCoreFolder*) folderWithPath:(NSString *)path;

- (BOOL) connectToAccount:(CTCoreAccount*)account;

@end
