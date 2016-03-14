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

extension Array {

    func selectedTextStyleModel() -> TextStyleModel? {
        for object in self {
            if let textStyleModel = object as? TextStyleModel {
                if textStyleModel.enabled == true {
                    return textStyleModel
                }
            }
        }
        return nil
    }

    func setTextStyleModelEnabledAndAllOthersDisabled(textstyleModel : TextStyleModel) {
        for object in self {
            if let aTextStyleModel = object as? TextStyleModel {
                if aTextStyleModel.keyword == textstyleModel.keyword {
                    aTextStyleModel.enabled = true
                } else {
                    aTextStyleModel.enabled = false
                }
            }
        }
    }
}
