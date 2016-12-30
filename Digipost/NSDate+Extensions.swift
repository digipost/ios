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

extension Date {
    
    func prettyStringWithJPGExtension()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "IMG "
        dateString = dateString + dateFormatter.string(from: self)
        dateString = dateString + ".jpg"
        return dateString
    }
    
    func prettyStringWithMOVExtension()-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "MOV "
        dateString = dateString + dateFormatter.string(from: self)
        dateString = dateString + ".mov"
        return dateString
    }

    func dateByAdding(seconds: Int?) -> Date? {
        if seconds == nil {
            return nil
        }
        let calendar = Calendar.current
        var components = DateComponents()
        components.second = seconds!
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options())
    }

    func isLaterThan(_ aDate: Date) -> Bool {
        let isLater = self.compare(aDate) == ComparisonResult.orderedDescending
        return isLater
    }
}

