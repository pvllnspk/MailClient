//
//  AppDelegate.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AppDelegate.h"
#import "MailboxesViewController.h"
#import "MessageViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    MessageViewController * messageViewController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)messageViewController;
    
    MailboxesViewController * mailboxesViewController = splitViewController.viewControllers[0];
    return YES;    
}

+(dispatch_queue_t) serialGlobalBackgroundQueue
{
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("serialGlobalBackgroundQueue_#1", 0);
    });
    return queue;
}

@end
