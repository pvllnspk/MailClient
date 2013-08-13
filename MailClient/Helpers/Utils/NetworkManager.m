//
//  NetworkManager.m
//  MailClient
//
//  Created by Barney on 8/13/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "NetworkManager.h"
#import "Reachability.h"

@implementation NetworkManager
{
    Reachability *_reachability;
    NSMutableArray *_observers;
}

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    static NetworkManager *netwokManager;
    dispatch_once(&onceToken, ^{
        netwokManager = [[self alloc] init];
    });
    return netwokManager;
}

-(id)init
{
    if (self = [super init]) {
        
        _observers = [NSMutableArray array];
        
        __weak typeof(self) weakSelf = self;
        
        _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        _reachability.reachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf notifyObservers:YES];
            });
        };
        
        _reachability.unreachableBlock = ^(Reachability*reach)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf notifyObservers:NO];
            });
        };
    }
    return  self;
}

-(void)addObserver:(id)observer
{
    if(![_observers containsObject:observer]){
        [_observers addObject:observer];
    }
}

-(void)removeObserver:(id)observer
{
    if([_observers containsObject:observer]){
        [_observers removeObject:observer];
    }
}

-(void)notifyObservers:(BOOL)isReachable
{
    for(id observer in _observers){
        
        if([observer respondsToSelector:@selector(onReachabilityChanged:)]){
            [observer onReachabilityChanged:isReachable];
        }
    }
}

- (BOOL)isReachable
{
    return [_reachability isReachable];
}

- (BOOL)isReachableViaWWAN
{
    return [_reachability isReachableViaWWAN];
}

- (BOOL)isReachableViaWiFi
{
    return [_reachability isReachableViaWiFi];
}

@end
