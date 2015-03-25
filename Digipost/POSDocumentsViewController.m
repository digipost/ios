//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import <UIActionSheet+Blocks.h>
#import "POSFolderIcon.h"
#import "UIColor+Convenience.h"
#import "POSDocumentsViewController.h"
#import "POSModelManager.h"
#import "POSDocument.h"
#import "POSDocumentTableViewCell.h"
#import "POSAttachment.h"
#import "UIColor+Convenience.h"
#import "POSAPIManager.h"
#import "POSMailbox.h"
#import "POSRootResource.h"
#import "POSFolder+Methods.h"
#import "POSReceipt.h"
#import "NSError+ExtraInfo.h"
#import "SHCAttachmentsViewController.h"
#import "POSLetterViewController.h"
#import "SHCAppDelegate.h"
#import <AHKActionSheet.h>
#import "SHCDocumentsViewController+NavigationHierarchy.h"
#import "UIViewController+ValidateOpening.h"
#import "POSInvoice.h"
#import "POSAccountViewController.h"
#import "POSFoldersViewController.h"
#import "NSPredicate+CommonPredicates.h"
#import "POSDocumentTableViewCell.h"
#import "POSUploadTableViewCell.h"
#import "UIViewController+BackButton.h"
#import "SHCOAuthViewController.h"
#import "POSOAuthManager.h"
#import "POSDocument+Methods.h"
#import "Digipost-Swift.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushDocumentsIdentifier = @"PushDocuments";
NSString *const kDocumentsViewControllerIdentifier = @"documentsViewControllerIdentifier";
// Google Analytics screen name
NSString *const kDocumentsViewControllerScreenName = @"Documents";

NSString *const kRefreshDocumentsContentNotificationName = @"refreshDocumentsContentNotificationName";

NSString *const kDocumentsViewEditingStatusChangedNotificationName = @"documentsViewEditingStatusChangedNotificationName";
//NSString *const kDocumentsViewDidMoveOrDeleteDocumentsLetterViewNeedsReloadNotificationName =@"documentsViewDidMoveOrDeleteDocumentsLetterViewNeedsReloadNotificationName";

NSString *const kEditingStatusKey = @"editingStatusKey";

@interface POSDocumentsViewController () <NSFetchedResultsControllerDelegate, SHCDocumentTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIView *tableViewBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *noDocumentsLabel;
@property (copy, nonatomic) NSString *selectedDocumentUpdateUri;
@property (assign, nonatomic) BOOL shouldAnimateInsertAndDeletesToFetchedResultsController;

@end

@implementation POSDocumentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithRed:64.0 / 255.0
                                                                       green:66.0 / 255.0
                                                                        blue:69.0 / 255.0
                                                                       alpha:0.95]];

    self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
    self.moveBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_MOVE_TITLE", @"Move");
    self.deleteBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_DELETE_TITLE", @"Delete");

    self.baseEntity = [[POSModelManager sharedManager] documentEntity];

    self.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt))
                                                            ascending:NO
                                                             selector:@selector(compare:)] ];

    self.predicate = [NSPredicate predicateWithDocumentsForMailBoxDigipostAddress:self.mailboxDigipostAddress
                                                                 inFolderWithName:self.folderName];
    self.screenName = kDocumentsViewControllerScreenName;

    [super viewDidLoad];
    [self addAccountsAnFoldersVCToDoucmentHierarchy];

    [self updateToolbarButtonItems];
    [self pos_setDefaultBackButton];
    self.shouldAnimateInsertAndDeletesToFetchedResultsController = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES
                                       animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgressDidChange:)
                                                 name:kAPIManagerUploadProgressChangedNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgressDidFinish:)
                                                 name:kAPIManagerUploadProgressFinishedNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshContent)
                                                 name:kRefreshDocumentsContentNotificationName
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.folderUri == nil) {
        POSFolder *folder = [POSFolder existingFolderWithName:self.folderName
                                       mailboxDigipostAddress:self.mailboxDigipostAddress
                                       inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        self.folderUri = folder.uri;
        self.folderDisplayName = folder.displayName;
    }

    self.predicate = [NSPredicate predicateWithDocumentsForMailBoxDigipostAddress:self.mailboxDigipostAddress
                                                                 inFolderWithName:self.folderName];
    [self updateContentsFromServerUserInitiatedRequest:@NO];
    [self.navigationController.toolbar setBarTintColor:[UIColor digipostSpaceGrey]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[POSAPIManager sharedManager] cancelUpdatingDocuments];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAPIManagerUploadProgressChangedNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAPIManagerUploadProgressFinishedNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kRefreshDocumentsContentNotificationName
                                                  object:nil];

    [self programmaticallyEndRefresh];

    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushAttachmentsIdentifier]) {
        POSDocument *document = (POSDocument *)sender;
        self.selectedDocumentUpdateUri = document.updateUri;
        SHCAttachmentsViewController *attachmentsViewController = (SHCAttachmentsViewController *)segue.destinationViewController;
        attachmentsViewController.documentsViewController = self;
        attachmentsViewController.attachments = document.attachments;
    } else if ([segue.identifier isEqualToString:kPushLetterIdentifier]) {
        POSAttachment *attachment = (POSAttachment *)sender;
        POSLetterViewController *letterViewController = (POSLetterViewController *)segue.destinationViewController;
        letterViewController.documentsViewController = self;
        letterViewController.attachment = attachment;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing
             animated:animated];
    [self.navigationController setToolbarHidden:!editing
                                       animated:animated];
    [self updateNavbar];
    self.navigationController.interactivePopGestureRecognizer.enabled = !editing;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDocumentsViewEditingStatusChangedNotificationName
                                                        object:self
                                                      userInfo:@{kEditingStatusKey : [NSNumber numberWithBool:editing]}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [super tableView:tableView
                  numberOfRowsInSection:section];

    if ([POSAPIManager sharedManager].isUploadingFile) {
        number++;
    }

    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([POSAPIManager sharedManager].isUploadingFile) {
        if (indexPath.row == 0) {
            POSUploadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUploadTableViewCellIdentifier
                                                                           forIndexPath:indexPath];
            cell.progressView.progress = [POSAPIManager sharedManager].uploadProgress.fractionCompleted;
            cell.dateLabel.text = [POSDocument stringForDocumentDate:[NSDate date]];
            NSString *fileName = [[POSAPIManager sharedManager].uploadProgress userInfo][@"fileName"];
            fileName = [fileName stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            cell.fileNameLabel.text = fileName;
            return cell;
        }

        // If we have a cell displaying the upload progress, adjust the indexPath accordingly.
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                       inSection:indexPath.section];
    }
    POSDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDocumentTableViewCellIdentifier
                                                                     forIndexPath:indexPath];
    [self configureCell:cell
            atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(POSDocumentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    POSDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPath];

    POSAttachment *attachment = [document mainDocumentAttachment];

    if ([attachment.authenticationLevel isEqualToString:kAttachmentOpeningValidAuthenticationLevel]) {
        cell.lockedImageView.hidden = YES;
    } else {
        cell.unreadImageView.hidden = YES;
        cell.lockedImageView.hidden = NO;
    }
    if ([attachment.read boolValue]) {
        cell.subjectLabel.font = [UIFont digipostRegularFont];
    } else {
        cell.subjectLabel.font = [UIFont digipostBoldFont];
    }
    if (attachment.originIsPublicEntity) {
        NSString *publicEntity = NSLocalizedString(@"PUBLIC_ENTITY", @"the name of public entity");
        cell.senderLabel.text = [NSString stringWithFormat:@"%@: %@", publicEntity, attachment.document.creatorName];
    } else {
        cell.senderLabel.text = [NSString stringWithFormat:@"%@", attachment.document.creatorName];
    }

    cell.delegate = self;
    cell.editingAccessoryType = UITableViewCellAccessoryNone;
    cell.attachmentImageView.hidden = [document.attachments count] > 1 ? NO : YES;
    cell.dateLabel.text = [POSDocument stringForDocumentDate:attachment.document.createdAt];
    cell.dateLabel.accessibilityLabel = [NSDateFormatter localizedStringFromDate:attachment.document.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    cell.subjectLabel.text = attachment.subject;
    cell.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%@  Received %@ From %@", @"Accessibilitylabel on document cell"), cell.subjectLabel.accessibilityLabel, cell.dateLabel.accessibilityLabel, cell.senderLabel.accessibilityLabel];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([POSAPIManager sharedManager].isUploadingFile) {
        if (indexPath.row == 0) {
            return nil;
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [self updateToolbarButtonItems];
        return;
    }

    NSIndexPath *actualIndexPathSelected = nil;
    // adjust for index when uploading file
    if ([POSAPIManager sharedManager].isUploadingFile) {
        actualIndexPathSelected = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
    } else {
        actualIndexPathSelected = indexPath;
    }

    POSDocument *document = [self.fetchedResultsController objectAtIndexPath:actualIndexPathSelected];
    POSAttachment *attachment = [document mainDocumentAttachment];
    if ([document.attachments count] > 1) {
        [self performSegueWithIdentifier:kPushAttachmentsIdentifier
                                  sender:document];

    } else if (attachment.openingReceiptUri) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Avsender krever lesekvittering", @"Avsender krever lesekvittering")
                           message:NSLocalizedString(@"Hvis du åpner dette brevet", @"Hvis du åpner dette brevet")
                 cancelButtonTitle:NSLocalizedString(@"Avbryt", @"Avbryt")
                 otherButtonTitles:@[ NSLocalizedString(@"Åpne brevet og send kvittering", @"Åpne brevet og send kvittering") ]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              switch (buttonIndex) {
                                  case 0:
                                      break;
                                  case 1:
                                  {
                                      [self shouldValidateOpeningReceipt:document];
                                      break;
                                  }
                                  case 2:
                                      break;
                                  default:
                                      break;
                              }
                          }];
    } else {
        POSAttachment *attachment = [document mainDocumentAttachment];
        [self validateOpeningAttachment:attachment
            success:^{
                                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                        ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
                                    } else {
                                        [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
                                    }
            }
            failure:^(NSError *error){

            }];
    }
}

- (void)shouldValidateOpeningReceipt:(POSDocument *)document
{
    POSAttachment *attachment = [document.attachments firstObject];
    [[POSAPIManager sharedManager] validateOpeningReceipt:attachment success:^(NSDictionary *attachmentAttributes) {
        
        [self validateOpeningAttachment:attachment
                                success:^{
                                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                        ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
                                    } else {
                                        
                                        if ([document.attachments count] > 1) {
                                            [self performSegueWithIdentifier:kPushAttachmentsIdentifier
                                                                      sender:document];
                                        } else {
                                            [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
                                        }
                                    }
                                }
                                failure:^(NSError *error) {
                                    [UIAlertView showWithTitle:error.errorTitle
                                                       message:[error localizedDescription]
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@[error.okButtonTitle]
                                                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                          [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                                      }];
                                }];
    } failure:^(NSError *error) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Failed validating opening receipt title", @"title of alert telling user validation failed") message:@"" cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        [self updateToolbarButtonItems];
        return;
    }
}

#pragma mark - IBActions

- (IBAction)didTapSelectionBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if ([self someRowsSelected]) {
        [self deselectAllRows];
    } else {
        [self selectAllRows];
    }

    [self updateToolbarButtonItems];
}

- (IBAction)didTapMoveBarButtonItem:(UIBarButtonItem *)barButtonItem
{

    [self showBlurredActionSheetWithFolders];
    return;
}

- (void)showBlurredActionSheetWithFolders
{
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:@"Velg mappe"];

    NSArray *folders = [POSFolder foldersForUserWithMailboxDigipostAddress:self.mailboxDigipostAddress
                                                    inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    [actionSheet setBlurTintColor:[UIColor pos_colorWithR:64
                                                        G:66
                                                        B:69
                                                    alpha:0.80]];
    actionSheet.automaticallyTintButtonImages = @YES;
    [actionSheet setButtonHeight:50];

    actionSheet.separatorColor = [UIColor pos_colorWithR:255
                                                       G:255
                                                       B:255
                                                   alpha:0.30f];

    [actionSheet setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [actionSheet setButtonTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [actionSheet setCancelButtonTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    for (POSFolder *folder in folders) {

        UIImage *image = [POSFolderIcon folderIconWithName:folder.iconName].smallImage;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        if ([self.folderName isEqualToString:folder.name] == NO) {
            image = [image scaleToSize:CGSizeMake(18, 18)];
            if (image == nil) {
                image = [UIImage imageNamed:@"list-icon-inbox"];
            }

            [actionSheet addButtonWithTitle:folder.displayName
                                      image:image
                                       type:AHKActionSheetButtonTypeDefault
                                    handler:^(AHKActionSheet *actionSheet, id item) {
                                        if (item) {
                                            [self moveSelectedDocumentsToFolder:folder];
                                        }
                                    }];
        }
    }

    [actionSheet show];
}

- (void)moveSelectedDocumentsToFolder:(POSFolder *)folder
{
    self.shouldAnimateInsertAndDeletesToFetchedResultsController = YES;
    for (NSIndexPath *indexPathOfSelectedRow in [self.tableView indexPathsForSelectedRows]) {
        POSDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPathOfSelectedRow];

        [self moveDocument:document
                  toFolder:folder];
    }

    [self deselectAllRows];
    [self updateToolbarButtonItems];
    [self setEditing:NO
            animated:YES];
}

- (IBAction)didTapDeleteBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSUInteger numberOfLetters = [[self.tableView indexPathsForSelectedRows] count];
    NSString *letterWord = numberOfLetters == 1 ? NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_SINGULAR", @"letter") : NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_PLURAL", @"letters");

    NSString *deleteString = [NSString stringWithFormat:@"%@ %lu %@",
                                                        NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_ONE", @"Delete"),
                                                        (unsigned long)[[self.tableView indexPathsForSelectedRows] count],
                                                        letterWord];

    [UIActionSheet showFromBarButtonItem:barButtonItem
                                animated:YES
                               withTitle:nil
                       cancelButtonTitle:NSLocalizedString(@"GENERIC_CANCEL_BUTTON_TITLE", @"Cancel")
                  destructiveButtonTitle:deleteString
                       otherButtonTitles:nil
                                tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        [self deleteDocuments];
                                    }
                                    [self setEditing:NO animated:YES];
                                }];
}

- (void)refreshContent
{
    [self updateContentsFromServerUserInitiatedRequest:@YES];
}

#pragma mark - Private methods

- (void)updateContentsFromServerUserInitiatedRequest:(NSNumber *)userDidInititateRequest
{
    if ([POSAPIManager sharedManager].isUpdatingDocuments) {
        return;
    }
    self.shouldAnimateInsertAndDeletesToFetchedResultsController = [userDidInititateRequest boolValue];
    // @TODO refactor this
    // Saving uri for the open document in case we need to re fetch it later
    SHCAppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
    POSLetterViewController *letterViewConctroller = appDelegate.letterViewController;
    NSString *openedAttachmentURI;
    if ([letterViewConctroller isViewLoaded]) {
        openedAttachmentURI = letterViewConctroller.attachment.uri;
        if (openedAttachmentURI == nil) {
        }
    }
    [[POSAPIManager sharedManager] updateDocumentsInFolderWithName:self.folderName
        mailboxDigipostAddress:self.mailboxDigipostAddress
        folderUri:self.folderUri
        success:^{
                                                               
                                                               [self updateFetchedResultsController];
                                                               [self programmaticallyEndRefresh];
                                                               [self updateNavbar];
                                                               [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                                               
                                                               // If the user has just managed to enter a document with attachments _after_ the API call finished,
                                                               // but _before_ the Core Data stuff has finished, tapping an attachment will cause the app to crash.
                                                               // To avoid this, let's check if the attachment vc is on top of the nav stack, and if it is - repopulate its data.
                                                               if ([self.navigationController.topViewController isKindOfClass:[SHCAttachmentsViewController class]]) {
                                                                   SHCAttachmentsViewController *attachmentsViewController = (SHCAttachmentsViewController *)self.navigationController.topViewController;
                                                                   
                                                                   POSDocument *selectedDocument = [POSDocument existingDocumentWithUpdateUri:self.selectedDocumentUpdateUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                                   
                                                                   attachmentsViewController.attachments = selectedDocument.attachments;
                                                               }
                                                               
                                                               // quickfix for a bug that causes attachments document to become nil
                                                               // Refetches the showing attachment that lost its link to its document
                                                               SHCAppDelegate *appDelegate = (id) [UIApplication sharedApplication].delegate;
                                                               POSLetterViewController *letterViewConctroller = (id)appDelegate.letterViewController;
                                                               if (letterViewConctroller.attachment) {
                                                                   if (letterViewConctroller.attachment.uri == nil ) {
                                                                       POSAttachment *refetchedObject = [POSAttachment existingAttachmentWithUri:openedAttachmentURI inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                                       [letterViewConctroller setAttachmentDoNotDismissPopover:refetchedObject];
                                                                   }
                                                               }
                                                               
                                                               POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
                                                               if (!rootResource.currentBankAccount) {
                                                                   if ([self documentsNeedCurrentBankAccount]) {
                                                                       [self updateCurrentBankAccountWithUri:rootResource.currentBankAccountUri];
                                                                   }
                                                               }
        }
        failure:^(NSError *error) {
                                                               
                                                               NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                   if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                                       // We were unauthorized, due to the session being invalid.
                                                                       // Let's retry in the next run loop
                                                                       [self performSelector:@selector(updateContentsFromServerUserInitiatedRequest:) withObject:userDidInititateRequest afterDelay:0.0];
                                                                       
                                                                       return;
                                                                   }
                                                               }
                                                               
                                                               [self programmaticallyEndRefresh];
                                                               
                                                               [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                                               if ([userDidInititateRequest boolValue]){
                                                                   [UIAlertView showWithTitle:error.errorTitle
                                                                                      message:[error localizedDescription]
                                                                            cancelButtonTitle:nil
                                                                            otherButtonTitles:@[error.okButtonTitle]
                                                                                     tapBlock:error.tapBlock];
                                                               }
        }];
}

- (void)updateNavbar
{
    [super updateNavbar];

    self.navigationItem.title = self.folderDisplayName;

    UIBarButtonItem *rightBarButtonItem = nil;
    if ([self numberOfRows] > 0) {
        rightBarButtonItem = self.editButtonItem;
    }

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    UIBarButtonItem *backBarButtonItem = self.navigationItem.leftBarButtonItem;
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
}

- (void)updateToolbarButtonItems
{
    if ([self.tableView indexPathsForSelectedRows] > 0) {
        self.moveBarButtonItem.enabled = YES;
        self.deleteBarButtonItem.enabled = YES;
    } else {
        self.moveBarButtonItem.enabled = NO;
        self.deleteBarButtonItem.enabled = NO;
    }

    if ([self someRowsSelected]) {
        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_NONE_TITLE", @"Select none");
    } else {
        self.selectionBarButtonItem.title = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", @"Select all");
    }
}

- (BOOL)someRowsSelected
{
    return [[self.tableView indexPathsForSelectedRows] count] > 0;
}

- (NSInteger)numberOfRows
{
    NSInteger numberOfRows = 0;
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        numberOfRows += [self.tableView numberOfRowsInSection:section];
    }

    return numberOfRows;
}

- (void)selectAllRows
{
    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                        inSection:section];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)deselectAllRows
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        POSDocumentTableViewCell *cell = (POSDocumentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath
                                      animated:NO];
    }
}

- (void)moveDocument:(POSDocument *)document toFolder:(POSFolder *)folder
{
    [[POSAPIManager sharedManager] moveDocument:document
        toFolder:folder
        withSuccess:^{
                                        
                                        document.folder = folder;
                                        
                                        [[POSModelManager sharedManager].managedObjectContext save:nil];
                                        
                                        [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                        [self updateFetchedResultsController];
                                        
                                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                            POSDocument *currentOpenDocument = ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment.document;
                                            if ([currentOpenDocument isEqual:document]){
                                                ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = nil;
                                            }
                                        }
        }
        failure:^(NSError *error) {
                                            NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                    // We were unauthorized, due to the session being invalid.
                                                    // Let's retry in the next run loop
                                                    double delayInSeconds = 0.0;
                                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        [self moveDocument:document toFolder:folder];
                                                    });
                                                    
                                                    return;
                                                }
                                            }
                                            
                                            [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                            
                                            [UIAlertView showWithTitle:error.errorTitle
                                                               message:[error localizedDescription]
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@[error.okButtonTitle]
                                                              tapBlock:error.tapBlock];
        }];
}

- (void)deleteDocuments
{
    for (NSIndexPath *indexPathOfSelectedRow in [self.tableView indexPathsForSelectedRows]) {
        POSDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPathOfSelectedRow];
        [self deleteDocument:document];
    }
    [self deselectAllRows];
    [self updateToolbarButtonItems];
}

- (void)deleteDocument:(POSDocument *)document
{
    [[POSAPIManager sharedManager] deleteDocument:document
        withSuccess:^{
                                          [self updateFetchedResultsController];
                                          
                                          [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                          
                                          if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                              
                                              POSDocument *currentOpenDocument = ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment.document;
                                              if ([currentOpenDocument isEqual:document]){
                                                  ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = nil;
                                              }
                                          }
        }
        failure:^(NSError *error) {
                                              NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                  if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                      // We were unauthorized, due to the session being invalid.
                                                      // Let's retry in the next run loop
                                                      [self performSelector:@selector(deleteDocument:) withObject:document afterDelay:0.0];
                                                      
                                                      return;
                                                  }
                                              }
                                              
                                              [self showTableViewBackgroundView:([self numberOfRows] == 0)];
                                              
                                              [UIAlertView showWithTitle:error.errorTitle
                                                                 message:[error localizedDescription]
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@[error.okButtonTitle]
                                                                tapBlock:error.tapBlock];
        }];
}

- (BOOL)documentsNeedCurrentBankAccount
{
    NSManagedObjectContext *managedObjectContext = [POSModelManager sharedManager].managedObjectContext;

    NSArray *alldocuments = [POSDocument allDocumentsInFolderWithName:self.folderName
                                               mailboxDigipostAddress:self.mailboxDigipostAddress
                                               inManagedObjectContext:managedObjectContext];
    for (POSDocument *document in alldocuments) {
        for (POSAttachment *attachment in document.attachments) {
            if (attachment.invoice && [attachment.invoice.canBePaidByUser boolValue] && [attachment.invoice.sendToBankUri length] > 0) {
                return YES;
            }
        }
    }

    return NO;
}

- (void)updateCurrentBankAccountWithUri:(NSString *)uri
{
    if ([POSAPIManager sharedManager].isUpdatingBankAccount) {
        return;
    }

    [[POSAPIManager sharedManager] updateBankAccountWithUri:uri
                                                    success:nil
                                                    failure:^(NSError *error) {
                                                        
                                                        NSHTTPURLResponse *response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
                                                        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                            if ([[POSAPIManager sharedManager] responseCodeIsUnauthorized:response]) {
                                                                // We were unauthorized, due to the session being invalid.
                                                                // Let's retry in the next run loop
                                                                double delayInSeconds = 0.0;
                                                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                                    [self updateCurrentBankAccountWithUri:uri];
                                                                });
                                                                
                                                                return;
                                                            }
                                                        }
                                                        
                                                        [UIAlertView showWithTitle:error.errorTitle
                                                                           message:[error localizedDescription]
                                                                 cancelButtonTitle:nil
                                                                 otherButtonTitles:@[error.okButtonTitle]
                                                                          tapBlock:error.tapBlock];
                                                    }];
}

- (void)uploadProgressDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Don't do anything if this view controller isn't visible
        if (!(self.isViewLoaded && self.view.window)) {
            return;
        }
        
        // Try to find our upload cell
        POSUploadTableViewCell *uploadCell = nil;
        
        for (UITableViewCell *cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[POSUploadTableViewCell class]]) {
                uploadCell = (POSUploadTableViewCell *)cell;
                break;
            }
        }
        
        if (uploadCell) {
            uploadCell.progressView.progress = [POSAPIManager sharedManager].uploadProgress.fractionCompleted;
        } else {
            // We've not found the upload cell - let's check if the topmost cell is visible.
            // If it is, that means we're missing the upload cell and we need to insert it.
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if ([[self.tableView indexPathsForVisibleRows] containsObject:firstIndexPath]) {
                [self.tableView reloadData];
            }
        }
    });
}

- (void)uploadProgressDidFinish:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Don't do anything if this view controller isn't visible
        if (!(self.isViewLoaded && self.view.window)) {
            return;
        }
        [self updateContentsFromServerUserInitiatedRequest:@NO];
    });
}

- (void)showTableViewBackgroundView:(BOOL)showTableViewBackgroundView
{
    if (!self.tableViewBackgroundView.superview && showTableViewBackgroundView) {
        self.tableView.backgroundView = self.tableViewBackgroundView;

        self.noDocumentsLabel.text = NSLocalizedString(@"DOCUMENTS_VIEW_CONTROLLER_NO_DOCUMENTS_TITLE", @"You have no documents in this folder.");
    }

    self.tableViewBackgroundView.hidden = !showTableViewBackgroundView;
}

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController
{
    // todo do stuff here when authenticated
}

@end
