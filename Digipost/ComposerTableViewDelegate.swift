//
//  ComposerTableViewDelegate.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerTableViewDelegate: NSObject, UITableViewDelegate {
   
    weak var tableView: UITableView?

    // MARK: - Class initialiser
    
    init(asDelegateForTableView tableView: UITableView) {
        super.init()
        tableView.delegate = self
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Selected")
    }





}
