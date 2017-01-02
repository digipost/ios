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
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: UIControlEvents.valueChanged)
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
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.refreshControl.initializeRefreshControlText()
        self.refreshControl.attributedTitle = NSAttributedString(string: "placeholder", attributes: [NSForegroundColorAttributeName : UIColor(white: 0.4, alpha: 1.0)])
        self.refreshControl.updateTextRefreshing(false)  // false to get the last updated label
        self.refreshControl.tintColor = UIColor(white: 0.4, alpha: 1.0)
        
        self.refreshControl.beginRefreshing()
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trySynchronized(self.lockForFetchingCategories, criticalSection: self.fetchAndSetCategories)
        self.setupTableViewStyling()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }
    
    func setupTableViewStyling(){
        self.tableView.insertSubview(self.refreshControl, at: 0)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160
        self.tableView.separatorColor = UIColor.digipostDocumentListDivider()
        self.tableView.backgroundColor = UIColor.digipostDocumentListBackground()
    }
    
    func showTableViewBackgroundView(_ showTableViewBackgroundView: Bool = false){
        if(showTableViewBackgroundView) {
            self.tableView.backgroundView = self.tableViewBackgroundView
        }
        
        let rootResource: POSRootResource = POSRootResource.existingRootResource(in: POSModelManager.shared().managedObjectContext)
        
        if(rootResource.numberOfCards.intValue == 0) {
            self.noReceiptsLabel.text = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_NO_CARDS_TITLE", comment: "No cards")
        } else if(rootResource.numberOfCardsReadyForVerification.intValue == 0) {
            self.noReceiptsLabel.text = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_CARDS_READY_TITLE", comment: "Cards ready")
        } else {
            let format: NSString = NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_HIDDEN_TITLE", comment: "Receipts hidden") as NSString
            let numberOfReceiptsHidden: NSInteger = rootResource.numberOfReceiptsHiddenUntilVerification.intValue
            let receiptWord = numberOfReceiptsHidden == 1 ? NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_SINGULAR", comment: "receipt is") : NSLocalizedString("RECEIPTS_VIEW_CONTROLLER_NO_RECEIPTS_RECEIPT_WORD_IS_PLURAL", comment: "receipts are")
            self.noReceiptsLabel.text = NSString.init(format: format, numberOfReceiptsHidden, receiptWord) as String
        }
        
        self.tableViewBackgroundView.isHidden = !showTableViewBackgroundView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(tableView.responds(to: #selector(setter: UITableViewCell.separatorInset))){
            tableView.separatorInset = UIEdgeInsets.zero
        }
        
        if(tableView.responds(to: #selector(setter: UIView.layoutMargins))){
            tableView.layoutMargins = UIEdgeInsets.zero
        }
        
        if(cell.responds(to: #selector(setter: UIView.layoutMargins))){
            cell.layoutMargins = UIEdgeInsets.zero
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
            
            func updateCategoriesAndViewUponSuccess(_ APICallResult: Dictionary<String,AnyObject>){
                let fetchedResults = parseAndBuildCategoryTableViewCellArrayFrom(APICallResult["chains"]!)
                self.receiptsTableViewDataSource.categories = fetchedResults
                self.showTableViewBackgroundView(fetchedResults.count == 0)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                self.isFetchingCategories = false
            }
            func f(_ e: APIError){
                print("APIError: ", e)
                self.refreshControl.endRefreshing()
                self.showTableViewBackgroundView(true)
                self.isFetchingCategories = false
            }
            
            APIClient.sharedClient.fetchReceiptCategoriesInMailbox(self.mailboxDigipostAddress, uri: self.receiptsMetadataUri, success: updateCategoriesAndViewUponSuccess, failure: f)
        }
    }
    
    func parseAndBuildCategoryTableViewCellArrayFrom(_ APICallReceiptResult: AnyObject) -> Array<ReceiptCategory>{
        if(APICallReceiptResult.count == 0) {
            return []
        }
        var categoryList:Array<ReceiptCategory> = []
        
        for index in 0..<APICallReceiptResult.count /* 0-indexed */ {
            let subResult = APICallReceiptResult[index] as! [String: AnyObject]
            let count: Int = subResult["count"] as! Int
            let category: String = subResult["name"] as! String
            let chain_id: String = subResult["id"] as! String
            categoryList.append(ReceiptCategory(count: count, category: category, chain_id: chain_id))
        }
        
        return categoryList
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let receiptCategory: ReceiptCategory = self.receiptsTableViewDataSource.categories[indexPath.row]
        self.performSegue(withIdentifier: ReceiptCategoryViewController.pushReceiptsInCategoryIdentifier, sender: receiptCategory)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        refreshControl.endRefreshing()
        if(segue.identifier == ReceiptCategoryViewController.pushReceiptsInCategoryIdentifier){
            let category: ReceiptCategory = self.receiptsTableViewDataSource.categoryAtIndexPath(self.tableView.indexPathForSelectedRow!)
            let receiptsViewController: ReceiptsViewController = segue.destination as! ReceiptsViewController
            receiptsViewController.mailboxDigipostAddress = self.mailboxDigipostAddress
            receiptsViewController.receiptsUri = self.receiptsUri
            receiptsViewController.receiptCategoryId = category.chain_id
            receiptsViewController.receiptCategoryName = category.category
        }
    }
}
