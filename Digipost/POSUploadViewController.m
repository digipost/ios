//
//  POSUploadViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 04.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSUploadViewController.h"
#import "POSMailbox.h"
#import "POSUploadTableViewDataSource.h"

@interface POSUploadViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *howtoUploadImageView;
@property (nonatomic, strong) POSUploadTableViewDataSource *dataSource;
@property (nonatomic) BOOL isShowingFolders;

@end

NSString *kShowFoldersSegueIdentifier = @"showFoldersSegue";

@implementation POSUploadViewController

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
    self.dataSource = [[POSUploadTableViewDataSource alloc] initAsDataSourceForTableView:self.tableView];
    self.tableView.delegate = self;
    self.howtoUploadImageView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowingFolders == NO) {
        
    } else {
        [self performSegueWithIdentifier:kShowFoldersSegueIdentifier sender:self];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowFoldersSegueIdentifier]) {
        POSUploadViewController *uploadViewcontroller = [segue destinationViewController];
        uploadViewcontroller.isShowingFolders = YES;
    }

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
