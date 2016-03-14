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

protocol SegmentedControlTableViewCellDelegate {
    func segmentedControlTableViewCellValueChanged(segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int)
}

class SegmentedControlTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var multiselectSegmentedControl : MultiselectSegmentedControl!
    
    var delegate : SegmentedControlTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        multiselectSegmentedControl.valueChangedClosure = { (newValue, index) -> Void in
            self.delegate?.segmentedControlTableViewCellValueChanged(self, newValue: newValue, atIndex: index)
        }
        
    }
    
    func setupWithModels(textStyleModels : [TextStyleModel] ) {
        
        for (index, model) in textStyleModels.enumerate() {
            if let actualImage = UIImage(named:  model.preferredIconName!) {
                multiselectSegmentedControl.setImage(actualImage, atIndex: index)
            } else {
                multiselectSegmentedControl.setImage(UIImage(named: "Bold")!, atIndex: index)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}