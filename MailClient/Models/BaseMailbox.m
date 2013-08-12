//
//  BaseMailbox.m
//  MailClient
//
//  Created by Barney on 8/12/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "BaseMailbox.h"

@implementation BaseMailbox
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
    
    return [self connectToAccount:_account];
}

-(BOOL)connectToAccount:(CTCoreAccount *)account
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
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