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

extension UIStoryboard {
    class func storyboardForCurrentUserInterfaceIdiom() -> UIStoryboard {
        let device = UIDevice.current.userInterfaceIdiom
        switch device {
        case .phone:
            return UIStoryboard(name: "LoginView", bundle: nil) 
        case .pad:
            return UIStoryboard(name: "Main_iPad", bundle: nil)
        case .unspecified:
            return UIStoryboard(name: "LoginView", bundle: nil)
        default:
            return UIStoryboard(name: "LoginView", bundle: nil)
        }
    }
}
