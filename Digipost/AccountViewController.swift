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
                firstVC.navigationItem.setRightBarButton(logoutBarButtonItem, animated: false)
            }
            firstVC.navigationItem.leftBarButtonItem = nil
            firstVC.navigationItem.rightBarButtonItem = nil
            firstVC.navigationItem.titleView = nil
            
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext) != nil{
                performSegue(withIdentifier: "gotoDocumentsFromAccountsSegue", sender: self)
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.digipostGreyOne()
        refreshControl?.addTarget(self, action: #selector(AccountViewController.refreshContentFromServer), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        // Configure Tableview
        
        tableView.register(UINib(nibName: Constants.Account.mainAccountCellNibName, bundle: Bundle.main), forCellReuseIdentifier: Constants.Account.mainAccountCellIdentifier)
        tableView.register(UINib(nibName: Constants.Account.accountCellNibName, bundle: Bundle.main), forCellReuseIdentifier: Constants.Account.accountCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        let tblView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.isHidden = true
        tableView.backgroundColor = UIColor.digipostAccountViewBackground()
        
        dataSource = AccountTableViewDataSource(asDataSourceForTableView: tableView)
        tableView.delegate = self
        
        let appDelegate: SHCAppDelegate = UIApplication.shared.delegate as! SHCAppDelegate
        appDelegate.initGCM();
    }
    
    @objc func refreshContentFromServer() {
        updateContentsFromServerUseInitiateRequest(0)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
        
        let title = NSLocalizedString("Accounts title", comment: "Title for navbar at accounts view")
        navigationController?.navigationBar.topItem?.title = title
        
        logoutButtonVariable?.setTitle(NSLocalizedString("log out button title", comment: "Title for log out button"), for: UIControlState())
        logoutButtonVariable?.setTitleColor(UIColor.digipostLogoutButtonTextColor(), for: UIControlState())
        logoutBarButtonItem.accessibilityTraits = UIAccessibilityTraitButton
        
        if let showingItem: UINavigationItem = navigationController?.navigationBar.backItem {
            if showingItem.responds(to: #selector(setter: UINavigationItem.rightBarButtonItem)) {
                showingItem.setRightBarButton(logoutBarButtonVariable, animated: false)
            }
            
            showingItem.title = title
        }
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.topItem?.setRightBarButton(logoutBarButtonItem, animated: false)
        
        
        if OAuthToken.isUserLoggedIn(){
            updateContentsFromServerUseInitiateRequest(0)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kShowLoginViewControllerNotificationName), object: nil)
        }
    }
    
    func updateContentsFromServerUseInitiateRequest(_ userDidInitiateRequest: Int) {
    
        APIClient.sharedClient.updateRootResource(success: { (responseDictionary) -> Void in
            POSModelManager.shared().updateRootResource(attributes: responseDictionary)
            if let actualRefreshControl = self.refreshControl {
                actualRefreshControl.endRefreshing()
            }
        }) { (error) -> () in
            if (userDidInitiateRequest == 1) {
                UIAlertController.presentAlertControllerWithAPIError(error, presentingViewController: self, didTapOkClosure: nil)
            }
            
            if let actualRefreshControl = self.refreshControl {
                actualRefreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
        performSegue(withIdentifier: "PushFolders", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.contentView.backgroundColor = UIColor.digipostAccountCellSelectBackground()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushFolders" {
            let mailbox: POSMailbox = dataSource?.managedObjectAtIndexPath(tableView.indexPathForSelectedRow!) as! POSMailbox
            let folderViewController: POSFoldersViewController = segue.destination as! POSFoldersViewController
            folderViewController.selectedMailBoxDigipostAdress = mailbox.digipostAddress
            POSModelManager.shared().selectedMailboxDigipostAddress = mailbox.digipostAddress
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
            
        } else if segue.identifier == "gotoDocumentsFromAccountsSegue" {
            let documentsView: POSDocumentsViewController = segue.destination as! POSDocumentsViewController
            let rootResource: POSRootResource = POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext)
            let nameDescriptor: NSSortDescriptor = NSSortDescriptor(key: "owner", ascending: true)
            
            let set = rootResource.mailboxes as NSSet
            let mailboxes = set.allObjects as NSArray
            mailboxes.sortedArray(using: [nameDescriptor])
            
            let userMailbox: POSMailbox = mailboxes[0] as! POSMailbox
            documentsView.mailboxDigipostAddress = userMailbox.digipostAddress
            documentsView.folderName = kFolderInboxName
        }
    }
    
    // MARK: - Logout
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logoutUser()
    }
    
    func logoutUser() {
        
        let logoutAlertController = UIAlertController(title: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_CONFIRMATION_TITLE", comment: "You sure you want to sign out?"), message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        logoutAlertController.addAction(UIAlertAction(title: NSLocalizedString("FOLDERS_VIEW_CONTROLLER_LOGOUT_TITLE", comment: "Sign out"), style: .destructive,handler: {(alert: UIAlertAction!) in
            self.userDidConfirmLogout()
        }))
        
        logoutAlertController.addAction(UIAlertAction(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in }))
        
        logoutAlertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        let popPresenter = logoutAlertController.popoverPresentationController
        popPresenter?.sourceView = self.view
        popPresenter?.barButtonItem = logoutBarButtonItem
        
        present(logoutAlertController, animated: true, completion: nil)
    }
    
    func userDidConfirmLogout() {
        let appDelegate: SHCAppDelegate = UIApplication.shared.delegate as! SHCAppDelegate
        appDelegate.revokeGCMToken();
        
        if let letterViewController: POSLetterViewController = appDelegate.letterViewController {
            letterViewController.attachment = nil
        }
        
        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        dataSource?.stopListeningToCoreDataChanges()
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kShowLoginViewControllerNotificationName), object: nil)
        }else{
            var viewControllers: [UIViewController] = []
            if (navigationController?.viewControllers[0].isKind(of: SHCLoginViewController.self))! {
                if let loginView = navigationController?.viewControllers[0] {
                    viewControllers.append(loginView)
                    navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
        }
    }
    
    
}
