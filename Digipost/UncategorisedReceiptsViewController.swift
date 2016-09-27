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

class UncategorisedReceiptsViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var searchField: UITextField!
    
    static let pushReceiptIdentifier = "PushReceipt"
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(white: 0.4, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(UncategorisedReceiptsViewController.pullToRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    var receiptsTableViewDataSource: UncategorisedReceiptsTableViewDataSource!;
    
    var mailboxDigipostAddress: String = "";
    var receiptsUri: String = "";
    var numberOfReceiptsChangedUponLastUpdate: Bool! = true;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectionBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", comment: "Select all")
        self.deleteBarButtonItem.title = NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_DELETE_TITLE", comment: "Delete")
        self.navigationItem.title = "Receipts"
        self.receiptsTableViewDataSource = UncategorisedReceiptsTableViewDataSource.init(asDataSourceForTableView: self.tableView)
        self.tableView.delegate = self;
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.refreshControl.initializeRefreshControlText()
        self.refreshControl.updateRefreshControlTextRefreshing(true)
        
        self.refreshControl.beginRefreshing()
        self.refreshControl.endRefreshing()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchReceiptsFromAPI()
        self.setupTableViewStyling()
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if((self.tableView.indexPathForSelectedRow) != nil) {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }
        self.navigationController!.toolbar.barTintColor = UIColor.digipostSpaceGrey()
    }
    
    func pullToRefresh() {
        print("Pull to refresh")
        fetchReceiptsFromAPI()
        self.numberOfReceiptsChangedUponLastUpdate = true
    }
    
    func fetchReceiptsFromAPI() {
        print("Attempting to fetch data...")
        
        var fetchedReceipts: [POSReceipt] = []
        
        // completion methods
        func setFetchedObjects(APICallResult: Dictionary<String,AnyObject>){
            self.receiptsTableViewDataSource.receipts = parseReceiptsFrom(APICallResult["receipt"]!) // set in success method as it's called asynchronously
            print("Successfully fetched receipts.")
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        func f(e: APIError){ print(e.altertMessage) }
                
        let parameters : Dictionary<String,String> = {
            ["skip": "2", "take": "2"];
        }()
        
        APIClient.sharedClient.updateReceiptsInMailboxWithDigipostAddress(self.mailboxDigipostAddress, uri: self.receiptsUri, parameters: parameters, success: setFetchedObjects, failure: f)
    }
    
    func parseReceiptsFrom(APICallReceiptResult: AnyObject) -> Array<POSReceipt>{
        var receiptList:Array<POSReceipt> = []
        
        let managedObjectContext = POSModelManager.sharedManager().managedObjectContext

        for index in 0...(APICallReceiptResult.count-1 /* 0-indexed */) {
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
        
        if(self.numberOfReceiptsChangedUponLastUpdate &&
                !self.refreshControl.refreshing &&
                scrollOffset + scrollViewHeight >= 0.8 * scrollViewContentSizeHeight) {
            print("Debug: scrollViewDidScroll update") // <- DEBUG
            loadAdditionalReceipts()
        }
    }
    
    func loadAdditionalReceipts() {
        let previousNumberOfReceipts = self.receiptsTableViewDataSource.receipts.count
        self.fetchReceiptsFromAPI()  // this needs to be refactored to get(skip: receipts.count, take: default)
        let updatedNumberOfReceipts = self.receiptsTableViewDataSource.receipts.count
        
        self.numberOfReceiptsChangedUponLastUpdate = (previousNumberOfReceipts == updatedNumberOfReceipts) ? false : true;
    }
    
    func setupTableViewStyling() {
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160;
        self.tableView.backgroundView = nil
        self.tableView.separatorColor = UIColor.digipostDocumentListDivider()
        self.tableView.backgroundColor = UIColor.digipostDocumentListBackground()
        
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if(self.editing) {
            return false;
        }
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == UncategorisedReceiptsViewController.pushReceiptIdentifier){
            let receipt: POSReceipt = self.receiptsTableViewDataSource.receiptAtIndexPath(self.tableView.indexPathForSelectedRow!)
            let letterViewController: POSLetterViewController = segue.destinationViewController as! POSLetterViewController
            letterViewController.receiptsViewController = self
            letterViewController.receipt = receipt
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.navigationController?.setToolbarHidden(!editing, animated: animated)
        self.updateToolbarButtonItems()
        
        self.tableView.setEditing(editing, animated: animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = !editing
        
        NSNotificationCenter.defaultCenter().postNotificationName(kDocumentsViewEditingStatusChangedNotificationName, object: self, userInfo: [kEditingStatusKey : NSNumber(bool: editing)])
    }
    
    @IBAction func didTapSelectionBarButtonItem(barButtonItem: UIBarButtonItem) {
        if(thereAreSelectedRows() ) {
            self.deselectAllRows()
        } else {
            self.selectAllRows()
        }
    }
    
    @IBAction func didTapDeleteBarButtonItem(barButtonItem: UIBarButtonItem) {
        let numberOfReceipts = self.tableView.indexPathsForSelectedRows!.count
        let receiptWord = numberOfReceipts == 1 ?
            NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_SINGULAR", comment: "receipt") :
            NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_TWO_PLURAL", comment: "receipt");
        
        let deleteString = String.init(format: "%@ %lu %@", NSLocalizedString("DOCUMENTS_VIEW_CONTROLLER_DELETE_CONFIRMATION_ONE", comment: "Delete"), self.tableView.indexPathsForSelectedRows!.count, receiptWord)
        
        let registrationAlertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        func handler(action: UIAlertAction){ self.deleteReceipts() }
        let open: UIAlertAction = UIAlertAction(title: deleteString, style: UIAlertActionStyle.Destructive, handler: handler)
        
        func cancelHandler(action: UIAlertAction){}
        let cancel: UIAlertAction = UIAlertAction(title: NSLocalizedString("GENERIC_CANCEL_BUTTON_TITLE", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: cancelHandler)
        
        registrationAlertController.addAction(open)
        registrationAlertController.addAction(cancel)
        
        self.presentViewController(registrationAlertController, animated: true, completion: nil)
    }
    
    func selectAllRows(){
        for rowIndex in self.tableView.indexPathsForVisibleRows! {
            self.tableView.selectRowAtIndexPath(rowIndex, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    func deselectAllRows(){
        for rowIndex in self.tableView.indexPathsForVisibleRows! {
            self.tableView.cellForRowAtIndexPath(rowIndex)!.selectionStyle = UITableViewCellSelectionStyle.Default
            self.tableView.deselectRowAtIndexPath(rowIndex, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.updateToolbarButtonItems()
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.updateToolbarButtonItems()
        }
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
        print("In deleteReceipts()...")
        
    }
}
