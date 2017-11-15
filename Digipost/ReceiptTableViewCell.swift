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

class ReceiptTableViewCell : UITableViewCell {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let identifier = "ReceiptTableViewCellIdentifier"
    static let nibName = "ReceiptTableViewCellNib"
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        self.tintColor = self.isEditing ? UIColor(red: 64.0 / 255.0,
            green: 66.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
            : UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.tintColor = self.isEditing ? UIColor(red: 64.0 / 255.0,
                                                green: 66.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)
            : UIColor.white
    }
}
