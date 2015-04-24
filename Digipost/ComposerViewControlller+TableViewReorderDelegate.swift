//
//  ComposerViewControlller+TableViewReorderDelegate.swift
//  Digipost
//
//  Created by Henrik Holmsen on 24.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension ComposerViewController{
    
    // MARK: - TableView Delegate Reorder functions
    
    func tableView(tableView: UITableView!, beganMovingRowAtPoint point: CGPoint, withSnapShotViewOfDraggingRow snapShotView: UIView!) {
        deleteComposerModuleView = NSBundle.mainBundle().loadNibNamed("DeleteComposerModuleView", owner: self, options: nil)[0] as! DeleteComposerModuleView
        deleteComposerModuleView.addToView(self.view)
        deleteComposerModuleView.show()
        snapShotView.transform = CGAffineTransformMakeRotation(-0.02)
        let offset = tableView.frame.origin.x
        snapShotView.frame.size = CGSizeMake(snapShotView.frame.width, 88)
        snapShotView.frame.origin.x += offset
        view.addSubview(snapShotView)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.tableView.frame.size.height -= self.deleteComposerModuleView.frame.height
            }) { (Bool) -> Void in
                self.tableView.setNeedsLayout()
        }
        tableView.editing = true
        
    }
    
    func tableView(tableView: UITableView!, changedPositionOfRowAtPoint point: CGPoint) {
    }
    
    func tableView(tableView: UITableView!, endedMovingRowAtPoint point: CGPoint) {
        let translatedPoint = tableView.convertPoint(point, toView: deleteComposerModuleView)
        if deleteComposerModuleView.pointInside(translatedPoint, withEvent: nil){
            deleteComposerModule()
        } else {
            deleteComposerModuleView.hide()
        }
        
        tableView.editing = false
        
    }
    
    func deleteComposerModule(){
        tableView.isDeletingRow = true
        // Deleting of cell is processed in the UITableView+Reorder Category
        deleteComposerModuleView.hide()
    }
}