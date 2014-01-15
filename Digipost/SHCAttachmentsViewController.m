//
//  SHCAttachmentsViewController.m
//  Digipost
//
//  Created by Eivind Bohler on 18.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import <UIAlertView+Blocks.h>
#import "SHCAttachmentsViewController.h"
#import "SHCAttachmentTableViewCell.h"
#import "SHCAttachment.h"
#import "SHCDocument.h"
#import "SHCAppDelegate.h"
#import "SHCLetterViewController.h"
#import "UIViewController+ValidateOpening.h"
#import "NSError+ExtraInfo.h"

// Segue identifiers (to enable programmatic triggering of segues)
NSString *const kPushAttachmentsIdentifier = @"PushAttachments";

// Google Analytics screen name
NSString *const kAttachmentsViewControllerScreenName = @"Attachments";

@interface SHCAttachmentsViewController ()

@end

@implementation SHCAttachmentsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                        0.0,
                                                                        CGRectGetWidth(self.view.frame),
                                                                        50.0)];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0,
                                                                     0.0,
                                                                     CGRectGetWidth(tableHeaderView.frame) - 30.0,
                                                                     CGRectGetHeight(tableHeaderView.frame))];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:17.0];
    headerLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];

    SHCAttachment *firstAttachment = [self.attachments firstObject];
    headerLabel.text = firstAttachment.document.creatorName;

    [tableHeaderView addSubview:headerLabel],

    self.tableView.tableHeaderView = tableHeaderView;

    // This line makes the tableview hide its separator lines for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:YES animated:NO];

    // Since this is a UITableViewController subclass, and we can't subclass the GAITrackedViewController,
    // we'll manually track and submit screen hits.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:kAttachmentsViewControllerScreenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPushLetterIdentifier]) {
        SHCAttachment *attachment = (SHCAttachment *)sender;

        SHCLetterViewController *letterViewController = (SHCLetterViewController *)segue.destinationViewController;
        letterViewController.documentsViewController = self.documentsViewController;
        letterViewController.attachment = attachment;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCAttachment *attachment = self.attachments[indexPath.row];

    SHCAttachmentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kAttachmentTableViewCellIdentifier forIndexPath:indexPath];
    
    cell.subjectLabel.text = attachment.subject;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHCAttachment *attachment = self.attachments[indexPath.row];

    [self validateOpeningAttachment:attachment success:^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            ((SHCAppDelegate *)[UIApplication sharedApplication].delegate).letterViewController.attachment = attachment;
        } else {
            [self performSegueWithIdentifier:kPushLetterIdentifier sender:attachment];
        }
    } failure:^(NSError *error) {
        [UIAlertView showWithTitle:error.errorTitle
                           message:[error localizedDescription]
                 cancelButtonTitle:nil
                 otherButtonTitles:@[error.okButtonTitle]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [tableView deselectRowAtIndexPath:indexPath animated:YES];
                          }];
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
