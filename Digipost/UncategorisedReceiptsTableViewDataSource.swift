//
//  UncategorisedReceiptsTableViewDataSource.swift
//  Digipost
//
//  Created by William Berg on 22/09/16.
//  Copyright © 2016 Posten Norge AS. All rights reserved.
//

import Foundation

class UncategorisedReceiptsTableViewDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    let tableView: UITableView
    var receipts: [POSReceipt] = []
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Receipt")
        let managedObjectContext: NSManagedObjectContext = POSModelManager.sharedManager().managedObjectContext
        // Order the events by creation date, most recent first.
        let timeOfPurchaseDescriptor = NSSortDescriptor(key: "timeOfPurchase", ascending: false)
        fetchRequest.sortDescriptors = [timeOfPurchaseDescriptor]
        
        var controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
        } catch let error {
            print(error)
        }
        
        return controller
    }()
    
    var numberOfReceipts: Int = 0
    
    init(asDataSourceForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        
        tableView.dataSource = self
        fetchedResultsController.delegate = self
        
//        self.tableView.registerClass(POSReceiptTableViewCell.self, forCellReuseIdentifier: "ReceiptCellIdentifier")
        self.refreshContentFromScratch()
    }
    
    func refreshContentFromScratch(){
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        var receipts: [POSReceipt] = []
        for receipt in (self.fetchedResultsController.fetchedObjects as! [POSReceipt]){
            receipts.append(receipt)
        }
        print("Woohoo! New receipts:")
        print(receipts)
        self.receipts = receipts
    }
    
    func fetchNextReceipts() {
        // for now, perform old request, but duplicate list:
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        for receipt in (self.fetchedResultsController.fetchedObjects as! [POSReceipt]){
            self.receipts.append(receipt)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receipts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: POSReceiptTableViewCell = POSReceiptTableViewCell.init()
        
        // dostuff
        let receipt: POSReceipt = self.receipts[indexPath.row]
        cell.amountLabel.text = receipt.amount.stringValue
        cell.storeNameLabel.text = receipt.storeName
        cell.dateLabel.text = POSDocument.stringForDocumentDate(receipt.timeOfPurchase)
        
        return cell
    }
    
    func receiptAtIndexPath(indexPath: NSIndexPath) -> POSReceipt {
        return self.receipts[indexPath.row]
    }
}