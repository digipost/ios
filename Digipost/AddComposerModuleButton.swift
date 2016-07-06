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

    private var constraintGroup = ConstraintGroup()

    class func layoutInView(view: UIView) -> AddComposerModuleButton {
        let addComposerModuleButton = AddComposerModuleButton(frame: CGRectZero)
        addComposerModuleButton.setTitle("+", forState: .Normal)
        addComposerModuleButton.backgroundColor = UIColor.blackColor()
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    private func setupKeyboardAnimation(withSuperView: UIView) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddComposerModuleButton.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddComposerModuleButton.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let keyboardFrameConvertedToViewFrame = self.superview!.convertRect(keyboardFrame!, fromView: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve))
        let options = UIViewAnimationOptions.BeginFromCurrentState.union(curveAnimationOption)
        self.layoutIfNeeded()
        
        UIView.animateWithDuration(animationDuration, delay: 0, options:options, animations: { () -> Void in
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

    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        self.superview!.convertRect(keyboardFrame!, fromView: nil)
        let curveAnimationOption = UIViewAnimationOptions(rawValue: UInt(animationCurve))
        let options = UIViewAnimationOptions.BeginFromCurrentState.union(curveAnimationOption)
        self.layoutIfNeeded()
        UIView.animateWithDuration(animationDuration, delay: 0, options:options, animations: { () -> Void in
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
