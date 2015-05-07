//
//  AddComposerModuleButton.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import Cartography


private struct AddComposerModuleButtonConstants {
    static let width : CGFloat = 44
    static let height : CGFloat = 44
    static let bottomMargin : Double = 20
    static let rightMargin : Double = 20

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.intValue
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardFrameConvertedToViewFrame = self.superview!.convertRect(keyboardFrame!, fromView: nil)
        let curveAnimationOption = UIViewAnimationOptions(UInt(animationCurve))
        let options = UIViewAnimationOptions.BeginFromCurrentState | curveAnimationOption
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
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyboardFrameConvertedToViewFrame = self.superview!.convertRect(keyboardFrame!, fromView: nil)
        let curveAnimationOption = UIViewAnimationOptions(UInt(animationCurve))
        let options = UIViewAnimationOptions.BeginFromCurrentState | curveAnimationOption
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
