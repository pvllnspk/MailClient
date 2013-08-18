//
//  MCTreeTableViewCell.h
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

//Thanks https://github.com/adamhoracek/KOTree

#import <UIKit/UIKit.h>

@class MCTreeNode;

@interface MCTreeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) MCTreeNode *treeItem;

- (void)setLevel:(NSInteger)level;

@end
