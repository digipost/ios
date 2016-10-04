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

class ReceiptCategoryViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableViewBackgroundView: UIView!
    
    @IBOutlet weak var noReceiptsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var receiptsTableViewDataSource: ReceiptCategoryTableViewDataSource!;
    
    var mailboxDigipostAddress: String = ""
    var receiptsUri: String = ""
    var receiptsMetadataUri: String = ""
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    
    var lockForFetchingCategories: NSLock = NSLock()
    var isFetchingCategories: Bool = false
    
    static let pushReceiptsInCategoryIdentifier = "PushReceiptCategory"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NAVBAR_TITLE", comment: "Receipts")
        self.receiptsTableViewDataSource = ReceiptCategoryTableViewDataSource.init(asDataSourceForTableView: self.tableView)
        self.tableView.delegate = self
        
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
        
        trySynchronized(self.lockForFetchingCategories, criticalSection: self.fetchAndSetCategories)
        self.setupTableViewStyling()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }
    
    func setupTableViewStyling(){
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160
        self.tableView.separatorColor = UIColor.digipostDocumentListDivider()
        self.tableView.backgroundColor = UIColor.digipostDocumentListBackground()
    }
    
    func showTableViewBackgroundView(showTableViewBackgroundView: Bool = false){
        if(showTableViewBackgroundView) {
            self.tableView.backgroundView = self.tableViewBackgroundView
        }
        
        let rootResource: POSRootResource = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext)
        
        if(rootResource.numberOfCards.integerValue == 0) {
            self.noReceiptsLabel.text = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_NO_CARDS_TITLE", comment: "No cards")
        } else if(rootResource.numberOfCardsReadyForVerification.integerValue == 0) {
            self.noReceiptsLabel.text = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_CARDS_READY_TITLE", comment: "Cards ready")
        } else {
            let format: NSString = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_HIDDEN_TITLE", comment: "Receipts hidden")
            let numberOfReceiptsHidden: NSInteger = rootResource.numberOfReceiptsHiddenUntilVerification.integerValue
            let receiptWord: NSString = numberOfReceiptsHidden == 1 ? NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_SINGULAR", comment: "receipt is") : NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_PLURAL", comment: "receipts are")
            self.noReceiptsLabel.text = NSString.init(format: format, numberOfReceiptsHidden, receiptWord) as String
        }
        
        self.tableViewBackgroundView.hidden = !showTableViewBackgroundView
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
    
    func pullToRefresh(){
        if(!self.isFetchingCategories) {
            trySynchronized(self.lockForFetchingCategories, criticalSection: fetchAndSetCategories)
        }
    }
    
    func fetchAndSetCategories(){
        if(!self.isFetchingCategories){
            self.isFetchingCategories = true
            
            func updateCategoriesAndViewUponSuccess(APICallResult: Dictionary<String,AnyObject>){
                let fetchedResults = parseAndBuildCategoryTableViewCellArrayFrom(APICallResult["chains"]!)
                self.receiptsTableViewDataSource.categories = fetchedResults
                self.showTableViewBackgroundView(fetchedResults.count == 0)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                self.isFetchingCategories = false
            }
            func f(e: APIError){
                print("APIError: ", e)
                self.refreshControl.endRefreshing()
                self.showTableViewBackgroundView(true)
                self.isFetchingCategories = false
            }
            
            APIClient.sharedClient.fetchReceiptCategoriesInMailbox(self.mailboxDigipostAddress, uri: self.receiptsMetadataUri, success: updateCategoriesAndViewUponSuccess, failure: f)
        }
    }
    
    func parseAndBuildCategoryTableViewCellArrayFrom(APICallReceiptResult: AnyObject) -> Array<ReceiptCategory>{
        if(APICallReceiptResult.count == 0) {
            return []
        }
        
        var categoryList:Array<ReceiptCategory> = []
        
        for index in 0..<APICallReceiptResult.count /* 0-indexed */ {
            let count = APICallReceiptResult[index]["count"] as! String
            let category = APICallReceiptResult[index]["name"] as! String
            let id = APICallReceiptResult[index]["id"] as! String
            
            categoryList.append(ReceiptCategory(count: count, category: category, id: id))
        }
        
        return categoryList
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let receiptCategory: ReceiptCategory = self.receiptsTableViewDataSource.categories[indexPath.row]
        self.performSegueWithIdentifier(ReceiptCategoryViewController.pushReceiptsInCategoryIdentifier, sender: receiptCategory)
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == ReceiptCategoryViewController.pushReceiptsInCategoryIdentifier){
            let category: ReceiptCategory = self.receiptsTableViewDataSource.categoryAtIndexPath(self.tableView.indexPathForSelectedRow!)
            let receiptsViewController: ReceiptsViewController = segue.destinationViewController as! ReceiptsViewController
            receiptsViewController.mailboxDigipostAddress = self.mailboxDigipostAddress
            receiptsViewController.receiptsUri = self.receiptsUri
            receiptsViewController.receiptCategoryId = category.id
        }
    }
}
