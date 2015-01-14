//
//  AccountViewController.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-01-13.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem!
    
    var logoutBarButtonVariable: UIBarButtonItem?
    
    var refreshControl: UIRefreshControl?
    //var dataSource: POSAccountViewTableViewDataSource?
    var dataSource: AccountTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.dataSource = POSAccountViewTableViewDataSource(asDataSourceForTableView: self.tableView)
        self.tableView.registerNib(UINib(nibName: "AccountTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.cellIdentifier)
        self.dataSource = AccountTableViewDataSource(asDataSourceForTableView: tableView)
        self.tableView.delegate = self
        self.logoutBarButtonVariable = self.logoutBarButtonItem
        
        let firstVC: UIViewController = self.navigationController!.viewControllers[0] as UIViewController
        
        if firstVC.navigationItem.rightBarButtonItem == nil {
            firstVC.navigationItem.setRightBarButtonItem(self.logoutBarButtonItem, animated: false)
        }

        firstVC.navigationItem.leftBarButtonItem = nil
        firstVC.navigationItem.rightBarButtonItem = nil
        
        firstVC.navigationItem.titleView = nil
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext) {
                if rootResource == true {
                    self.performSegueWithIdentifier("gotoDocumentsFromAccountsSegue", sender: self)
                }
            }
            
        }
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let title = NSLocalizedString("Accounts title", comment: "Title for navbar at accounts view")
        
        if let showingItem: UINavigationItem = self.navigationController?.navigationBar.backItem {
            
            showingItem.hidesBackButton = true
                        
            if showingItem.respondsToSelector("setLeftBarButtonItem:") {
                showingItem.setLeftBarButtonItem(nil, animated: false)
            }
            
            if showingItem.respondsToSelector("setRightBarButtonItem:") {
                showingItem.setRightBarButtonItem(self.logoutBarButtonVariable, animated: false)
            }
            
            if showingItem.respondsToSelector("setBackBarButtonItem:") {
                showingItem.backBarButtonItem = nil
            }
            
            showingItem.title = title
        }

        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItem(self.logoutBarButtonItem, animated: false)
        self.navigationController?.navigationBar.topItem?.title = title
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateContentsFromServerUseInitiateRequest(0)
    }
    
    func updateContentsFromServerUseInitiateRequest(userDidInitiateRequest: Int) {
        POSAPIManager.sharedManager().updateRootResourceWithSuccess({ () -> Void in
            }, failure: { (error: NSError!) -> Void in
                
                if let e = error {
                    let key = AFNetworkingOperationFailingURLRequestErrorKey
                    
                    let response =  e.userInfo![key] as NSHTTPURLResponse
                    
                    if response.isKindOfClass(NSHTTPURLResponse) {
                        if (POSAPIManager.sharedManager().responseCodeIsUnauthorized(response)) {
                            NSTimer.scheduledTimerWithTimeInterval(0.0, target: userDidInitiateRequest, selector: "updateContentsFromServerUserInitiatedRequest:", userInfo: nil, repeats: false)
                            return
                        }
                    }
                }
        })
        
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("PushFolders", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushFolders" {
            let mailbox: POSMailbox = self.dataSource?.managedObjectAtIndexPath(self.tableView.indexPathForSelectedRow()!) as POSMailbox
            let folderViewController: POSFoldersViewController = segue.destinationViewController as POSFoldersViewController
            folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress
            POSModelManager.sharedManager().selectedMailboxDigipostAddress = mailbox.digipostAddress
        } else if segue.identifier == "gotoDocumentsFromAccountsSegue" {
            let documentsView: POSDocumentsViewController = segue.destinationViewController as POSDocumentsViewController
            let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
            let nameDescriptor: NSSortDescriptor = NSSortDescriptor(key: "owner", ascending: true)
            let mailboxes: NSArray = rootResource.mailboxes.sortedArrayUsingDescriptors([nameDescriptor])
            
            let userMailbox: POSMailbox = mailboxes[0] as POSMailbox
            documentsView.mailboxDigipostAddress = userMailbox.digipostAddress
            documentsView.folderName = kFolderInboxName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        self.logoutUser()
    }
    
    // MARK: - Logout
    
    func logoutUser() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIAlertView.showWithTitle(NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), message: "", cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), otherButtonTitles:[NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out")], tapBlock: { (alert: UIAlertView!, buttonIndex: Int) -> Void in
                if buttonIndex == 1 {
                    self.userDidConfirmLogout()
                }
                
            })
            
        } else {
            UIActionSheet.showFromBarButtonItem(self.logoutBarButtonItem, animated: true, withTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), destructiveButtonTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out"), otherButtonTitles: nil, tapBlock: { (actionSheet: UIActionSheet!, buttonIndex: Int) -> Void in
                if buttonIndex == 0 {
                    self.userDidConfirmLogout()
                }
            })
        }
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.sourceView = self.view
    }
    
    func userDidConfirmLogout() {
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
            letterViewController.receipt = nil
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil)
        self.tableView.reloadData()
        POSAPIManager.sharedManager().logout()
    }

}
