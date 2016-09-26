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
    var isEditing: Bool! = false;
    var needsReload: Bool! = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Receipts"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        let tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = tableFooterView
        self.tableView.tableFooterView?.hidden = true
        self.tableView.backgroundColor = UIColor.digipostAccountViewBackground()
        
        self.receiptsTableViewDataSource = UncategorisedReceiptsTableViewDataSource.init(asDataSourceForTableView: self.tableView)
        self.tableView.delegate = self;
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchReceiptsFromAPI()
        self.setupTableViewStyling()
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
        
        APIClient.sharedClient.updateReceiptsInMailboxWithDigipostAddress(self.mailboxDigipostAddress, uri: self.receiptsUri, success: setFetchedObjects, failure: f)
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
            loadAdditionalReceipts()
        }
    }
    
    func loadAdditionalReceipts() {
        let previousNumberOfReceipts = self.receiptsTableViewDataSource.receipts.count
        self.fetchReceiptsFromAPI()  // this needs to be refactored to get(skip: receipts.count, take: default)
        let updatedNumberOfReceipts = self.receiptsTableViewDataSource.receipts.count
        
        self.numberOfReceiptsChangedUponLastUpdate = (previousNumberOfReceipts == updatedNumberOfReceipts) ? false : true;
    }
    
    // styling-related methods for the table-view
    func setupTableViewStyling() {
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
}
