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

extension StylePickerViewController : UITableViewDataSource {



    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentShowingTextStyleModels().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let arrayOfModels = currentShowingTextStyleModels()[indexPath.row]
        let cell : UITableViewCell = {
            if arrayOfModels.count == 1 {
                // single choice type cell
                return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath) as! UITableViewCell
            } else {
                // multi select type cell
                if let preferredIconName = arrayOfModels.first!.preferredIconName {
                    let cell =  tableView.dequeueReusableCellWithIdentifier("segmentedControlCell", forIndexPath: indexPath) as! SegmentedControlTableViewCell
                    cell.delegate = self
                    for (index, model) in arrayOfModels.enumerate() {
                        cell.multiselectSegmentedControl.setButtonSelectedState(model.enabled, atIndex: index)
                    }
                    cell.setupWithModels(arrayOfModels)
                    return cell
                } else {
                    let cell =  tableView.dequeueReusableCellWithIdentifier("pickerCell", forIndexPath: indexPath) as! UITableViewCell
                    let models = arrayOfModels.selectedTextStyleModel()
                    cell.detailTextLabel?.text = models?.name
                    cell.textLabel?.text = "Stil"
                    return cell
                }
            }
            }()
        return cell
    }
}
