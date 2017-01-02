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

class MainAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var unreadMessages: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accountImageView.backgroundColor = UIColor.digipostProfileViewBackground()
        accountImageView.layer.cornerRadius = accountImageView.frame.width / 2
        accountImageView.clipsToBounds = true
        
        accountNameLabel.textColor = UIColor.digipostProfileTextColor()
        initialLabel.textColor = UIColor.digipostProfileViewInitials()
        unreadMessages.textColor = UIColor.digipostProfileTextColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
