//
//  ComposerViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var dataSource: ComposerTableViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = ComposerTableViewDataSource(asDataSourceForTableView: tableView)
        dataSource?.tableData = ["1","2","3"]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
