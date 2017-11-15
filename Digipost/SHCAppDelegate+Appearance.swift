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
import UIKit

extension SHCAppDelegate {
    @objc class func setupAppearance() {
        SHCAppDelegate.setupNavBarAppearance()
    }
    
    @objc class func setupNavBarAppearance() {
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = UIColor(red: 227/255, green: 45/255, blue: 34/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor(white: 1, alpha: 0.8)
        UINavigationBar.appearance().titleTextAttributes =  [ NSAttributedStringKey.foregroundColor : UIColor.white]
    }
}
