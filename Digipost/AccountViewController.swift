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

import UIKit

class AccountViewController: UIViewController, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem!
    
    var logoutBarButtonVariable: UIBarButtonItem?
    var logoutButtonVariable: UIButton?
    var refreshControl: UIRefreshControl?
    var dataSource: AccountTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutBarButtonVariable = logoutBarButtonItem
        logoutButtonVariable = logoutButton
        
        if let firstVC: UIViewController = navigationController?.viewControllers[0] {
            if firstVC.navigationItem.rightBarButtonItem == nil {
                firstVC.navigationItem.setRightBarButtonItem(logoutBarButtonItem, animated: false)
            }
            firstVC.navigationItem.leftBarButtonItem = nil
            firstVC.navigationItem.rightBarButtonItem = nil
            firstVC.navigationItem.titleView = nil
            
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext) {
                if rootResource == true {
                    performSegueWithIdentifier("gotoDocumentsFromAccountsSegue", sender: self)
                }
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.digipostGreyOne()
        refreshControl?.addTarget(self, action: #selector(AccountViewController.refreshContentFromServer), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Configure Tableview
        
        tableView.registerNib(UINib(nibName: Constants.Account.mainAccountCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.mainAccountCellIdentifier)
        tableView.registerNib(UINib(nibName: Constants.Account.accountCellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.accountCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        let tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.digipostAccountViewBackground()
        
        dataSource = AccountTableViewDataSource(asDataSourceForTableView: tableView)
        tableView.delegate = self
                
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
        appDelegate.initGCM();
    }
    
    func refreshContentFromServer() {
        updateContentsFromServerUseInitiateRequest(0)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBarHidden = false
        
        let title = NSLocalizedString("Accounts title", comment: "Title for navbar at accounts view")
        
        logoutButtonVariable?.setTitle(NSLocalizedString("log out button title", comment: "Title for log out button"), forState: .Normal)
        logoutButtonVariable?.setTitleColor(UIColor.digipostLogoutButtonTextColor(), forState: .Normal)
        
        if let showingItem: UINavigationItem = navigationController?.navigationBar.backItem {
            if showingItem.respondsToSelector(Selector("setRightBarButtonItem:")) {
                showingItem.setRightBarButtonItem(logoutBarButtonVariable, animated: false)
            }
            
            showingItem.title = title
        }
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.topItem?.setRightBarButtonItem(logoutBarButtonItem, animated: false)
        navigationController?.navigationBar.topItem?.title = title
        
        if OAuthToken.isUserLoggedIn() == false {
            NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil)
        } else {
            if (OAuthToken.isUserLoggedIn()) {
                updateContentsFromServerUseInitiateRequest(0)
            }
        }
    }
    
    func updateContentsFromServerUseInitiateRequest(userDidInitiateRequest: Int) {
        
        APIClient.sharedClient.updateRootResource(success: { (responseDictionary) -> Void in
            POSModelManager.sharedManager().updateRootResourceWithAttributes(responseDictionary)
            if let actualRefreshControl = self.refreshControl {
                self.refreshControl?.endRefreshing()
            }
            }) { (error) -> () in
                if (userDidInitiateRequest == 1) {
                    UIAlertController.presentAlertControllerWithAPIError(error, presentingViewController: self, didTapOkClosure: nil)
                }
                
                if let actualRefreshControl = self.refreshControl {
                    self.refreshControl?.endRefreshing()
                }
                // Notify user about error?
        }
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
        performSegueWithIdentifier("PushFolders", sender: self)
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushFolders" {
            let mailbox: POSMailbox = dataSource?.managedObjectAtIndexPath(tableView.indexPathForSelectedRow!) as! POSMailbox
            let folderViewController: POSFoldersViewController = segue.destinationViewController as! POSFoldersViewController
            folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress
            POSModelManager.sharedManager().selectedMailboxDigipostAddress = mailbox.digipostAddress
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: true)
            
        } else if segue.identifier == "gotoDocumentsFromAccountsSegue" {
            let documentsView: POSDocumentsViewController = segue.destinationViewController as! POSDocumentsViewController
            let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
            let nameDescriptor: NSSortDescriptor = NSSortDescriptor(key: "owner", ascending: true)
            
            let set = rootResource.mailboxes as NSSet
            let mailboxes = set.allObjects as NSArray
            mailboxes.sortedArrayUsingDescriptors([nameDescriptor])
            
            let userMailbox: POSMailbox = mailboxes[0] as! POSMailbox
            documentsView.mailboxDigipostAddress = userMailbox.digipostAddress
            documentsView.folderName = kFolderInboxName
        }
    }
    
    // MARK: - Logout
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        logoutUser()
    }
    
    func logoutUser() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIAlertView.showWithTitle(NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), message: "", cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), otherButtonTitles:[NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out")], tapBlock: { (alert: UIAlertView!, buttonIndex: Int) -> Void in
                if buttonIndex == 1 {
                    self.userDidConfirmLogout()
                }
            })
        } else {
            UIActionSheet.showFromBarButtonItem(logoutBarButtonItem, animated: true, withTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), destructiveButtonTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out"), otherButtonTitles: nil, tapBlock: { (actionSheet: UIActionSheet!, buttonIndex: Int) -> Void in
                if buttonIndex == 0 {
                    self.userDidConfirmLogout()
                }
            })
        }
    }
    
    func userDidConfirmLogout() {
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
        appDelegate.revokeGCMToken();
        
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
            letterViewController.receipt = nil
        }
        
        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        dataSource?.stopListeningToCoreDataChanges()
        NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil)
    }
    
    
}
