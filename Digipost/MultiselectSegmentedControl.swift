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

    @IBInspectable public var iconFileNamesList : String {
        set(newList) {
            iconFileNames = iconFileNamesList.splitWithString(",", listString: newList)
        }
        get {
            return ",".join(iconFileNames)
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }

    public func setButtonSelectedState(selected: Bool, atIndex index: Int) {
        let tag = index
        selectedIndexes[tag] = selected
        for view in subviews {
            if let button = view as? UIButton where view.tag == tag  {
                button.backgroundColor = selected ? segmentSelectedBackgroundColor : segmentBackgroundColor
            }
        }
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
        var leftSideButton : UIButton?
        for i in 0..<self.numberOfSegments {
            selectedIndexes.append(false)
            let button = UIButton(frame: CGRectZero)
            button.backgroundColor = segmentBackgroundColor
            button.addTarget(self, action: Selector("didTapButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = (i)
            self.addSubview(button)
            let bundle = NSBundle(forClass: self.dynamicType)
            button.setTitleColor(self.foregroundColor, forState: UIControlState.Normal)
            if iconFileNames.count > i {
                let iconName = iconFileNames[i]
                let image = UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)
                button.setImage(image, forState: .Normal)
            }

            layout(self, button) { mainView, button in
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
                    button.width == leftSideButton.width
                }

                leftSideButton = button
            }
        }

        layout(self, leftSideButton!) { mainView, button in
            button.right == mainView.right
        }

    }


}