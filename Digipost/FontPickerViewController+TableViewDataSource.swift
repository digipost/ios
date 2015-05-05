//
//  FontPickerViewController+TableViewDataSource.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension FontPickerViewController : UITableViewDataSource {
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func configureCell(cell : UITableViewCell, atIndexPath: NSIndexPath) {
        let font = fonts[atIndexPath.row]
        cell.detailTextLabel?.text = font.fontName
    }
}
