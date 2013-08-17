//
//  MailboxEntity.h
//  MailClient
//
//  Created by Barney on 8/17/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MailboxEntity : NSManagedObject

@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * password;

@end
