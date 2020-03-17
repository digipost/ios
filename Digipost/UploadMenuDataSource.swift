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

class UploadMenuDataSource: NSObject, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "uploadMenuCell", for: indexPath) 
        if let uploadMenuCell = cell as? UploadMenuTableViewCell {
            configureCell(uploadMenuCell, indexPath: indexPath)
        }
        
        return cell
    }
    
    func configureCell(_ cell: UploadMenuTableViewCell, indexPath: IndexPath){
        cell.accessibilityTraits = UIAccessibilityTraitButton;
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera", comment:"start camera")
            cell.iconImage.image = UIImage(named: "From_camera")
        case 1:
            cell.titleLabel.text = NSLocalizedString("upload action sheet camera roll button", comment:"button that uploads from camera roll")
            cell.iconImage.image = UIImage(named: "Upload_small")

        default:
            assert(false)
        }
    }
}
