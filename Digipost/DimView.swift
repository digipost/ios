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

class DimView: UIView {
    
    private var dimView: UIView!
    @IBInspectable var dimColor: UIColor!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func dim() {
        
        if dimView == nil {
            
            dimView = UIView(frame: UIScreen.mainScreen().bounds)
            dimView.backgroundColor = dimColor
            dimView.alpha = 0
            addSubview(dimView)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dimView.alpha = 0.5
            })
        } else {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dimView.alpha = 0
                }, completion: { (Bool) -> Void in
                    self.dimView.removeFromSuperview()
                    self.dimView = nil
            })
        }
    }

}
