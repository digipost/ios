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

extension UIImage {
    class func localizedImage(orientation: UIInterfaceOrientation) -> UIImage?{
        let locale = NSLocalizedString("language of app", comment: "the app language")
        var image: UIImage?
        if let localeName = locale as String? {
            if (UIInterfaceOrientationIsLandscape(orientation)){
                if (localeName.lowercaseString == "nb"){
                    image = UIImage(named: "Lastopp_veileder_norsk_horisontal")
                }else {
                    image = UIImage(named: "Lastopp_veileder_english_horisontal")
                }
            }else {
                if (localeName.lowercaseString == "nb"){
                    image = UIImage(named: "Lastopp_norsk_vertikal")
                } else {
                    image = UIImage(named: "Lastopp_engelsk_vertikal")
                }
            }
        }
        return image
    }
}