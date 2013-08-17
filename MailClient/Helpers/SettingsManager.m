//
//  SettingsManager.m
//  MailClient
//
//  Created by Barney on 8/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    static SettingsManager *settingsManager;
    dispatch_once(&onceToken, ^{
        settingsManager = [[self alloc] init];
    });
    return settingsManager;
}

- (NSString*)appID
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString*)appVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString*)systemVersion
{
	return [[UIDevice currentDevice] systemVersion];
}

- (NSString*)model
{
	return[[UIDevice currentDevice] model];
}

- (NSUUID*)udid
{
	return [[UIDevice currentDevice] identifierForVendor];
}

@end
