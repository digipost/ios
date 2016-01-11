
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
            for (index, r) in addedRecipients.enumerate() {
                if r.digipostAddress == recipients[indexPath.row].digipostAddress {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! RecipientTableViewCell
                    cell.addedButton.hidden = true
                    NSNotificationCenter.defaultCenter().postNotificationName("deleteRecipientNotification", object: r, userInfo: nil)
                    addedRecipients.removeAtIndex(index)
                    tableView.reloadData()
                    found = true
                }
            }
            if found == false {
                addedRecipients.append(recipients[indexPath.row])
                NSNotificationCenter.defaultCenter().postNotificationName("addRecipientNotification", object: recipients[indexPath.row], userInfo: nil)
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("deleteRecipientNotification", object: addedRecipients[indexPath.row], userInfo: nil)
            deletedRecipient = addedRecipients[indexPath.row]
            addedRecipients.removeAtIndex(indexPath.row)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.undoButtonBottomConstraint.constant = 20
                self.undoButton.layoutIfNeeded()
            })
        }
        
        tableView.reloadData()
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