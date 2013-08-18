//
//  AppConfig.h
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#ifndef MailClient_AppConfig_h
#define MailClient_AppConfig_h

#define APP_VERSION @"0.1.0"

#define LOAD_TEST_ACCOUNT_AT_START 1

#if 1
#define DLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define DLog(x, ...)
#endif

#endif
