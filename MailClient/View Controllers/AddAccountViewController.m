//
//  AddAccountViewController.m
//  MailClient
//
//  Created by Barney on 7/31/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "AddAccountViewController.h"

#define Labels [NSArray arrayWithObjects:@"Full Name:", @"Email Address:", @"Password:", nil]

@interface AddAccountViewController ()

@end

@implementation AddAccountViewController
{
    UITextView *_fullName;
    UITextView *_emailAddress;
    UITextView *_password;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView.dataSource = self;
    _tableView.delegate =self;    
	[_tableView setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1] /*#fff9f4*/];
    
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundView:[[UIView alloc] init]];

    
    [_topBar setBackgroundColor:[UIColor colorWithRed:1 green:0.976 blue:0.957 alpha:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UITextView *rightText = (UITextView *)[cell viewWithTag:102];
        
        leftText.text = [Labels objectAtIndex:indexPath.row];
        
        return cell;
        
    }if(indexPath.row==1){
        
        static NSString *CellIdentifier = @"AddAccountCell2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UILabel *leftText = (UILabel *)[cell viewWithTag:101];
        UITextView *rightText = (UITextView *)[cell viewWithTag:102];
        
        leftText.text = [Labels objectAtIndex:indexPath.row];
        
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
        UITextView *rightText = (UITextView *)[cell viewWithTag:102];
        
        leftText.text = [Labels objectAtIndex:indexPath.row];

        return cell;
    }
}

- (IBAction)cancel:(id)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                    message:@"You must be connected to the internet to use this app."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
