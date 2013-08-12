//
//  MailFolder.h
//  MailClient
//
//  Created by Barney on 8/10/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <MailCore/MailCore.h>

@interface MailFolder : NSObject

@property(nonatomic,copy) NSString *account;
@property(nonatomic,retain) CTCoreFolder *folder;

@end
