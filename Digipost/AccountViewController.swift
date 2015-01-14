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
    
    var refreshControl: UIRefreshControl? // trengs?
    //var dataSource: POSAccountViewTableViewDataSource?
    var dataSource: AccountTableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.dataSource = POSAccountViewTableViewDataSource(asDataSourceForTableView: self.tableView)
        
        logoutBarButtonVariable = logoutBarButtonItem

        let firstVC: UIViewController = navigationController!.viewControllers[0] as UIViewController
        if firstVC.navigationItem.rightBarButtonItem == nil {
            firstVC.navigationItem.setRightBarButtonItem(logoutBarButtonItem, animated: false)
        }

        firstVC.navigationItem.leftBarButtonItem = nil
        firstVC.navigationItem.rightBarButtonItem = nil
        firstVC.navigationItem.titleView = nil
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext) {
                if rootResource == true {
                    performSegueWithIdentifier("gotoDocumentsFromAccountsSegue", sender: self)
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.registerNib(UINib(nibName: "AccountTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.Account.cellIdentifier)
        dataSource = AccountTableViewDataSource(asDataSourceForTableView: tableView)
        tableView.delegate = self

        let title = NSLocalizedString("Accounts title", comment: "Title for navbar at accounts view")
        
        if let showingItem: UINavigationItem = navigationController?.navigationBar.backItem {
            
            showingItem.hidesBackButton = true
                        
            if showingItem.respondsToSelector("setLeftBarButtonItem:") {
                showingItem.setLeftBarButtonItem(nil, animated: false)
            }
            
            if showingItem.respondsToSelector("setRightBarButtonItem:") {
                showingItem.setRightBarButtonItem(logoutBarButtonVariable, animated: false)
            }
            
            if showingItem.respondsToSelector("setBackBarButtonItem:") {
                showingItem.backBarButtonItem = nil
            }
            
            showingItem.title = title
        }

        navigationItem.setHidesBackButton(true, animated: false)
        
        navigationItem.backBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        
        navigationController?.navigationBar.topItem?.setRightBarButtonItem(logoutBarButtonItem, animated: false)
        navigationController?.navigationBar.topItem?.title = title
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateContentsFromServerUseInitiateRequest(0)
    }
    
    func updateContentsFromServerUseInitiateRequest(userDidInitiateRequest: Int) {
        POSAPIManager.sharedManager().updateRootResourceWithSuccess({ () -> Void in
            }, failure: { (error: NSError!) -> Void in
                
                let key = AFNetworkingOperationFailingURLRequestErrorKey
                if error.userInfo![key] != nil {
                    let response =  error.userInfo![key] as NSHTTPURLResponse
                    
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
        performSegueWithIdentifier("PushFolders", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushFolders" {
            let mailbox: POSMailbox = dataSource?.managedObjectAtIndexPath(tableView.indexPathForSelectedRow()!) as POSMailbox
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
        logoutUser()
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
            UIActionSheet.showFromBarButtonItem(logoutBarButtonItem, animated: true, withTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You you sure you want to sign out?"), cancelButtonTitle: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), destructiveButtonTitle: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out"), otherButtonTitles: nil, tapBlock: { (actionSheet: UIActionSheet!, buttonIndex: Int) -> Void in
                if buttonIndex == 0 {
                    self.userDidConfirmLogout()
                }
            })
        }
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.sourceView = view
    }
    
    func userDidConfirmLogout() {
        let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
            letterViewController.receipt = nil
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kShowLoginViewControllerNotificationName, object: nil)
        tableView.reloadData()
        POSAPIManager.sharedManager().logout()
    }

}
