//
//  MCTreeTableViewCell.h
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCTreeItem;

@interface MCTreeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) MCTreeItem *treeItem;

- (void)setLevel:(NSInteger)level;

@end
