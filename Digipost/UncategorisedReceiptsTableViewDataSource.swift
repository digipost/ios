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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receipts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(UncategorisedReceiptsTableViewCell.identifier)
        
        if(cell == nil){
            cell = UncategorisedReceiptsTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: UncategorisedReceiptsTableViewCell.identifier)
        }
        
        self.configureCell(cell  as! UncategorisedReceiptsTableViewCell, indexPath: indexPath)
        return cell!
    }
    
    func configureCell(receiptTableViewCell: UncategorisedReceiptsTableViewCell, indexPath: NSIndexPath) {
        let receipt: POSReceipt = self.receipts[indexPath.row]
        
        receiptTableViewCell.storeNameLabel.text = receipt.storeName;
        receiptTableViewCell.amountLabel.text = POSReceipt.stringForReceiptAmount(receipt.amount)
        receiptTableViewCell.amountLabel.accessibilityLabel = self.numberFormatter.stringFromNumber(receipt.amount.doubleValue / 100);
        receiptTableViewCell.amountLabel.accessibilityHint = self.numberFormatter.stringFromNumber(receipt.amount.doubleValue / 100);
        receiptTableViewCell.dateLabel.text = POSDocument.stringForDocumentDate(receipt.timeOfPurchase)
        receiptTableViewCell.multipleSelectionBackgroundView = UIView()
    }
    
    func receiptAtIndexPath(indexPath: NSIndexPath) -> POSReceipt {
        return self.receipts[indexPath.row]
    }
}