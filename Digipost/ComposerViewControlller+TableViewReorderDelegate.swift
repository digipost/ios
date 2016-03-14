//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
            UIView.animateWithDuration(0.4, delay: 0.03, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                let randomValue = Int.random(-4...4)
                snapShotView.transform = CGAffineTransformMakeRotation(-(CGFloat(randomValue) * 0.01))
            }, completion: { (complete) -> Void in

            })

        }
        tableView.contentInset = UIEdgeInsetsMake(0, 0, deleteComposerModuleView.frame.height, 0)
        tableView.editing = true
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

        if let indexPath = tableView.indexPathForRowAtPoint(point) {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell
            cell?.moduleTextView.delegate = self
        }
    }
    
    func deleteComposerModule(){
        tableView.isDeletingRow = true
        // Deleting of cell is processed in the UITableView+Reorder Category
        deleteComposerModuleView.hide()
    }
}