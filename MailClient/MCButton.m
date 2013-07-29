//
//  MCButton.m
//  MailClient
//
//  Created by Barney on 7/29/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MCButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation MCButton
{
    UIView *_selectionView;
}

- (void)awakeFromNib
{
    static CGRect sectionSize;
    sectionSize = CGRectMake(0, 0, 60, 40);
    
    _selectionView = [[UIView alloc] initWithFrame:sectionSize];
    [_selectionView setBackgroundColor:[UIColor clearColor]];
    [_selectionView setCenter:[self convertPoint:CGPointMake(round(self.titleLabel.center.x), round(self.titleLabel.center.y)) fromView:self]];
    _selectionView.layer.cornerRadius = 5;
    _selectionView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    _selectionView.layer.borderWidth = 1.0f;
    [_selectionView setUserInteractionEnabled:NO];
    [_selectionView setAlpha:0.4];
    [self addSubview:_selectionView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [UIView animateWithDuration:0.2 animations:^
     {
         [_selectionView setAlpha:0.1];
     }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.1 animations:^
     {
         [_selectionView setAlpha:0.4];
     }];
}

@end
