//
//  SettingsManager.h
//  MailClient
//
//  Created by Barney on 8/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

+ (id)sharedManager;

- (NSString*)appID;
- (NSString*)appVersion;
- (NSString*)systemVersion;
- (NSString*)model;
- (NSUUID*)udid;

@end
