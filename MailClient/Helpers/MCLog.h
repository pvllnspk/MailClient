//
//  MCLog.h
//  MailClient
//
//  Created by Barney on 8/15/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#ifndef MailClient_MCLog_h
#define MailClient_MCLog_h

extern int MCLogDetailed;

#define MCLogMailCore(fmt, ...) if(MCLogDetailed){NSLog((@"MAILCORE : %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}

#endif
