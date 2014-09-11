//
//  POSUploadViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 04.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSUploadViewController.h"
#import "POSMailbox+Methods.h"
#import "POSFolder+Methods.h"
#import "UIViewController+BackButton.h"
#import "POSAPIManager+PrivateMethods.h"
#import "POSUploadTableViewDataSource.h"

NSString *const kStartUploadingDocumentNotitification = @"startUploadingDocumentNotification";

@interface POSUploadViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *howtoUploadImageView;
@property (nonatomic, strong) POSUploadTableViewDataSource *dataSource;
@property (nonatomic) BOOL isShowingFolders;
@property (nonatomic, strong) POSMailbox *chosenMailBox;
@property (nonatomic, strong) POSFolder *chosenFolder;
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
    if (self.isShowingFolders){
        self.dataSource.entityDescription = kFolderEntityName;
    }else {
        self.dataSource.entityDescription = kMailboxEntityName;
    }
    self.tableView.delegate = self;
    self.howtoUploadImageView.hidden = YES;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self pos_hasBackButton] == NO){
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
}
- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowingFolders == NO) {
        [self performSegueWithIdentifier:kShowFoldersSegueIdentifier sender:self];
    } else {
        self.chosenFolder = [self.dataSource managedObjectAtIndexPath:indexPath];
        
        [[POSAPIManager sharedManager] uploadFileWithURL:self.url toFolder:self.chosenFolder success:^{
            
           
        } failure:^(NSError *error) {
            
        }];
        NSNotification *notification = [NSNotification notificationWithName:kStartUploadingDocumentNotitification object:self userInfo:@{
                                                                                                                                         @"folder": self.chosenFolder, @"mailbox": self.chosenMailBox
                                                                                                                                         }];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowFoldersSegueIdentifier]) {
        POSUploadViewController *uploadViewcontroller = [segue destinationViewController];
        uploadViewcontroller.isShowingFolders = YES;
        POSMailbox *selectedMailbox = [self.dataSource managedObjectAtIndexPath:self.tableView.indexPathForSelectedRow];
        uploadViewcontroller.chosenMailBox = selectedMailbox;
        uploadViewcontroller.url = self.url;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
