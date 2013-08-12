//
//  AddAccountViewController.m
//  MailClient
//
//  Created by Barney on 8/7/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AddAccountViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GoogleMailbox.h"
#import "YahooMailbox.h"
#import "NSString+Additions.h"
#import "TimeExecutionTracker.h"

#define LABELS [NSArray arrayWithObjects:@"Full Name:", @"Email Address:", @"Password:", nil]

#define SUFFIX_GOOGLE @"@gmail.com"
#define SUFFIX_YAHOO  @"@yahoo.com"


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
    
    [self.view setBackgroundColor:BACKGROUND_COLOR];
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
	[_tableView setBackgroundColor:BACKGROUND_COLOR];
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundView:[[UIView alloc] init]];
}



- (IBAction)cancel:(id)sender
{
    DLog(@"cancel");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    [self showSpinner];
    
    BaseMailbox* account;
    
    
    if([_emailAddress.text endsWith:SUFFIX_GOOGLE]){
        
        account = [[GoogleMailbox alloc]
                   initWithFullName:_fullName.text emailAddress:_emailAddress.text password:_password.text];
        
        DLog(@"hasSuffix:SUFFIX_GOOGLE")
        
    }else if([_emailAddress.text endsWith:SUFFIX_YAHOO]){
        
        account = [[YahooMailbox alloc]
                   initWithFullName:_fullName.text emailAddress:_emailAddress.text password:_password.text];
        
        DLog(@"hasSuffix:SUFFIX_YAHOO")
        
    }else{
        
         DLog(@"addingAccountFailed  [%@]  ",_emailAddress.text)
        
        [self addingAccountFailed];
    }
    
    
    dispatch_async([AppDelegate serialBackgroundQueue], ^{
        
        DLog(@"attempt to add an existing account with the credentials [%@] and [%@]",_emailAddress.text, _password.text);
        
        [TimeExecutionTracker startTrackingWithName:@"connection to an account"];
        
        BOOL success = [account connect];
        
        [TimeExecutionTracker stopTrackingAndPrint];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            
            if (success){
                
                DLog(@"Succes");
                [self addingAccountSuccessed:account];
            }
            else{
                
                DLog(@"Failed %@",account.connectionError);
                [self addingAccountFailed];
            }
        });
    });
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
        leftText.text = [LABELS objectAtIndex:indexPath.row];
		[leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _fullName = (UITextView *)[cell viewWithTag:102];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
        
    }if(indexPath.row==1){
        
        static NSString *CellIdentifier = @"AddAccountCell2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *leftText = (UILabel *)[cell viewWithTag:101];
        leftText.text = [LABELS objectAtIndex:indexPath.row];
        [leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _emailAddress = (UITextView *)[cell viewWithTag:102];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
        leftText.text = [LABELS objectAtIndex:indexPath.row];
        [leftText setFont:MCFONT_TITLE];
		[leftText setTextColor:MCCOLOR_TITLE];
		[leftText.layer setShadowColor:MCCOLOR_TITLE_SHADOW.CGColor];
        
        _password = (UITextView *)[cell viewWithTag:102];
        [_password setSecureTextEntry:YES];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

-(void)addingAccountSuccessed:(BaseMailbox*) account
{
    if(_delegate){
        [_delegate accountAdded:account];
        [self cancel:nil];
    }
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
