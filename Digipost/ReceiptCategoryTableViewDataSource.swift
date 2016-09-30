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

class ReceiptCategoriesTableViewDataSource: NSObject, UITableViewDataSource {

    let tableView: UITableView
    var categories: [ReceiptCategory] = []
    
    init(asDataSourceForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        
        tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(ReceiptCategoriesTableViewCell.identifier)
        
        if(cell == nil){
            cell = ReceiptCategoriesTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: ReceiptCategoriesTableViewCell.identifier)
        }
        
        self.configureCell(cell as! ReceiptCategoriesTableViewCell, indexPath: indexPath)
        return cell!
    }
    
    func configureCell(receiptCategoryCell: ReceiptCategoriesTableViewCell, indexPath: NSIndexPath){
        
        
    }
    
    func categoryAtIndexPath(indexPath: NSIndexPath) -> ReceiptCategory {
        return self.categories[indexPath.row]
    }
}