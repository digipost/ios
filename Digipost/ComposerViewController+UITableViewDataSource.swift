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

import UIKit

extension ComposerViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = composerModules.count
        rowCount = tableView.adjustedValueForReorderingOfRowCount(rowCount, forSection: section)
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let indexPathFromVisibleIndexPath = tableView.dataSourceIndexPathFromVisibleIndexPath(indexPath)
        
        let module = composerModules[indexPath.row]
        let textModule = module as? TextComposerModule
        
        let cell : UITableViewCell = {
            if let imageModule = module as? ImageComposerModule {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Composer.imageModuleCellIdentifier, forIndexPath: indexPath) as! ImageModuleTableViewCell
                self.configureImageModuleCell(cell, withModule: imageModule)
                return cell
            } else if let textModule = module as? TextComposerModule {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.Composer.textModuleCellIdentifier, forIndexPath: indexPath) as! TextModuleTableViewCell
                self.configureTextModuleCell(cell, withModule: textModule)
                cell.moduleTextView.tag = indexPath.row
                return cell
            } else {
                assert(false)
                return UITableViewCell()
            }
        }()
        
        if tableView.shouldSubstitutePlaceHolderForCellBeingMovedAtIndexPath(indexPathFromVisibleIndexPath){
            cell.hidden = true
        }
        return cell
    }
    
    func configureImageModuleCell(cell: ImageModuleTableViewCell, withModule module: ImageComposerModule){
        cell.moduleImageView.image = module.image
    }
    
    func configureTextModuleCell(cell: TextModuleTableViewCell, withModule module: TextComposerModule){
        cell.moduleTextView.attributedText = module.attributedText
        cell.moduleTextView.delegate = self
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let rowToMove = composerModules.removeAtIndex(sourceIndexPath.row)
        composerModules.insert(rowToMove, atIndex: destinationIndexPath.row)
        tableView.reloadData()
        let cell = tableView.cellForRowAtIndexPath(destinationIndexPath) as? TextModuleTableViewCell
        cell?.moduleTextView.becomeFirstResponder()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            composerModules.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } else if editingStyle == UITableViewCellEditingStyle.Insert{
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell{
                configureTextModuleCell(cell, withModule: composerModule(atIndexPath: indexPath) as! TextComposerModule)
            }
            
        }
    }
    
    // MARK: - Helper Functions
    func composerModule(atIndexPath atIndexPath: NSIndexPath) -> ComposerModule? {
        return composerModules[atIndexPath.row]
    }
    
    func indexPath(module module: ComposerModule) -> NSIndexPath? {
        return {
            for (index, tableViewModule) in self.composerModules.enumerate() {
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
