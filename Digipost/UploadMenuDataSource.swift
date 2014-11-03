//
//  UploadMenuDataSource.swift
//  Digipost
//
//  Created by Håkon Bogen on 03/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UploadMenuDataSource: NSObject, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("uploadMenuCell", forIndexPath: indexPath) as UITableViewCell
        if let uploadMenuCell = cell as? UploadMenuTableViewCell {
            configureCell(uploadMenuCell, indexPath: indexPath)
        }
        
        return cell
    }
    
    func configureCell(cell: UploadMenuTableViewCell, indexPath: NSIndexPath){
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera roll button", comment:"button that uploads from camera roll")
        case 1:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera", comment:"start camera")
        case 2:
            cell.titleLabel.text = NSLocalizedString( "upload action sheet other file", comment:"From other app")
        default:
            assert(false)
        }
    }
}
