//
//  SHCReceiptsViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "SHCReceiptsViewController.h"
#import "UIRefreshControl+Additions.h"
#import "POSReceiptsTableViewDataSource.h"
#import "UIViewController+Additions.h"

@interface SHCReceiptsViewController ()
@property (nonatomic,strong)UIRefreshControl *refreshControl;
@property (nonatomic,strong)POSReceiptsTableViewDataSource *receiptsTableViewDataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SHCReceiptsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setTitle:self.storeName];
    self.receiptsTableViewDataSource = [POSReceiptsTableViewDataSource new];
    self.receiptsTableViewDataSource.storeName = self.storeName;
    self.tableView.dataSource = self.receiptsTableViewDataSource;
    
    [self updateNavbar];

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];

    // Set the initial refresh control text
    [self.refreshControl initializeRefreshControlText];
    [self.refreshControl updateRefreshControlTextRefreshing:YES];

        self.refreshControl.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];

    // This is a hack to force iOS to make up its mind as to what the value of the refreshControl's frame.origin.y should be.
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];

    // Present persistent data before updating
//    [self updateFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
