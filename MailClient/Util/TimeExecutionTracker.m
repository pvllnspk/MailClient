//
//  TimeExecutionTracker.m
//  MailClient
//
//  Created by Barney on 8/1/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "TimeExecutionTracker.h"

#if 1 // Set to 1 to enable TimeExecutionTracker Logging
#define TETLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define TETLog(x, ...)
#endif

static NSDate *_methodStart;
static NSString *_trackingName;

@implementation TimeExecutionTracker

+(void)startTrackingWithName:(NSString *)name
{
    _methodStart = [NSDate date];
    _trackingName = name;
    TETLog(@"[ %@ ]",_trackingName)
}

+(void)stopTrackingAndPrint
{
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:_methodStart];
    TETLog(@"[ %@ ] executionTime = %f",_trackingName,executionTime)
}

@end
