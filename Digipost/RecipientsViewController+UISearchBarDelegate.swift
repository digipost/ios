//
//  RecipientsViewController+UISearchBarDelegate.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

extension RecipientViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        recipients.removeAll(keepCapacity: false)
        
        if searchBar.text == "" {
            tableView.reloadData()
        } else if searchBar.text != "" {
            APIClient.sharedClient.getRecipients(searchBar.text, success: { (responseDictionary) -> Void in
                self.recipients = Recipient.recipients(jsonDict: responseDictionary)
                self.tableView.reloadData()
                }) { (error) -> () in
                    println(error)
            }
        }

        tableView.reloadData()
    }
}
