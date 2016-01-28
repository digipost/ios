//
//  SegmentedControlTableViewCell.swift
//  Digipost
//
//  Created by Håkon Bogen on 08/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

protocol SegmentedControlTableViewCellDelegate {
    func segmentedControlTableViewCellValueChanged(segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int)
}

class SegmentedControlTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var multiselectSegmentedControl : MultiselectSegmentedControl!
    
    var delegate : SegmentedControlTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        multiselectSegmentedControl.valueChangedClosure = { (newValue, index) -> Void in
            self.delegate?.segmentedControlTableViewCellValueChanged(self, newValue: newValue, atIndex: index)
        }
        
    }
    
    func setupWithModels(textStyleModels : [TextStyleModel] ) {
        
        for (index, model) in textStyleModels.enumerate() {
            if let actualImage = UIImage(named:  model.preferredIconName!) {
                multiselectSegmentedControl.setImage(actualImage, atIndex: index)
            } else {
                multiselectSegmentedControl.setImage(UIImage(named: "Bold")!, atIndex: index)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}