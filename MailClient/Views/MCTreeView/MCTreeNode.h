//
//  MCTreeItem.h
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

//Thanks https://github.com/adamhoracek/KOTree

#import <Foundation/Foundation.h>

@interface MCTreeNode : NSObject

@property (nonatomic, strong) NSString *base, *path;
@property (nonatomic) NSInteger numberOfSubitems;
@property (nonatomic, strong) MCTreeNode *parentSelectingItem;
@property (nonatomic, strong) NSMutableArray *ancestorSelectingItems;
@property (nonatomic) NSInteger submersionLevel;

- (BOOL)isEqualToSelectingItem:(MCTreeNode *)selectingItem;

@end
