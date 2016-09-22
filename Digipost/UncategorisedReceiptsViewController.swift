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
    
    @IBOutlet weak var searchButton: UIButton!
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
        
        self.selectionBarButtonItem.title = LocalizedString("DOCUMENTS_VIEW_CONTROLLER_TOOLBAR_SELECT_ALL_TITLE", tableName: "", comment: "Select all")
        
        self.navigationItem.title = "Receipts"
        self.receiptsTableViewDataSource = UncategorisedReceiptsTableViewDataSource.init(asDataSourceForTableView: self.tableView)
//        self.receiptsTableViewDataSource!.storeName = ""
        self.tableView.delegate = self;
        
        // ignore table view styling for now(?)
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl!.initializeRefreshControlText()
        self.refreshControl!.updateRefreshControlTextRefreshing(true)
        self.refreshControl!.tintColor = UIColor.init(white: 0.4, alpha: 1.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setToolbarHidden(true, animated: false)
        
        self.setupTableViewStyling()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if((self.tableView.indexPathForSelectedRow) != nil) {
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }
        self.navigationController!.toolbar.barTintColor = UIColor.digipostSpaceGrey()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !self.isEditing;
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == kPushReceiptIdentifier){
            let receipt: POSReceipt = self.receiptsTableViewDataSource.receiptAtIndexPath(self.tableView.indexPathForSelectedRow!)
            let letterViewController: POSLetterViewController = segue.destinationViewController as! POSLetterViewController;
//            letterViewController.receiptsViewController = self as UncategorisedReceiptsViewController; // for now, unset, implementing rendering of table in GUI first
            letterViewController.receipt = receipt;
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func didTapSelectionBarButtonItem(barButtonItem: UIBarButtonItem) {
        // select, deselect, update toolbar
    }
    
    func didTapDeleteBarButtonItem(barButtonItem: UIBarButtonItem) {
        // delete receipt(s), etc.
    }
    
    func deleteReceipt(receipt: POSReceipt) {
        
    }
    
    func selectAllRows(){
        
    }
    
    func deselectAllRows(){
        
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
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None;
    }
}
