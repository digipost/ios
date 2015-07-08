//
//  SegmentedControlTableViewCell.swift
//  Digipost
//
//  Created by Håkon Bogen on 08/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

protocol SegmentedControlTableViewCellDelegate {
    func segmentedControlTableViewCellDidSelectControlAtIndex(segmentedControlTableViewCell: SegmentedControlTableViewCell, indexTapped: Int)

}

class SegmentedControlTableViewCell: UITableViewCell {

    var delegate : SegmentedControlTableViewCellDelegate?

    @IBOutlet weak var segmentedControl : UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func valueChanged(sender: UISegmentedControl) {

    }
}