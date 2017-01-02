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

private struct RecipientButtonExtensionConstants {
    static let widthMargin : CGFloat = 80
}

extension UIButton {

    func fitAsManyStringsAsPossible(_ strings: [String]) {
        if strings.count == 0 {
            return
        }
        self.setTitle("", for: UIControlState())
        let currentSize = CGSize(width: self.frame.size.width - RecipientButtonExtensionConstants.widthMargin, height: self.frame.size.height)
        var string = strings[0]
        var lastFittedString = ""
        for i in 0..<strings.count {
            let remainingStrings = (strings.count - i) - 1
            if i != 0 {
                string = string + ", \(strings[i])"
            }
            let localizedEnding = String.localizedStringWithFormat(NSLocalizedString("recipients add more button overflow text", comment: "the end of recipients string when it overflows its size"), remainingStrings)
            let localizedMorePersons = remainingStrings == 0 ? "" : localizedEnding
            let allPersonsWithMorePersonsString = "\(string)\(localizedMorePersons)"
            self.setTitle(allPersonsWithMorePersonsString, for: UIControlState())
            let sizeFits = self.sizeThatFits(currentSize)
            if sizeFits.width > currentSize.width {
                if lastFittedString == "" {
                    self.setTitle(allPersonsWithMorePersonsString, for: UIControlState())
                    break
                } else {
                    self.setTitle(lastFittedString, for: UIControlState())
                }
            } else {
                lastFittedString = allPersonsWithMorePersonsString
            }
        }
    }
 
}
