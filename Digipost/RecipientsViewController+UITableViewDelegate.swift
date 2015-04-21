
//
//  RecipientsViewController+TableViewDelegateExtension.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension RecipientViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var found = false
        
        if searchBar.isFirstResponder() {
            for (index, r) in enumerate(addedRecipients) {
                if r.name == recipients[indexPath.row].name {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! RecipientTableViewCell
                    cell.addedButton.hidden = true
                    addedRecipients.removeAtIndex(index)
                    tableView.reloadData()
                    found = true
                }
            }
            if found == false { addedRecipients.append(recipients[indexPath.row]) }
        }
        
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if searchBar.isFirstResponder() == false {
            addedRecipients.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectZero)
        
        var singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTapOnEmptyTableView:")
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(singleTap)
        
        return footerView
    }
    
    
    
}