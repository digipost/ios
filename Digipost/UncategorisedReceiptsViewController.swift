//
//  UncategorisedReceiptsViewController.swift
//  Digipost
//
//  Created by William Berg on 21/09/16.
//  Copyright © 2016 Posten Norge AS. All rights reserved.
//

import UIKit

class UncategorisedReceiptsViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var searchField: UITextField!
    
    var refreshControl: UIRefreshControl!;
    var receiptsTableViewDataSource: UncategorisedReceiptsTableViewDataSource!;
    
    var mailboxDigipostAddress: String = "";
    var receiptsUri: String = "";
    var numberOfReceiptsChangedUponLastUpdate: Bool! = true;
    var isEditing: Bool! = false;
    var needsReload: Bool! = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Receipts"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        let tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.digipostAccountViewBackground()
        
        self.receiptsTableViewDataSource = UncategorisedReceiptsTableViewDataSource.init(asDataSourceForTableView: self.tableView)
        self.tableView.delegate = self;
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl!.initializeRefreshControlText()
        self.refreshControl!.updateRefreshControlTextRefreshing(true)
        self.refreshControl!.tintColor = UIColor.init(white: 0.4, alpha: 1.0)
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
    
    func fetchReceiptsFromAPI() {
        print("Attempting to fetch data...")
        
        var fetchedReceipts: [POSReceipt] = []
        
        func setFetchedObjects(APICallResult: Dictionary<String,AnyObject>){
            self.receiptsTableViewDataSource.receipts = parseReceiptsFrom(APICallResult["receipt"]!) // set in success method as it's called asynchronously
            print("Successfully fetched receipts.")
            self.tableView.reloadData()
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
        let scrollViewHeight: CGFloat = scrollView.frame.size.height;
        let scrollViewContentSizeHeight: CGFloat = scrollView.contentSize.height;
        let scrollOffset: CGFloat = scrollView.contentOffset.y;
        
        if(self.numberOfReceiptsChangedUponLastUpdate &&
            scrollOffset + scrollViewHeight >= 0.8 * scrollViewContentSizeHeight) {
            // load more
            loadAdditionalReceipts()
        }
    }
    
    func loadAdditionalReceipts() {
        let previousNumberOfReceipts = 0 // get from data source
        // update
        let updatedNumberOfReceipts = 0 // get from data source
        
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
