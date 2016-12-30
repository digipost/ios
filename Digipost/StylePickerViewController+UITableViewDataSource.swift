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



    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentShowingTextStyleModels().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arrayOfModels = currentShowingTextStyleModels()[indexPath.row]
        let cell : UITableViewCell = {
            if arrayOfModels.count == 1 {
                // single choice type cell
                return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) 
            } else {
                // multi select type cell
                if arrayOfModels.first!.preferredIconName != nil {
                    let cell =  tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath) as! SegmentedControlTableViewCell
                    cell.delegate = self
                    for (index, model) in arrayOfModels.enumerated() {
                        cell.multiselectSegmentedControl.setButtonSelectedState(model.enabled, atIndex: index)
                    }
                    cell.setupWithModels(arrayOfModels)
                    return cell
                } else {
                    let cell =  tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) 
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
