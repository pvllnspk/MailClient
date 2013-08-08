//
//  MailAttributesView.h
//  MailClient
//
//  Created by Barney on 8/8/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSTokenField.h"

@protocol MailAttributesViewDelegate <NSObject>
@optional
- (void)accountAdded:(GoogleMailAccount *)account;
@end

@interface MailAttributesView : UIView <JSTokenFieldDelegate>

@end
