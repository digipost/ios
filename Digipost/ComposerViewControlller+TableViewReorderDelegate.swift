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
    
    func tableView(_ tableView: UITableView!, beganMovingRowAt point: CGPoint, withSnapShotViewOfDraggingRow snapShotView: UIView!) {

        // todo dismiss keyboard

        deleteComposerModuleView = Bundle.main.loadNibNamed("DeleteComposerModuleView", owner: self, options: nil)![0] as! DeleteComposerModuleView
        deleteComposerModuleView.addToView(self.view)
        deleteComposerModuleView.show()
        
        if let snapshotImageView = snapShotView as? UIImageView {
            let offset = tableView.frame.origin.x + 4
            snapshotImageView.contentMode = UIViewContentMode.scaleAspectFill
            snapshotImageView.frame.size = CGSize(width: tableView.frame.size.width - offset , height: 66)
            snapshotImageView.frame.origin.x = offset
            view.addSubview(snapshotImageView)
            UIView.animate(withDuration: 0.4, delay: 0.03, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                let randomValue = Int.random(-4...4)
                snapShotView.transform = CGAffineTransform(rotationAngle: -(CGFloat(randomValue) * 0.01))
            }, completion: { (complete) -> Void in

            })

        }
        tableView.contentInset = UIEdgeInsetsMake(0, 0, deleteComposerModuleView.frame.height, 0)
        tableView.isEditing = true
    }
    
    
    func tableView(_ tableView: UITableView!, endedMovingRowAt point: CGPoint) {
        let translatedPoint = tableView.convert(point, to: deleteComposerModuleView)
        if deleteComposerModuleView.point(inside: translatedPoint, with: nil){
            deleteComposerModule()
        } else {
            deleteComposerModuleView.hide()
        }
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.isEditing = false

        if let indexPath = tableView.indexPathForRow(at: point) {
            let cell = tableView.cellForRow(at: indexPath) as? TextModuleTableViewCell
            cell?.moduleTextView.delegate = self
        }
    }
    
    func deleteComposerModule(){
        tableView.isDeletingRow = true
        // Deleting of cell is processed in the UITableView+Reorder Category
        deleteComposerModuleView.hide()
    }
}
