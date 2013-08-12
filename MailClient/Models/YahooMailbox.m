//
//  YahooMailbox.m
//  MailClient
//
//  Created by Barney on 8/12/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "YahooMailbox.h"

#define INCOMING_SERVER_REMOTE_FOLDERS @"imap.mail.yahoo.com"
#define INCOMING_PORT 993
#define INCOMING_CONNECTION_TYPE CTConnectionTypeTLS
#define INCOMING_AUTH_TYPE CTImapAuthTypePlain

#define OUTGOING_SERVER @"smtp.mail.yahoo.com"
#define OUTGOING_PORT 465
#define OUTGOING_CONNECTION_TYPE CTSMTPConnectionTypeTLS

@implementation YahooMailbox

-(BOOL)connectToAccount:(CTCoreAccount *)account
{
    BOOL success = [account connectToServer:INCOMING_SERVER_REMOTE_FOLDERS
                                       port:INCOMING_PORT
                             connectionType:INCOMING_CONNECTION_TYPE
                                   authType:INCOMING_AUTH_TYPE
                                      login:self.emailAddress
                                   password:self.password];
    
    self.connectionError = account.lastError;
    
    return success;
}

@end
