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


struct ComposerViewControllerDelegateConstants {
    static let textViewMarginTop : CGFloat = 5
    static let textViewMarginBottom : CGFloat = 5

    static let minimumCellSize : CGFloat = 44

}

extension ComposerViewController {

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.editing == true {
            return 88
        } else {
            let module = composerModule(atIndexPath: indexPath)
            if let textModule = module as? TextComposerModule {
                return height(textComposerModule: textModule)
            }
            if ((module as? ImageComposerModule) != nil) {
                return self.view.frame.width
            }
            
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }

    func height(textComposerModule textComposerModule: TextComposerModule) -> CGFloat {
        let textView = UITextView()
        textView.attributedText = textComposerModule.attributedText
        textView.frame.size.width = self.tableView.frame.size.width - 40 // TODO: use the actual margin!
        let size = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, 1000))
        let calculatedHeight = size.height + ComposerViewControllerDelegateConstants.textViewMarginBottom
        return max(calculatedHeight, ComposerViewControllerDelegateConstants.minimumCellSize)
    }
}
