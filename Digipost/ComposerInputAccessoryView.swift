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

//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var textView: UITextView!
//    
//    @IBOutlet weak var leftView: UIView!
//    @IBOutlet weak var centerView: UIView!
//    @IBOutlet weak var rightView: UIView!
//    
//    @IBOutlet weak var doneButton: UIButton!





    var containedViews = [UIView]()

    func setupWithTextComposerModule(textComposerModule : TextComposerModule) {

        for view in containedViews {
            if let composerTypeButton = view as? ComposerTypeButton {
                composerTypeButton.setTitle("Headline", forState: .Normal)
            } else if let textAttributeButton = view as? TextAttributeButton   {
                
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
                secondView.width == 44
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
