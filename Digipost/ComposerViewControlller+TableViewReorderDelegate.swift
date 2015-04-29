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

        // todo dismiss keyboard

        deleteComposerModuleView = NSBundle.mainBundle().loadNibNamed("DeleteComposerModuleView", owner: self, options: nil)[0] as! DeleteComposerModuleView
        deleteComposerModuleView.addToView(self.view)
        deleteComposerModuleView.show()
        if let snapshotImageView = snapShotView as? UIImageView {
            let offset = tableView.frame.origin.x + 4
            snapshotImageView.contentMode = UIViewContentMode.ScaleAspectFill
            snapshotImageView.frame.size = CGSizeMake(tableView.frame.size.width - offset , 66)
            snapshotImageView.frame.origin.x = offset
            view.addSubview(snapshotImageView)
            UIView.animateWithDuration(0.4, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
//                snapShotView.transform = CGAffineTransformMakeRotation(-0.03)
            }, completion: { (complete) -> Void in

            })

        }
        tableView.contentInset = UIEdgeInsetsMake(0, 0, deleteComposerModuleView.frame.height, 0)
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
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.editing = false
        
    }
    
    func deleteComposerModule(){
        tableView.isDeletingRow = true
        // Deleting of cell is processed in the UITableView+Reorder Category
        deleteComposerModuleView.hide()
    }
}