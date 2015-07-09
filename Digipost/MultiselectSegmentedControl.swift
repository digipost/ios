//  MultiselectSegmentedControl.swift
//  Digipost
//
//  Created by Håkon Bogen on 08/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation
import Cartography

protocol MultiselectSegmentedControlDelegate {

    // see selectedIndexes to find out what indexes are selected
    func multiselectSegmentedControlValueChanged(multiselectSegmentedControl: MultiselectSegmentedControl)

}

@IBDesignable public class MultiselectSegmentedControl : UIView {

    var selectedIndexes = [Bool]()
    var delegate : MultiselectSegmentedControlDelegate?

    var valueChangedClosure: ((value: Bool, atIndex: Int) -> Void)?

    @IBInspectable public var segmentSelectedBackgroundColor : UIColor = UIColor.grayColor()
    @IBInspectable public var segmentBackgroundColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var foregroundColor : UIColor = UIColor.blackColor()
    @IBInspectable public var numberOfSegments : Int = 2

    private var iconFileNames = [String]()
    private var buttons = [UIButton]()
    private var hasDoneLayout = false

    @IBInspectable public var iconFileNamesList : String {
        set(newList) {
            iconFileNames = iconFileNamesList.splitWithString(",", listString: newList)
        }
        get {
            return ",".join(iconFileNames)
        }
    }


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

        if selectedIndexes[button.tag] {
            selectedIndexes[button.tag] = false
            button.backgroundColor = segmentBackgroundColor
            valueChangedClosure?(value: false, atIndex: button.tag)
        } else {
            button.backgroundColor = segmentSelectedBackgroundColor
            selectedIndexes[button.tag] = true
            valueChangedClosure?(value: true, atIndex: button.tag)
        }
        delegate?.multiselectSegmentedControlValueChanged(self)
    }

    /**
    Internal setup, must only be called once
    */
    private func setup() {
        let widthPerSegment = self.frame.size.width / CGFloat(self.numberOfSegments)
        var leftSideButton : UIButton?
        for i in 0..<self.numberOfSegments {
            selectedIndexes.append(false)
            let button = UIButton(frame: CGRectZero)
            button.backgroundColor = segmentBackgroundColor
            button.addTarget(self, action: Selector("didTapButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = i
            self.addSubview(button)
            let bundle = NSBundle(forClass: self.dynamicType)
            button.setTitleColor(self.foregroundColor, forState: UIControlState.Normal)
            if iconFileNames.count > i {
                let iconName = iconFileNames[i]
                let image = UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)
                let newImage = image?.scaleToSize(CGSizeMake(image!.size.width / 2 , image!.size.height / 2))
                button.setImage(newImage, forState: .Normal)
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