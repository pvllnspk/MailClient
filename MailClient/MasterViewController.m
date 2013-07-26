//
//  MasterViewController.m
//  MailClient
//
//  Created by Barney on 7/25/13.
//  Copyright (c) 2013 pvllnspk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "DTCoreText.h" 

#if 1 // Set to 1 to enable MasterViewController Logging
#define MVCLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MVCLog(x, ...)
#endif

@implementation MasterViewController
{
    NSArray *_mailboxes;
    NSMutableArray *_mailfolders;
    UIActivityIndicatorView *_spinner;
}

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
    MVCLog(@"awakeFromNib");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MVCLog(@"viewDidLoad");
    
    
    NSString *html = @"<p>Some Text</p>";
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data
                                                               documentAttributes:NULL];
    NSLog(@"%@", attrString);
    
    
    [self initSpinner];
    [self showSpinner];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("dispatch_queue_#1", 0);
    dispatch_async(backgroundQueue, ^{
        
      DLog(@"attempt to connect to the gmail account");
        
        CTCoreAccount *account = [[CTCoreAccount alloc] init];
        BOOL success = [account connectToServer:@"imap.gmail.com"
                                           port:993
                                 connectionType:CTConnectionTypeTLS
                                       authType:CTImapAuthTypePlain
                                          login:@"findiosjob@gmail.com"
                                       password:@"7092findiosjob"];
        
        
        if (!success)
        {
            DLog(@"Failed %@",account.lastError);
        }
        else
        {
            DLog(@"Success");
            
            NSSet *subFolders = [account subscribedFolders];
            _mailboxes = [subFolders allObjects];
            
            _mailfolders = [[NSMutableArray alloc]init];
            for(NSString *mailbox in _mailboxes){
                  CTCoreFolder *folder = [account folderWithPath:mailbox];
                [_mailfolders addObject:folder];
            }            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideSpinner];
            [self.tableView reloadData];
            
        });
    });
}


#pragma mark
#pragma mark Spinner

-(void) initSpinner
{
    MVCLog(@"initSpinner");
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    _spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
                                 | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    _spinner.hidesWhenStopped = YES;
    [_spinner setColor:[UIColor grayColor]];
    [self.view addSubview:_spinner];
}

-(void) showSpinner
{
    MVCLog(@"showSpinner");
    [_spinner startAnimating];
}

-(void) hideSpinner
{
    MVCLog(@"hideSpinner");
    [_spinner stopAnimating];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MVCLog(@"numberOfRowsInSection %d",[_mailboxes count]);
    return [_mailboxes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_mailboxes objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.detailViewController setFolder:[_mailfolders objectAtIndex:indexPath.row]];
}

@end
