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
            delegate?.segmentedControlTableViewCellValueChanged(self, newValue: newValue, atIndex: index)
        }

    }

    func setupWithModels(textStyleModels : [TextStyleModel] ) {

        for (index, model) in enumerate(textStyleModels) {
            multiselectSegmentedControl.setImage(UIImage(named: model.preferredIconName!)!, atIndex: index)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}