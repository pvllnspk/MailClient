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

@synthesize fullName,emailAddress,password;

-(BOOL)connect
{
    CTCoreAccount *account = [[CTCoreAccount alloc] init];
    BOOL success = [account connectToServer:INCOMING_SERVER_REMOTE_FOLDERS
                                       port:INCOMING_PORT
                             connectionType:INCOMING_CONNECTION_TYPE
                                   authType:INCOMING_AUTH_TYPE
                                      login:emailAddress
                                   password:password];
    return success;
}

@end
