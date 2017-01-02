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

class ReceiptsTableViewDataSource: NSObject, UITableViewDataSource {
    let tableView: UITableView
    var receipts: [POSReceipt] = []
    
    lazy var numberFormatter: NumberFormatter = {
        var numberFormatter = NumberFormatter()
        
        numberFormatter.currencyCode = "NOK"
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.perMillSymbol = " "
        numberFormatter.decimalSeparator = " "
        numberFormatter.groupingSize = 10
        numberFormatter.currencySymbol = "kroner"
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.locale = Locale.init(identifier: "nb_NO")
        
        return numberFormatter
    }()
    
    var numberOfReceipts: Int = 0
    
    init(asDataSourceForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: ReceiptTableViewCell.identifier)
        
        if(cell == nil){
            cell = ReceiptTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: ReceiptTableViewCell.identifier)
        }
        
        self.configureCell(cell  as! ReceiptTableViewCell, indexPath: indexPath)
        return cell!
    }
    
    func configureCell(_ receiptTableViewCell: ReceiptTableViewCell, indexPath: IndexPath) {
        let receipt: POSReceipt = self.receipts[indexPath.row]
        let amount = NSNumber(value: receipt.amount.doubleValue / 100)
        
        receiptTableViewCell.storeNameLabel.text = receipt.storeName;
        receiptTableViewCell.amountLabel.text = POSReceipt.string(forReceiptAmount: receipt.amount)
        receiptTableViewCell.amountLabel.accessibilityLabel = self.numberFormatter.string(from: amount)
        receiptTableViewCell.amountLabel.accessibilityHint = self.numberFormatter.string(from: amount)
        receiptTableViewCell.dateLabel.text = POSDocument.string(forDocumentDate: receipt.timeOfPurchase)
        receiptTableViewCell.multipleSelectionBackgroundView = UIView()
    }
    
    func receiptAtIndexPath(_ indexPath: IndexPath) -> POSReceipt {
        return self.receipts[indexPath.row]
    }
}
