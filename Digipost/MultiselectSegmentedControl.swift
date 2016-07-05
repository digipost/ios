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
    
    @IBInspectable public var iconFileNamesList : String {
        set(newList) {
            iconFileNames = iconFileNamesList.splitWithString(",", listString: newList)
        }
        get {
            return iconFileNames.joinWithSeparator(",")
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
    
    public func setImage(image : UIImage, atIndex index: Int) {
        let button = buttons[index]
        button.setImage(image, forState: UIControlState.Normal)
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
            buttons.append(button)
            button.backgroundColor = segmentBackgroundColor
            button.addTarget(self, action: #selector(MultiselectSegmentedControl.didTapButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = (i)
            self.addSubview(button)
            let bundle = NSBundle(forClass: self.dynamicType)
            button.setTitleColor(self.foregroundColor, forState: UIControlState.Normal)
            if iconFileNames.count > i {
                let iconName = iconFileNames[i]
                let image = UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)
                button.setImage(image, forState: .Normal)
            }
            
            constrain(self, button) { mainView, button in
                button.top == mainView.top
                button.bottom == mainView.bottom
            }
            
            if leftSideButton == nil  {
                constrain(self, button) { mainView, button in
                    button.left == mainView.left
                }
                
                leftSideButton = button
                
            } else {
                constrain(leftSideButton!, button) { leftSideButton, button in
                    button.left == leftSideButton.right
                    button.width == leftSideButton.width
                }
                
                leftSideButton = button
            }
        }
        
        constrain(self, leftSideButton!) { mainView, button in
            button.right == mainView.right
        }
        
    }
    
    
}