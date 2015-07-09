//
//  StylePickerViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

protocol StylePickerViewControllerDelegate {

    func stylePickerViewControllerDidSelectStyle(stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool)

}

class StylePickerViewController: UIViewController, UITableViewDelegate, SegmentedControlTableViewCellDelegate {

    static let storyboardIdentifier = "stylePickerViewController"

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentedControl : UISegmentedControl!

    var delegate : StylePickerViewControllerDelegate?

    var textStyleModels : [[TextStyleModel]]!

    func setupForAttributedString(attributedString: NSAttributedString )  {

    }

    func currentSelectedAttributes() -> [TextStyleModel] {
        let selectedTextStyles = textStyleModels.flatMap { (arrayOfModels) -> Array<TextStyleModel> in
            return arrayOfModels.filter { (element) -> Bool in
                let booleanValue = element.enabled
                return element.enabled
            }
        }
        return selectedTextStyles
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        textStyleModels = TextStyleModel.allTextStyleModels()
    }

    func segmentedControlTableViewCellValueChanged(segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int) {
        let indexPath = tableView.indexPathForCell(segmentedControlTableViewCell)
        var models = textStyleModels[indexPath!.row]

        var model = models[atIndex]
        model.enabled = newValue

        delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: model, enabled: newValue)

        for (model, index) in enumerate(models) {

        }

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
