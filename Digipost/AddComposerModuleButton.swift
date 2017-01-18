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


private struct AddComposerModuleButtonConstants {
    static let width : CGFloat = 44
    static let height : CGFloat = 44
    static let bottomMargin : CGFloat = 20
    static let rightMargin : CGFloat = 20

}

class AddComposerModuleButton: UIButton {

    fileprivate var constraintGroup = ConstraintGroup()

    class func layoutInView(_ view: UIView) -> AddComposerModuleButton {
        let addComposerModuleButton = AddComposerModuleButton(frame: CGRect.zero)
        addComposerModuleButton.setTitle("+", for: UIControlState())
        addComposerModuleButton.backgroundColor = UIColor.black
        view.addSubview(addComposerModuleButton)
        addComposerModuleButton.constraintGroup = constrain(addComposerModuleButton, replace: addComposerModuleButton.constraintGroup) { view in
            view.bottom == view.superview!.bottom - AddComposerModuleButtonConstants.bottomMargin
            view.right == view.superview!.right - AddComposerModuleButtonConstants.rightMargin
            view.width == AddComposerModuleButtonConstants.width
            view.height == AddComposerModuleButtonConstants.height
        }
        addComposerModuleButton.setupKeyboardAnimation(view)
        return addComposerModuleButton
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    fileprivate func setupKeyboardAnimation(_ withSuperView: UIView) {
        NotificationCenter.default.addObserver(self, selector: #selector(AddComposerModuleButton.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddComposerModuleButton.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = self.superview!.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIViewAnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.constraintGroup = constrain(self, replace: self.constraintGroup) { view in
                view.bottom == view.superview!.bottom - keyboardFrameConvertedToViewFrame.size.height - AddComposerModuleButtonConstants.bottomMargin
                view.right == view.superview!.right - AddComposerModuleButtonConstants.rightMargin
                view.width == AddComposerModuleButtonConstants.width
                view.height == AddComposerModuleButtonConstants.height
            }
            self.layoutIfNeeded()
            }) { (complete) -> Void in
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.int32Value
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        self.superview!.convert(keyboardFrame!, from: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve!))
        let options = UIViewAnimationOptions.beginFromCurrentState.union(curveAnimationOption)
        self.layoutIfNeeded()
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.constraintGroup = constrain(self, replace: self.constraintGroup) { view in
                view.bottom == view.superview!.bottom - AddComposerModuleButtonConstants.bottomMargin
                view.right == view.superview!.right - AddComposerModuleButtonConstants.rightMargin
                view.width == AddComposerModuleButtonConstants.width
                view.height == AddComposerModuleButtonConstants.height
            }
            self.layoutIfNeeded()
            }) { (complete) -> Void in
        }
    }
}
