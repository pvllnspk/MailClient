//
//  AddAccountViewController.m
//  MailClient
//
//  Created by Barney on 7/31/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AddAccountViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GoogleMailAccount.h"
#import "TimeExecutionTracker.h"
#import "AppDelegate.h"

#define Labels [NSArray arrayWithObjects:@"Full Name:", @"Email Address:", @"Password:", nil]

#define MCCOLOR_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
#define MCCOLOR_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define MCFONT_TITLE [UIFont fontWithName:@"HelveticaNeue" size:22.0f]


@implementation AddAccountViewController
{
    UITextView *_fullName;
    UITextView *_emailAddress;
    UITextView *_password;
    
    UIActivityIndicatorView *_spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSpinner];

    _tableView.dataSource = self;
    _tableView.delegate =self;    
	[_tableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
    
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundView:[[UIView alloc] init]];

    
    [_topBar setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row==0){
        
        static NSString *CellIdentifier = @"AddAccountCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *leftText = (UILabel *)[cell viewWithTag:101];
         leftText.text = [Labels objectAtIndex:indexPath.row];
		[leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _fullName = (UITextView *)[cell viewWithTag:102];
        
        return cell;
        
    }if(indexPath.row==1){
        
        static NSString *CellIdentifier = @"AddAccountCell2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *leftText = (UILabel *)[cell viewWithTag:101];
         leftText.text = [Labels objectAtIndex:indexPath.row];
        [leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _emailAddress = (UITextView *)[cell viewWithTag:102];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
    
    else{
        
        static NSString *CellIdentifier = @"AddAccountCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *leftText = (UILabel *)[cell viewWithTag:101];
        leftText.text = [Labels objectAtIndex:indexPath.row];
        [leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _password = (UITextView *)[cell viewWithTag:102];

        return cell;
    }
}

- (IBAction)cancel:(id)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    [self showSpinner];
    
    dispatch_async([AppDelegate serialGlobalBackgroundQueue], ^{
        
        DLog(@"attempt to add an existing account with the credentials [%@] and [%@]",_emailAddress.text, _password.text);
        [TimeExecutionTracker startTrackingWithName:@"connection to an account"];
        
        GoogleMailAccount* googleAccount = [[GoogleMailAccount alloc]
                                            initWithFullName:_fullName.text emailAddress:_emailAddress.text password:_password.text];
        BOOL success = [googleAccount connect];

        [TimeExecutionTracker stopTrackingAndPrint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            
            if (success){
                
                DLog(@"Succes");
                [self addingAccountSuccessed:googleAccount];
            }
            else{
                
                DLog(@"Failed %@",googleAccount.connectionError);
                [self addingAccountFailed];
            }
        });
    });
}





-(void)addingAccountSuccessed:(GoogleMailAccount*) googleAccount
{
    [_delegate accountAdded:googleAccount];
    
    
}

-(void)addingAccountFailed
{
    _emailAddress.text = @"";
    _password.text = @"";
    
    CABasicAnimation *movingAnimation =[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    [movingAnimation setDuration:0.2];
    [movingAnimation setRepeatCount:1];
    [movingAnimation setAutoreverses:YES];
    [movingAnimation setFromValue:[NSNumber numberWithFloat:-5]];
    [movingAnimation setToValue:[NSNumber numberWithFloat:5]];
    [self.view.layer addAnimation:movingAnimation forKey:@"animateLayer"];
}

#pragma mark
#pragma mark Panels Spinners

-(void) initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height * 0.7f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}

-(void) showSpinner
{
    [_spinner startAnimating];
    _tableView.userInteractionEnabled = NO;
}

-(void) hideSpinner
{
    [_spinner stopAnimating];
    _tableView.userInteractionEnabled = YES;
}

@end
