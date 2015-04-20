//
//  PreviewViewController+UITableViewDataSource.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension PreviewViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("recipientCell") as! RecipientTableViewCell
        
        let name = recipients[indexPath.row].name
        let address = recipients[indexPath.row].name
        
        cell.loadCell(name!, address: address!)

        return cell
    }
}