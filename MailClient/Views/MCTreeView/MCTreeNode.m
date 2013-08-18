//
//  MCTreeItem.m
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

//Thanks https://github.com/adamhoracek/KOTree

#import "MCTreeNode.h"

@implementation MCTreeNode

@synthesize base, path;
@synthesize numberOfSubitems;
@synthesize parentSelectingItem;
@synthesize ancestorSelectingItems;
@synthesize submersionLevel;

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToSelectingItem:other];
}

- (BOOL)isEqualToSelectingItem:(MCTreeNode *)selectingItem {
	if (self == selectingItem)
        return YES;
	
	if ([base isEqualToString:selectingItem.base])
		if ([path isEqualToString:selectingItem.path])
			if (numberOfSubitems == selectingItem.numberOfSubitems)
				return YES;
	
	return NO;
}

@end
