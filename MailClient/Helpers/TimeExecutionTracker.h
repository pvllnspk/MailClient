//
//  TimeExecutionTracker.h
//  MailClient
//
//  Created by Barney on 8/1/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeExecutionTracker : NSObject

+ (void)startTrackingWithName:(NSString*)name;
+ (void)stopTrackingAndPrint;

@end
