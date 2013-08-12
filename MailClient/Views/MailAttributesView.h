//
//  MailAttributesView.h
//  MailClient
//
//  Created by Barney on 8/8/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSTokenField.h"

@interface MailAttributesView : UIView <JSTokenFieldDelegate>
{
@public
    JSTokenField *fromField;
	JSTokenField *toField;
	JSTokenField *ccField;
    UITextField *subjectField;
}

@property (nonatomic, assign) id <JSTokenFieldDelegate> delegate;

@end
