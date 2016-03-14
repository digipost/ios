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

extension UIScrollView{
    
    var totalPageProgressInPercentage:CGFloat {
        get {
            let maxHorizontalOffset = self.contentSize.width - pageSize.width
            let currentHorizontalOffset = self.contentOffset.x
            return currentHorizontalOffset / maxHorizontalOffset
        }
    }
    
    var pageProgressInPercentage:CGFloat {
        get { return self.contentOffset.x / pageSize.width }
    }
    
    var pageSize:CGSize {
        get { return self.frame.size }
    }
    
    var currentPage:Int {
        get { return Int(floor((self.contentOffset.x * 2.0 + self.frame.width) / (self.frame.width * 2.0)))}
    }
    
    var scrollableEdgeOffset:CGFloat {
        get { return self.frame.width / 3}
    }
}
