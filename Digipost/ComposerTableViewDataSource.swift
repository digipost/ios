//
//  ComposerTableViewDataSource.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerTableViewDataSource: NSObject, UITableViewDataSource {
   
    let tableView: UITableView
    var tableData = [AnyObject]()
    
    // MARK: - Class initialiser
    
    init(asDataSourceForTableView tableView: UITableView){
        
        self.tableView = tableView
        super.init()
        tableView.allowsLongPressToReorder = true
        tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = tableData.count
        rowCount = tableView.adjustedValueForReorderingOfRowCount(rowCount, forSection: section)
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let indexPathFromVisibleIndexPath = tableView.dataSourceIndexPathFromVisibleIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPathFromVisibleIndexPath) as UITableViewCell
        
        if tableView.shouldSubstitutePlaceHolderForCellBeingMovedAtIndexPath(indexPathFromVisibleIndexPath){
            cell.hidden = true
        }
        
        cell.textLabel?.text = tableData[indexPathFromVisibleIndexPath.row] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let rowToMoveContent = tableData[sourceIndexPath.row]
        tableData.removeAtIndex(sourceIndexPath.row)
        tableData.insert(rowToMoveContent, atIndex: destinationIndexPath.row)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            tableData.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}
