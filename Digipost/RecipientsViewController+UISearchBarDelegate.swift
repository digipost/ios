//
//  RecipientsViewController+UISearchBarDelegate.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension RecipientViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                searchBar.backgroundColor = UIColor(r: 227, g: 45, b: 34)
                searchBar.tintColor = UIColor.whiteColor()
        })
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                searchBar.backgroundColor = UIColor.whiteColor()
        })
    }
    
}
