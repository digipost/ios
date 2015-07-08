//  MultiselectSegmentedControl.swift
//  Digipost
//
//  Created by Håkon Bogen on 08/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import Cartography

@IBDesignable public class MultiselectSegmentedControl : UIView {

    private var iconFileNames = [String]()

    private var buttons = [UIButton]()

    private var selectedIndex = [Bool]()

    @IBInspectable public var segmentSelectedBackgroundColor : UIColor = UIColor.grayColor() {
        didSet {

        }
    }

    @IBInspectable public var segmentBackgroundColor : UIColor = UIColor.whiteColor() {
        didSet {

        }
    }

    @IBInspectable public var foregroundColor : UIColor = UIColor.redColor() {
        didSet {

        }
    }

    @IBInspectable public var numberOfSegments : Int = 0 {
        didSet {

        }
    }


    @IBInspectable public var iconFileNamesList : String {
        set(newList) {
            iconFileNames = iconFileNamesList.splitWithString(",", listString: newList)
        }
        get {
            return ",".join(iconFileNames)
        }
    }

    private var hasDoneLayout = false

    public override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout == false {
            hasDoneLayout = true
            setup()
        }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }

    func didTapButton(button: UIButton) {
        if selectedIndex[button.tag] {
            selectedIndex[button.tag] = false
            button.backgroundColor = segmentBackgroundColor
        } else {
            button.backgroundColor = segmentSelectedBackgroundColor
            selectedIndex[button.tag] = true
        }
    }

    /**
    Internal setup, must only be called once
    */
    private func setup() {
        let widthPerSegment = self.frame.size.width / CGFloat(self.numberOfSegments)
        var leftSideButton : UIButton?
        for i in 0..<self.numberOfSegments {
            selectedIndex.append(false)
            let button = UIButton(frame: CGRectZero)
            button.backgroundColor = segmentBackgroundColor
            button.addTarget(self, action: Selector("didTapButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = i
            self.addSubview(button)
            let bundle = NSBundle(forClass: self.dynamicType)
            button.setTitleColor(self.foregroundColor, forState: UIControlState.Normal)
            if iconFileNames.count > i {
                let iconName = iconFileNames[i]
                button.setImage(UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
            }

            layout(self, button) { mainView, button in
                button.width == widthPerSegment
                button.top == mainView.top
                button.bottom == mainView.bottom
            }

            if leftSideButton == nil  {
                layout(self, button) { mainView, button in
                    button.left == mainView.left
                }
                leftSideButton = button
            } else {
                layout(leftSideButton!, button) { leftSideButton, button in
                    button.left == leftSideButton.right
                }
                leftSideButton = button
            }
        }
    }


}