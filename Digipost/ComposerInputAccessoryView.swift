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
import Cartography

struct ComposerInputAccessoryViewConstants {
    static let leftMargin = 5
    static let height : CGFloat = 44
    static let width : CGFloat = 44
}

class ComposerInputAccessoryView: UIView {
    var containedViews = [UIView]()

    func setupWithStandardLayout(_ withControlEventInTarget: UIViewController, selector: Selector) {
        let composerTypeButton = ComposerTypeButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        composerTypeButton.setTitle("Headline", for: UIControlState())
        self.addViewToAccessoryBar(composerTypeButton)
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .left), target: withControlEventInTarget, selector: selector))
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .center), target: withControlEventInTarget, selector: selector))
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .right), target: withControlEventInTarget, selector: selector))
    }


    func refreshUIWithTextAttribute(_ textAttribute: TextAttribute) {
        for view in containedViews {
            if let textAttributeButton = view as? TextAttributeButton   {
                if textAttributeButton.textAttribute.hasOneOrMoreMatchesWith(textAttribute: textAttribute) {
                    textAttributeButton.backgroundColor = UIColor.red
                } else {
                    textAttributeButton.backgroundColor = UIColor.black
                }
            }
        }
    }

    func refreshUIWithTextComposerModule(_ textComposerModule : TextComposerModule) {
        for view in containedViews {
            if let composerTypeButton = view as? ComposerTypeButton {
                // do the actual
                composerTypeButton.setTitle("Headline", for: UIControlState())
            } else if let textAttributeButton = view as? TextAttributeButton   {
                if textAttributeButton.textAttribute.hasOneOrMoreMatchesWith(textAttribute: textComposerModule.textAttribute) {
                    textAttributeButton.backgroundColor = UIColor.red
                } else {
                    textAttributeButton.backgroundColor = UIColor.white
                }
            }
        }
    }

    func addViewsToAccessoryBar(_ views: [UIView]) {
        for view in views {
            addViewToAccessoryBar(view)
        }
    }

    func addViewToAccessoryBar(_ view: UIView) {
        self.addSubview(view)
        if containedViews.count == 0 {
            constrain(self, view) { firstView, secondView in
                secondView.width == 60
                secondView.height == 44
                secondView.left == firstView.left + 5
                secondView.top == firstView.top
            }
        } else {
            let leftMostView = containedViews.last as UIView!
            constrain(leftMostView, view) { firstView, secondView in
                secondView.width == 44
                secondView.height == 44
                secondView.left == firstView.right + 5
            }
            constrain(self, view) { firstView, secondView in
                secondView.top == firstView.top
            }
        }

        containedViews.append(view)
    }
//    
//    @IBAction func alignContentLeft(sender: AnyObject) {
///        setBackground(leftView)
//    }
//    
//    @IBAction func alignContentCenter(sender: AnyObject) {
//        textView.textAlignment = .Center
//        setBackground(centerView)
//
//    }
//
//    @IBAction func alignContentRight(sender: AnyObject) {
//        textView.textAlignment = .Right
//        setBackground(rightView)
//    }
//    
//    @IBAction func doneAction(sender: AnyObject) {
//        textView.resignFirstResponder()
//    }
//    
//    func setBackground(view: UIView) {
//        leftView.backgroundColor = .clearColor()
//        centerView.backgroundColor = .clearColor()
//        rightView.backgroundColor = .clearColor()
//        
//        view.backgroundColor = 	UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//    }
}
