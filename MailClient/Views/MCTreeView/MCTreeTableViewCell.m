//
//  MCTreeTableViewCell.m
//  MailClient
//
//  Created by Barney on 7/28/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

//Thanks https://github.com/adamhoracek/KOTree

#import "MCTreeTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define MCCOLOR_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
#define MCCOLOR_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define MCCOLOR_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1] /*#9b6040*/
#define MCCOLOR_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/
#define MCFONT_TITLE [UIFont fontWithName:@"HelveticaNeue" size:19.0f]
#define MCFONT_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]

@implementation MCTreeTableViewCell

@synthesize backgroundImageView;
@synthesize iconButton;
@synthesize titleTextField;
@synthesize countLabel;
@synthesize treeItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"copymove-cell-bg"]];
		[backgroundImageView setContentMode:UIViewContentModeTopRight];
		
		[self setBackgroundView:backgroundImageView];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		
        iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [iconButton setFrame:CGRectMake(0, 0, 100, 65)];
        [iconButton setAdjustsImageWhenHighlighted:NO];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder"] forState:UIControlStateNormal];
        
        [self.contentView addSubview:iconButton];
        
        
		titleTextField = [[UITextField alloc] init];
		[titleTextField setFont:MCFONT_TITLE];
		[titleTextField setTextColor:MCCOLOR_TITLE];
		[titleTextField.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
		[titleTextField.layer setShadowOffset:CGSizeMake(0, 1)];
		[titleTextField.layer setShadowOpacity:1.0f];
		[titleTextField.layer setShadowRadius:0.0f];
		
		[titleTextField setUserInteractionEnabled:NO];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
		[titleTextField sizeToFit];
		[titleTextField setFrame:CGRectMake(108, 17, titleTextField.frame.size.width, titleTextField.frame.size.height)];
		[self.contentView addSubview:titleTextField];
		
		[self.layer setMasksToBounds:YES];
		
		countLabel = [[UILabel alloc] initWithFrame:CGRectMake(686, 28, 47, 28)];
		[countLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
		[countLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"item-counter"]]];
		[countLabel setTextAlignment:UITextAlignmentCenter];
		[countLabel setLineBreakMode:UILineBreakModeMiddleTruncation];
		[countLabel setFont:MCFONT_COUNTER];
		[countLabel setTextColor:MCCOLOR_COUNTER];
		[countLabel setShadowColor:MCCOLOR_COUNTER_SHADOW];
		[countLabel setShadowOffset:CGSizeMake(0, 1)];
		
		[self setAccessoryView:countLabel];
		[self.accessoryView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
		
    }
    return self;
}

- (void)setLevel:(NSInteger)level
{    
    CGRect rect;
    
    rect = iconButton.frame;
    rect.origin.x = 5 * level;
    iconButton.frame = rect;
    
    rect = titleTextField.frame;
    rect.origin.x = 15 + (50 * level + level==0?0:70);
    titleTextField.frame = rect;
}

@end
