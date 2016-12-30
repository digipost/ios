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

extension String {
    
    /**
    Inserts a substring at the given index in self.
    :param: index Where the new string is inserted
    :param: string String to insert
    :returns: String formed from self inserting string at index
    */
    func insert (_ index: Int, string: String) -> String {
        //  Edge cases, prepend and append

        if index > length {
            return self + string
        } else if index < 0 {
            return string + self
        }
        return self[0..<index] + string + self[index..<length]
    }

    func splitWithString(_ string: String, listString: String) -> [String] {
        let list = listString.components(separatedBy: string)
        var trimmed = [String]()
        for value in list {
            let whitespace = CharacterSet.whitespaces
            trimmed.append(value.trimmingCharacters(in: whitespace))
        }
        return trimmed
    }
}
