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
import Google.Analytics

@objc class GAEvents: NSObject{
    
    class func tracker() -> GAITracker {
        return GAI.sharedInstance().defaultTracker
    }
    
    class func event(category: String, action: String, label:String, value: NSNumber?) {
        #if !DEBUG
            if let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as? [AnyHashable : Any] {
            tracker().send(event)
        }
        #endif
    }
}
