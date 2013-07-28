//
//  MCTreeItem.h
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCTreeItem : NSObject

@property (nonatomic, strong) NSString *base, *path;
@property (nonatomic) NSInteger numberOfSubitems;
@property (nonatomic, strong) MCTreeItem *parentSelectingItem;
@property (nonatomic, strong) NSMutableArray *ancestorSelectingItems;
@property (nonatomic) NSInteger submersionLevel;

- (BOOL)isEqualToSelectingItem:(MCTreeItem *)selectingItem;

@end
