//
//  FontPickerViewController+TableViewDataSource.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension FontPickerViewController : UITableViewDataSource {
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
}
