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

extension String
{
    subscript(i: Int) -> Character {
        let result = self.characters.index(self.startIndex, offsetBy: i)
        return self[result]
    }

    // O(n)
    subscript (r: Range<Int>) -> String {
        get {
            var counter = 0
            var currentIndex = self.startIndex
            var stringInRange = ""
            while counter < r.upperBound && currentIndex < self.endIndex {
                currentIndex = <#T##Collection corresponding to `currentIndex`##Collection#>.index(after: currentIndex)
                stringInRange.append(self[currentIndex])
                counter += 1
            }
            return stringInRange

        }
    }
}
