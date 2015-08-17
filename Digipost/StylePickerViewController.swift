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

    func currentSelectedAttributes() -> [TextStyleModel] {
        let selectedTextStyles = textStyleModels.flatMap { (arrayOfModels) -> [TextStyleModel] in
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
        segmentedControl.setupWithDigipostFont()
        textStyleModels = TextStyleModel.allTextStyleModels()
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 0.01))
    }

    func viewForInputView() -> UIView {
        return self.view
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.removeBorders()
    }

    func segmentedControlTableViewCellValueChanged(segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int) {
        if let indexPath = tableView.indexPathForCell(segmentedControlTableViewCell) {
        var models = textStyleModels[indexPath.row]

        var model = models[atIndex]
        model.enabled = newValue

        delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: model, enabled: newValue)
        }
    }

    func setupForAttributedString(attributedString: NSAttributedString )  {
        let allModels = textStyleModels.flatMap({ (array) -> Array<TextStyleModel> in
            return array
        })

        for model in allModels {
            switch model.value {
            case let value as UIFontDescriptorSymbolicTraits:
                if value == UIFontDescriptorSymbolicTraits.TraitBold {
                    model.enabled = attributedString.isBold()
                } else if value == UIFontDescriptorSymbolicTraits.TraitItalic {
                    model.enabled = attributedString.isItalic()
                }
                break
            default:
                break
            }
        }

        self.tableView.reloadData()
    }


    private func setBoldAttributeSelected() {

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
