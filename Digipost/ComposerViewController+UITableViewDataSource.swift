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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = composerModules.count
        rowCount = tableView.adjustedValueForReordering(ofRowCount: rowCount, forSection: section)
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let indexPathFromVisibleIndexPath = tableView.dataSourceIndexPath(fromVisibleIndexPath: indexPath)
        
        let module = composerModules[indexPath.row]
        
        let cell : UITableViewCell = {
            if let imageModule = module as? ImageComposerModule {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Composer.imageModuleCellIdentifier, for: indexPath) as! ImageModuleTableViewCell
                self.configureImageModuleCell(cell, withModule: imageModule)
                return cell
            } else if let textModule = module as? TextComposerModule {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Composer.textModuleCellIdentifier, for: indexPath) as! TextModuleTableViewCell
                self.configureTextModuleCell(cell, withModule: textModule)
                cell.moduleTextView.tag = indexPath.row
                return cell
            } else {
                assert(false)
                return UITableViewCell()
            }
        }()
        
        if tableView.shouldSubstitutePlaceHolderForCellBeingMoved(at: indexPathFromVisibleIndexPath){
            cell.isHidden = true
        }
        return cell
    }
    
    func configureImageModuleCell(_ cell: ImageModuleTableViewCell, withModule module: ImageComposerModule){
        cell.moduleImageView.image = module.image
    }
    
    func configureTextModuleCell(_ cell: TextModuleTableViewCell, withModule module: TextComposerModule){
        cell.moduleTextView.attributedText = module.attributedText
        cell.moduleTextView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = composerModules.remove(at: sourceIndexPath.row)
        composerModules.insert(rowToMove, at: destinationIndexPath.row)
        tableView.reloadData()
        let cell = tableView.cellForRow(at: destinationIndexPath) as? TextModuleTableViewCell
        cell?.moduleTextView.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            composerModules.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        } else if editingStyle == UITableViewCellEditingStyle.insert{
            if let cell = tableView.cellForRow(at: indexPath) as? TextModuleTableViewCell{
                configureTextModuleCell(cell, withModule: composerModule(atIndexPath: indexPath) as! TextComposerModule)
            }
            
        }
    }
    
    // MARK: - Helper Functions
    func composerModule(atIndexPath: IndexPath) -> ComposerModule? {
        return composerModules[atIndexPath.row]
    }
    
    func indexPath(module: ComposerModule) -> IndexPath? {
        return {
            for (index, tableViewModule) in self.composerModules.enumerated() {
                if tableViewModule.isEqual(module) {
                    return IndexPath(row: index, section: 0)
                }
            }
            return nil
            }()
    }
    
    func resizeHeight(_ height: CGFloat, forCellAtRow row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! TextModuleTableViewCell
        cell.frame.size.height = height
        tableView.endUpdates()
    }
    
}
