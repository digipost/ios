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

extension NSDate {
    
    func prettyStringWithJPGExtension()-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "IMG "
        dateString = dateString.stringByAppendingString(dateFormatter.stringFromDate(self))
        dateString = dateString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dateString = dateString.stringByAppendingString(".jpg")
        return dateString
    }
    
    func prettyStringWithMOVExtension()-> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM YY HH:mm:ss"
        var dateString = "MOV "
        dateString = dateString.stringByAppendingString(dateFormatter.stringFromDate(self))
        dateString = dateString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dateString = dateString.stringByAppendingString(".mov")
        return dateString
    }

    func dateByAdding(seconds seconds: Int?) -> NSDate? {
        if seconds == nil {
            return nil
        }
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.second = seconds!
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())
    }

    func isLaterThan(aDate: NSDate) -> Bool {
        let isLater = self.compare(aDate) == NSComparisonResult.OrderedDescending
        return isLater
    }
}

