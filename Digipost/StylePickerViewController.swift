//
//  StylePickerViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 07/07/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit
import Cartography

protocol StylePickerViewControllerDelegate {

    func stylePickerViewControllerDidSelectStyle(stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool)

}

class StylePickerViewController: UIViewController, UITableViewDelegate, SegmentedControlTableViewCellDelegate {

    static let storyboardIdentifier = "stylePickerViewController"

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentedControl : UISegmentedControl!

    var delegate : StylePickerViewControllerDelegate?

    var textStyleModels : [[TextStyleModel]]!

    var stylePickerDetailListViewController : StylePickerDetailListViewController?

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


    func setKeywordsEnabled(keywords: [String]) {
        var selectedModels = [TextStyleModel]()

        let allTextStyleModels = textStyleModels.flatMap({ (array) -> Array<TextStyleModel> in
            return array
        })

        for model in allTextStyleModels {
            if contains(keywords, model.keyword) {
                selectedModels.append(model)
                model.enabled = true
            } else {
                model.enabled = false
            }
        }

        self.tableView.reloadData()
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedTextStyleModels = textStyleModels[indexPath.row]

        if selectedTextStyleModels.count > 1 {
            let storyboard = UIStoryboard(name: "StylePicker", bundle: NSBundle.mainBundle())
            let viewController = storyboard.instantiateViewControllerWithIdentifier("stylePickerDetailListViewController") as? UIViewController
            if let newView = viewController?.view {
                self.view.addSubview(newView)

                var group = constrain(self.view, newView ) { firstView, secondView in
                    secondView.left == firstView.right
                    secondView.width == firstView.width
                    secondView.top == firstView.top
                    secondView.bottom == firstView.bottom
                }
                self.view.layoutIfNeeded()

                UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    layout(self.view, newView, replace: group) { firstView, secondView in
                        secondView.left == firstView.left
                        secondView.top == firstView.top
                        secondView.right == firstView.right
                        secondView.bottom == firstView.bottom
                    }
                    self.view.layoutIfNeeded()

                }, completion: { (complete) -> Void in

                })

                stylePickerDetailListViewController = viewController as? StylePickerDetailListViewController
                stylePickerDetailListViewController?.textStyleModels = selectedTextStyleModels

            }
        }
    }

}
