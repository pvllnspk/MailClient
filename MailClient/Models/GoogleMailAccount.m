//
//  GoogleMailAccount.m
//  MailClient
//
//  Created by Barney on 8/1/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "GoogleMailAccount.h"

#define INCOMING_SERVER_REMOTE_FOLDERS @"imap.gmail.com"
#define INCOMING_PORT 993
#define INCOMING_CONNECTION_TYPE CTConnectionTypeTLS
#define INCOMING_AUTH_TYPE CTImapAuthTypePlain

#define OUTGOING_SERVER @"smtp.gmail.com"
#define OUTGOING_PORT 587
#define OUTGOING_CONNECTION_TYPE CTSMTPConnectionTypeStartTLS

@implementation GoogleMailAccount
{
    CTCoreAccount *_account;
}

-(id)initWithFullName:(NSString *)fullName emailAddress:(NSString *)emailAddress password:(NSString *)password
{
    if(self = [super init]){
        _fullName = fullName;
        _emailAddress = emailAddress;
        _password = password;
    }
    return(self);
}

-(BOOL)connect
{
    _account = [[CTCoreAccount alloc] init];
    BOOL success = [_account connectToServer:INCOMING_SERVER_REMOTE_FOLDERS
                                       port:INCOMING_PORT
                             connectionType:INCOMING_CONNECTION_TYPE
                                   authType:INCOMING_AUTH_TYPE
                                      login:_emailAddress
                                   password:_password];
    
    _connectionError = _account.lastError;
    
    return success;
}

-(NSArray*)subscribedFolders
{
    NSSet *subFolders = [_account subscribedFolders];
    return [subFolders allObjects];
}

- (CTCoreFolder *)folderWithPath:(NSString *)path
{
    return [[CTCoreFolder alloc] initWithPath:path inAccount:_account];
}

@end
