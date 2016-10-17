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

class ReceiptsViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var receiptsTableViewDataSource: ReceiptsTableViewDataSource!
    
    @IBOutlet weak var selectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    static let pushReceiptIdentifier = "PushReceipt"
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    var idParameterName: String = "chain_id"
    var mailboxDigipostAddress: String = ""
    var receiptsUri: String = ""
    var receiptCategoryId: String = ""
    var receiptCategoryName: String = ""
    var numberOfReceiptsChangedUponLastUpdate: Bool! = false
    
    var lockForFetchingReceipts: NSLock = NSLock() // mutex for avoiding duplicate calls of receipt-fetching
    var hasReturnedFromAsyncFetch: Bool = true
    var pullToRefreshIsRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectionBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", comment: "Select all")
        self.deleteBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_DELETE_TITLE", comment: "Delete")
        self.navigationItem.title = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NAVBAR_TITLE", comment: "Receipts")
        self.receiptsTableViewDataSource = ReceiptsTableViewDataSource.init(asDataSourceForTableView: self.tableView)
        self.tableView.delegate = self
        self.searchBar.delegate = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.refreshControl.initializeRefreshControlText()
        self.refreshControl.attributedTitle = NSAttributedString(string: "placeholder", attributes: [NSForegroundColorAttributeName : UIColor(white: 0.4, alpha: 1.0)])
        self.refreshControl.updateRefreshControlTextRefreshing(false)  // false to get the last updated label
        self.refreshControl.tintColor = UIColor(white: 0.4, alpha: 1.0)
        
        self.refreshControl.beginRefreshing()
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        trySynchronized(self.lockForFetchingReceipts, criticalSection: self.fetchReceiptsFromAPI)
        self.setupTableViewStyling()
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if((self.tableView.indexPathForSelectedRow) != nil) {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }
        self.navigationController!.toolbar.barTintColor = UIColor.digipostSpaceGrey()
        self.updateNavbar()
    }
    
    func pullToRefresh(calledRecursively calledRecursivelyOnce: Bool = false) {
        self.pullToRefreshIsRunning = true
        self.searchBar.text = ""
        hideKeyboardIfVisible()
        
        if(self.hasReturnedFromAsyncFetch){
            // Waits for lock and executes the reset:
            synchronized(self.lockForFetchingReceipts, criticalSection: self.resetDataStructuresAndPerformFetchFromAPIWithNoSkip)
        }
    }
    
    func resetDataStructuresAndPerformFetchFromAPIWithNoSkip(){
        
        func setReceipts(APICallResult: Dictionary<String,AnyObject>){
            self.receiptsTableViewDataSource.receipts = self.parseReceiptsFrom(APICallResult["receipt"]!)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.hasReturnedFromAsyncFetch = true
            self.pullToRefreshIsRunning = false
            self.numberOfReceiptsChangedUponLastUpdate = true
            self.updateNavbar()
            self.updateToolbarButtonItems()
        }
        func f(e: APIError){
            self.refreshControl.endRefreshing()
            self.numberOfReceiptsChangedUponLastUpdate = false
            self.hasReturnedFromAsyncFetch = true
            print(e.altertMessage)
            self.updateNavbar()
            self.updateToolbarButtonItems()
        }
        APIClient.sharedClient.fetchReceiptsInMailboxWith(parameters: [self.idParameterName : self.receiptCategoryId, "skip": String(0)],
                                                                     digipostAddress: self.mailboxDigipostAddress, uri: self.receiptsUri,
                                                                     success: setReceipts, failure: f)
    }
    
    func fetchReceiptsFromAPI() {
        
        if(self.hasReturnedFromAsyncFetch && !pullToRefreshIsRunning) {
            self.hasReturnedFromAsyncFetch = false
            // Completion method run upon GET-success
            // Note that this functions as a callback after receipts have been retrieved through the API.
            func setFetchedObjects(APICallResult: Dictionary<String,AnyObject>){
                let previouslySelectedIndexPaths: [NSIndexPath] = self.getIndexPathsForSelectedCells()
                
                let fetchedReceipts: [POSReceipt] = parseReceiptsFrom(APICallResult["receipt"]!)
                self.receiptsTableViewDataSource.receipts += fetchedReceipts
                
                self.numberOfReceiptsChangedUponLastUpdate = (fetchedReceipts.count > 0)
                if(self.numberOfReceiptsChangedUponLastUpdate!) {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    
                    self.selectCellsFor(previouslySelectedIndexPaths)
                }
                
                self.updateNavbar()
                self.updateToolbarButtonItems()
                self.hasReturnedFromAsyncFetch = true
            }
            func f(e: APIError){
                self.numberOfReceiptsChangedUponLastUpdate = false
                self.hasReturnedFromAsyncFetch = true
                print(e.altertMessage)
                self.updateNavbar()
                self.updateToolbarButtonItems()
            }
            
            var parameters = [self.idParameterName: self.receiptCategoryId, "skip": String(self.receiptsTableViewDataSource.receipts.count)]
            if(self.searchBar.text != nil && self.searchBar.text!.length > 0) {
               parameters["search"] = self.searchBar.text!
            }
            
            APIClient.sharedClient.fetchReceiptsInMailboxWith(parameters: parameters, digipostAddress: self.mailboxDigipostAddress,
                                                              uri: self.receiptsUri, success: setFetchedObjects, failure: f)
        }
    }

    func parseReceiptsFrom(APICallReceiptResult: AnyObject) -> Array<POSReceipt>{
        if(APICallReceiptResult.count == 0) {
            return []
        }
        
        var receiptList:Array<POSReceipt> = []
        
        let managedObjectContext = POSModelManager.sharedManager().managedObjectContext

        for index in 0..<APICallReceiptResult.count /* 0-indexed */ {
            var receiptAttributes: Dictionary<String, AnyObject> = Dictionary<String,AnyObject>()
            
            for receiptFieldKey in APICallReceiptResult[index].allKeys {
                receiptAttributes[receiptFieldKey as! String] = APICallReceiptResult[index][receiptFieldKey as! String]
            }
            
            receiptList.append(POSReceipt.init(attributes: receiptAttributes, inManagedObjectContext: managedObjectContext))
        }
        
        return receiptList
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollViewContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        
        if(self.numberOfReceiptsChangedUponLastUpdate && hasReturnedFromAsyncFetch && !self.pullToRefreshIsRunning &&
            scrollOffset + scrollViewHeight >= 0.8 * scrollViewContentSizeHeight) {
            trySynchronized(self.lockForFetchingReceipts, criticalSection: self.fetchReceiptsFromAPI)
        }
    }
    
    func setupTableViewStyling() {
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160;
        self.tableView.backgroundView = nil
        self.tableView.separatorColor = UIColor.digipostDocumentListDivider()
        self.tableView.backgroundColor = UIColor.digipostDocumentListBackground()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92;
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 20;
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        hideKeyboardIfVisible()
        if(segue.identifier == ReceiptsViewController.pushReceiptIdentifier){
            let receipt: POSReceipt = self.receiptsTableViewDataSource.receiptAtIndexPath(self.tableView.indexPathForSelectedRow!)
            let letterViewController: POSLetterViewController = segue.destinationViewController as! POSLetterViewController
            letterViewController.receiptsViewController = self
            letterViewController.receipt = receipt
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.navigationController?.setToolbarHidden(!editing, animated: animated)
        
        self.tableView.setEditing(editing, animated: animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = !editing
        
        NSNotificationCenter.defaultCenter().postNotificationName(kDocumentsViewEditingStatusChangedNotificationName, object: self, userInfo: [kEditingStatusKey : NSNumber(bool: editing)])
        self.updateNavbar()
        self.updateToolbarButtonItems()
    }
    
    @IBAction func didTapSelectionBarButtonItem(barButtonItem: UIBarButtonItem) {
        if(thereAreSelectedRows() ) {
            self.deselectAllRows()
        } else {
            self.selectAllRows()
        }
        self.updateToolbarButtonItems()
    }
    
    @IBAction func didTapDeleteBarButtonItem(barButtonItem: UIBarButtonItem) {
        let numberOfReceipts = self.tableView.indexPathsForSelectedRows!.count
        let receiptWord = numberOfReceipts == 1 ?
            NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_SINGULAR", comment: "receipt") :
            NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_PLURAL", comment: "receipt")
        
        let deleteString = String.init(format: "%@ %lu %@", NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_ONE", comment: "Delete"), self.tableView.indexPathsForSelectedRows!.count, receiptWord)
        
        let registrationAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        func handler(action: UIAlertAction){ self.deleteReceipts() }
        let open: UIAlertAction = UIAlertAction(title: deleteString, style: UIAlertActionStyle.Destructive, handler: handler)
        
        func cancelHandler(action: UIAlertAction){}
        let cancel: UIAlertAction = UIAlertAction(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: cancelHandler)
        
        registrationAlertController.addAction(open)
        registrationAlertController.addAction(cancel)
        
        self.presentViewController(registrationAlertController, animated: true, completion: nil)
        self.updateToolbarButtonItems()
    }
    
    func selectAllRows(){
        for rowIndex in 0...self.tableView.numberOfRowsInSection(0) {  // as we only operate with one section
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: rowIndex, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    func hideKeyboardIfVisible(){
        searchBar.endEditing(true)
    }
    
    func deselectAllRows(){
        if(self.tableView.indexPathsForSelectedRows == nil){
            return
        }
        
        for selectedIndexPath in self.tableView.indexPathsForSelectedRows! {
            self.tableView.cellForRowAtIndexPath(selectedIndexPath)?.selectionStyle = UITableViewCellSelectionStyle.Default
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }
    
    func getIndexPathsForSelectedCells() -> [NSIndexPath] {
        if(self.tableView.indexPathsForSelectedRows == nil){
            return []
        }
        
        // for some peculiar reason, simply using the index paths retrieved by "(..).indexPathsForSelectedRows" returns an additional index path
        var indexPaths = self.tableView.indexPathsForSelectedRows!
        indexPaths.removeLast()
        return indexPaths
    }
    
    func selectCellsFor(indexPaths: [NSIndexPath]) {
        for indexPathForSelectedRow in indexPaths {
            self.tableView.selectRowAtIndexPath(indexPathForSelectedRow, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.updateToolbarButtonItems()
            return
        }
        
        let receipt: POSReceipt = self.receiptsTableViewDataSource.receipts[indexPath.row]
        
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
            let appDelegate: SHCAppDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
            appDelegate.letterViewController.receipt = receipt
        } else {
            self.performSegueWithIdentifier(kPushReceiptIdentifier, sender: receipt)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.updateToolbarButtonItems()
        }
    }
    
    func updateNavbar() {
        if(self.tableView.numberOfRowsInSection(0) > 0 ){
            self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.editButtonItem()
        }
        self.navigationController?.navigationBar.topItem!.title = receiptCategoryName;
    }
    
    func updateToolbarButtonItems(){
        if(thereAreSelectedRows() ) {
            self.deleteBarButtonItem.enabled = true
            self.selectionBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_NONE_TITLE", comment: "Select none");
        } else {
            self.deleteBarButtonItem.enabled = false
            self.selectionBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", comment: "Select all");
        }
    }
    
    func thereAreSelectedRows() -> Bool {
        return self.tableView.indexPathsForSelectedRows != nil &&
            self.tableView.indexPathsForSelectedRows!.count > 0
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func deleteReceipts(){
        self.deleteBarButtonItem.enabled = false
        
        func failureToDeleteReceipt(apiError: APIError) {
            let alert = UIAlertView()
            alert.title = "Could not delete receipt"
            alert.message = "Unfortunately, an error occurred when attempting to delete the receipt(s)."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        // update GUI, then perform deletes
        var receiptsStagedForDeletion: [POSReceipt] = []
        for indexPathOfSelectedRow: NSIndexPath in self.tableView.indexPathsForSelectedRows! {
            let receiptToBeDeleted: POSReceipt = self.receiptsTableViewDataSource.receipts[indexPathOfSelectedRow.row]
            self.receiptsTableViewDataSource.receipts.removeAtIndex(indexPathOfSelectedRow.row)
            receiptsStagedForDeletion.append(receiptToBeDeleted)
        }
        self.tableView.reloadData()
        
        for receiptToBeDeleted: POSReceipt in receiptsStagedForDeletion {
            APIClient.sharedClient.deleteReceipt(receiptToBeDeleted, success: {}, failure: failureToDeleteReceipt)
        }
        
        self.deselectAllRows()
        self.tableView.reloadData()
        self.updateToolbarButtonItems()
    }
    
    // ---------- SEARCH ----------
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideKeyboardIfVisible()
        if(searchBar.text?.length > 0){
            self.receiptsTableViewDataSource.receipts.removeAll()
            self.tableView.reloadData()
            trySynchronized(self.lockForFetchingReceipts, criticalSection: self.fetchReceiptsFromAPI)
        }
    }
}
