//
//  ComposerTableViewDelegate.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerTableViewDelegate: NSObject, UITableViewDelegate {
   
    let tableView: UITableView
    var tableData = [AnyObject]()
    
    // MARK: - Class initialiser
    
    init(asDelegateForTableView tableView: UITableView){
        self.tableView = tableView
        super.init()
        tableView.delegate = self
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected")
    }


}
