//
//  RecipientViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class RecipientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var recipients : [Recipient] = [Recipient]() {
        didSet { tableView.reloadData() }
    }
    var addedRecipients : [Recipient] = [Recipient]() {
        didSet { tableView.reloadData() }
    }
    
    var recipientSearchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        var tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor(r: 222, g: 224, b: 225)
        
        self.recipientSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = true
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.frame.size = self.navigationController!.navigationBar.frame.size
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            controller.searchBar.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar

            return controller
        })()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
