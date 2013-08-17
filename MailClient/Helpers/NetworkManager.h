//
//  NetworkManager.h
//  MailClient
//
//  Created by Barney on 8/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkManagerDelegate <NSObject>

@optional
- (void)onReachabilityChanged:(BOOL)isReachable;

@end

@interface NetworkManager : NSObject

+ (id)sharedManager;

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;

- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

@end
