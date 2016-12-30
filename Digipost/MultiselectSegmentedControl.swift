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
    func multiselectSegmentedControlValueChanged(_ multiselectSegmentedControl: MultiselectSegmentedControl)
    
}

@IBDesignable open class MultiselectSegmentedControl : UIView {
    
    var selectedIndexes = [Bool]()
    var delegate : MultiselectSegmentedControlDelegate?
    
    var valueChangedClosure: ((_ value: Bool, _ atIndex: Int) -> Void)?
    
    @IBInspectable open var segmentSelectedBackgroundColor : UIColor = UIColor.gray
    @IBInspectable open var segmentBackgroundColor : UIColor = UIColor.white
    @IBInspectable open var foregroundColor : UIColor = UIColor.black
    @IBInspectable open var numberOfSegments : Int = 2
    
    fileprivate var iconFileNames = [String]()
    
    fileprivate var buttons = [UIButton]()
    
    @IBInspectable open var iconFileNamesList : String {
        set(newList) {
            iconFileNames = iconFileNamesList.splitWithString(",", listString: newList)
        }
        get {
            return iconFileNames.joined(separator: ",")
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }
    
    open func setImage(_ image : UIImage, atIndex index: Int) {
        let button = buttons[index]
        button.setImage(image, for: UIControlState())
    }
    
    open func setButtonSelectedState(_ selected: Bool, atIndex index: Int) {
        let tag = index
        selectedIndexes[tag] = selected
        for view in subviews {
            if let button = view as? UIButton, view.tag == tag  {
                button.backgroundColor = selected ? segmentSelectedBackgroundColor : segmentBackgroundColor
            }
        }
    }
    
    func didTapButton(_ button: UIButton) {
        if selectedIndexes[button.tag] {
            selectedIndexes[button.tag] = false
            button.backgroundColor = segmentBackgroundColor
            valueChangedClosure?(false, button.tag)
        } else {
            button.backgroundColor = segmentSelectedBackgroundColor
            selectedIndexes[button.tag] = true
            valueChangedClosure?(true, button.tag)
        }
        delegate?.multiselectSegmentedControlValueChanged(self)
    }
    
    /**
     Internal setup, must only be called once
     */
    fileprivate func setup() {
        var leftSideButton : UIButton?
        for i in 0..<self.numberOfSegments {
            selectedIndexes.append(false)
            let button = UIButton(frame: CGRect.zero)
            buttons.append(button)
            button.backgroundColor = segmentBackgroundColor
            button.addTarget(self, action: #selector(MultiselectSegmentedControl.didTapButton(_:)), for: UIControlEvents.touchUpInside)
            button.tag = (i)
            self.addSubview(button)
            let bundle = Bundle(for: type(of: self))
            button.setTitleColor(self.foregroundColor, for: UIControlState())
            if iconFileNames.count > i {
                let iconName = iconFileNames[i]
                let image = UIImage(named: iconName, in: bundle, compatibleWith: nil)
                button.setImage(image, for: UIControlState())
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
