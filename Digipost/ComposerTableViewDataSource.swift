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
    var tableData = [ComposerModule]()
    
    // MARK: - Class initialiser
    
    init(asDataSourceForTableView tableView: UITableView){
        
        self.tableView = tableView
        super.init()
        tableView.allowsLongPressToReorder = true
        tableView.dataSource = self
    }
    
    // MARK: - UITableView Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = tableData.count
        rowCount = tableView.adjustedValueForReorderingOfRowCount(rowCount, forSection: section)
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let indexPathFromVisibleIndexPath = tableView.dataSourceIndexPathFromVisibleIndexPath(indexPath)
        
        let module = tableData[indexPath.row]

        switch module.type {
            
        case .ImageModule:
        
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Composer.imageModuleCellIdentifier, forIndexPath: indexPath) as! ImageModuleTableViewCell
            
            configureImageModuleCell(cell, withModule: module as! ComposerImageModule)
            
            if tableView.shouldSubstitutePlaceHolderForCellBeingMovedAtIndexPath(indexPathFromVisibleIndexPath){
                cell.hidden = true
            }
            
            return cell
        
        case .TextModule:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Composer.textModuleCellIdentifier, forIndexPath: indexPath) as! TextModuleTableViewCell
            configureTextModuleCell(cell, withModule: module as! ComposerTextModule)
            
            if tableView.shouldSubstitutePlaceHolderForCellBeingMovedAtIndexPath(indexPathFromVisibleIndexPath){
                cell.hidden = true
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let rowToMove = tableData.removeAtIndex(sourceIndexPath.row)
        tableData.insert(rowToMove, atIndex: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            tableData.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: - Helper Functions
    
    func configureImageModuleCell(cell: ImageModuleTableViewCell, withModule module: ComposerImageModule){
        cell.moduleImageView.image = module.image
    }
    
    func configureTextModuleCell(cell: TextModuleTableViewCell, withModule module: ComposerTextModule){
        cell.moduleTextView.text = module.text
        cell.moduleTextView.font = module.font
    }

   func composerModule(#atIndexPath: NSIndexPath) -> ComposerModule? {
       return tableData[atIndexPath.row]
    }

    func indexPath(#module: ComposerModule) -> NSIndexPath? {
        return {
            for (index, tableViewModule) in enumerate(self.tableData) {
                if tableViewModule.isEqual(module) {
                    return NSIndexPath(forRow: index, inSection: 0)
                }
            }
            return nil
        }()
    }
    
    func resizeHeight(height: CGFloat, forCellAtRow row: Int) {
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        tableView.beginUpdates()
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextModuleTableViewCell
        cell.frame.size.height = height
        tableView.endUpdates()
    }

}
