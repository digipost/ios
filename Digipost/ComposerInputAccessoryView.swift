//
//  ComposerInputAccessoryView.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-16.
//  Copyright (c) 2015 Posten. All rights reserved.
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

    func setupWithStandardLayout(withControlEventInTarget: UIViewController, selector: Selector) {
        let composerTypeButton = ComposerTypeButton(frame: CGRectMake(0, 0, 44, 44))
        composerTypeButton.setTitle("Headline", forState: .Normal)
        self.addViewToAccessoryBar(composerTypeButton)
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .Left), target: withControlEventInTarget, selector: selector))
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .Center), target: withControlEventInTarget, selector: selector))
        addViewToAccessoryBar(TextAttributeButton(textAttribute: TextAttribute(textAlignment: .Right), target: withControlEventInTarget, selector: selector))
    }


    func refreshUIWithTextAttribute(textAttribute: TextAttribute) {
        for view in containedViews {
            if let textAttributeButton = view as? TextAttributeButton   {
                if textAttributeButton.textAttribute.hasOneOrMoreMatchesWith(textAttribute: textAttribute) {
                    textAttributeButton.backgroundColor = UIColor.redColor()
                } else {
                    textAttributeButton.backgroundColor = UIColor.blackColor()
                }
            }
        }
    }

    func refreshUIWithTextComposerModule(textComposerModule : TextComposerModule) {
        for view in containedViews {
            if let composerTypeButton = view as? ComposerTypeButton {
                // do the actual
                composerTypeButton.setTitle("Headline", forState: .Normal)
            } else if let textAttributeButton = view as? TextAttributeButton   {
                if textAttributeButton.textAttribute.hasOneOrMoreMatchesWith(textAttribute: textComposerModule.textAttribute()) {
                    textAttributeButton.backgroundColor = UIColor.redColor()
                } else {
                    textAttributeButton.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }

    func addViewsToAccessoryBar(views: [UIView]) {
        for view in views {
            addViewToAccessoryBar(view)
        }
    }

    func addViewToAccessoryBar(view: UIView) {
        self.addSubview(view)
        if containedViews.count == 0 {
            layout(self, view) { firstView, secondView in
                secondView.width == 60
                secondView.height == 44
                secondView.left == firstView.left + 5
                secondView.top == firstView.top
            }
        } else {
            let leftMostView = containedViews.last as UIView!
            layout(leftMostView, view) { firstView, secondView in
                secondView.width == 44
                secondView.height == 44
                secondView.left == firstView.right + 5
            }
            layout(self, view) { firstView, secondView in
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
