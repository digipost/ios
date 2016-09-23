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
    
    lazy var numberFormatter: NSNumberFormatter = {
        var numberFormatter = NSNumberFormatter()
        
        numberFormatter.currencyCode = "NOK"
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.perMillSymbol = " "
        numberFormatter.decimalSeparator = " "
        numberFormatter.groupingSize = 10
        numberFormatter.currencySymbol = "kroner"
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.locale = NSLocale.init(localeIdentifier: "nb_NO")
        
        return numberFormatter
    }()
    
    var numberOfReceipts: Int = 0
    
    init(asDataSourceForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        
        tableView.dataSource = self
        
        self.tableView.registerClass(UncategorisedReceiptsTableViewCell.self, forCellReuseIdentifier: "ReceiptTableViewCellIdentifier")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receipts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("ReceiptTableViewCellIdentifier")
        
        if(cell == nil){
            cell = UncategorisedReceiptsTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ReceiptTableViewCellIdentifier")
        }
        
        self.configureCell(cell  as! UncategorisedReceiptsTableViewCell, indexPath: indexPath)
        
        return cell!
    }
    
    func configureCell(receiptTableViewCell: UncategorisedReceiptsTableViewCell, indexPath: NSIndexPath) {
        let receipt: POSReceipt = self.receipts[indexPath.row]
        
//        print(receiptTableViewCell)
//        print(receiptTableViewCell.storeNameLabel)
//        print(receiptTableViewCell.storeNameLabel.text)
//        receiptTableViewCell.storeNameLabel.text = receipt.storeName;
//        receiptTableViewCell.amountLabel.text = POSReceipt.stringForReceiptAmount(receipt.amount)
//        receiptTableViewCell.amountLabel.accessibilityLabel = self.numberFormatter.stringFromNumber(receipt.amount.doubleValue / 100);
//        receiptTableViewCell.amountLabel.accessibilityHint = self.numberFormatter.stringFromNumber(receipt.amount.doubleValue / 100);
//        receiptTableViewCell.dateLabel.text = POSDocument.stringForDocumentDate(receipt.timeOfPurchase)
//        receiptTableViewCell.multipleSelectionBackgroundView = UIView()
    }
    
    func receiptAtIndexPath(indexPath: NSIndexPath) -> POSReceipt {
        return self.receipts[indexPath.row]
    }
}