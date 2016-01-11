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

class StylePickerViewController: UIViewController, UITableViewDelegate, SegmentedControlTableViewCellDelegate, StylePickerDetailListViewControllerDelegate {

    static let storyboardIdentifier = "stylePickerViewController"

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentedControl : UISegmentedControl!

    var delegate : StylePickerViewControllerDelegate?

    var textStyleModels : [[[TextStyleModel]]]!

    var stylePickerDetailListViewController : StylePickerDetailListViewController?

    var stylePickerDetailListViewControllerConstraintGroup : ConstraintGroup?

    func currentSelectedAttributes() -> [TextStyleModel] {
        let selectedTextStyles = currentShowingTextStyleModels().flatMap { (arrayOfModels) -> [TextStyleModel] in
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

    func currentShowingTextStyleModels() -> [[TextStyleModel]] {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        return textStyleModels[selectedIndex]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.removeBorders()
    }

    func segmentedControlTableViewCellValueChanged(segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int) {
        if let indexPath = tableView.indexPathForCell(segmentedControlTableViewCell) {
            var models = currentShowingTextStyleModels()[indexPath.row]

            var model = models[atIndex]
            model.enabled = newValue

            delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: model, enabled: newValue)

        }
    }

    func setupForAttributedString(attributedString: NSAttributedString )  {
        let allModels = currentShowingTextStyleModels().flatMap({ (array) -> Array<TextStyleModel> in
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

    func setCurrentStyling(styling : [NSObject : AnyObject]) {
        // if the stylepicker isnt shown, don't update it
        if self.view.superview == nil {
            return
        }

        var selectedModels = [TextStyleModel]()

        if let styleArray = styling["style"] as? [String], classesDictionary = styling["classes"] as? [NSObject : AnyObject]  {

            let allTextStyleModels = currentShowingTextStyleModels().flatMap({ (array) -> Array<TextStyleModel> in
                return array
            })

            var classesArray = [String]()

            for (key, value) in classesDictionary {
                if key == "length" {
                    continue
                }

                if let actualValue = value as? String {
                    classesArray.append(actualValue)
                }
            }

            for model in allTextStyleModels {
                if classesArray.contains(model.keyword) || styleArray.contains(model.keyword) {
                    selectedModels.append(model)
                    model.enabled = true
                } else {
                    model.enabled = false
                }
            }
            self.tableView.reloadData()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedTextStyleModels = currentShowingTextStyleModels()[indexPath.row]

        if selectedTextStyleModels.count > 1 {
            let storyboard = UIStoryboard(name: "StylePicker", bundle: NSBundle.mainBundle())
            self.stylePickerDetailListViewController = storyboard.instantiateViewControllerWithIdentifier("stylePickerDetailListViewController") as? StylePickerDetailListViewController
            stylePickerDetailListViewController?.textStyleModels = selectedTextStyleModels
            stylePickerDetailListViewController?.delegate = self
            animateDetailListViewController(shouldShowView: true)
        }
    }

    private func animateDetailListViewController(shouldShowView shouldShowView: Bool) {
        if shouldShowView {

            if let newView = self.stylePickerDetailListViewController?.view {
                self.view.addSubview(newView)
                var group = constrain(self.view, newView ) { firstView, secondView in
                    secondView.left == firstView.right
                    secondView.width == firstView.width
                    secondView.top == firstView.top
                    secondView.bottom == firstView.bottom
                }

                self.view.layoutIfNeeded()

                UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.stylePickerDetailListViewControllerConstraintGroup = constrain(self.view, newView, replace: group) { firstView, secondView in
                        secondView.left == firstView.left
                        secondView.top == firstView.top
                        secondView.right == firstView.right
                        secondView.bottom == firstView.bottom
                    }

                    self.view.layoutIfNeeded()

                    }, completion: { (complete) -> Void in

                })
            }
        } else {

            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                var group = constrain(self.view, self.stylePickerDetailListViewController!.view!, replace: self.stylePickerDetailListViewControllerConstraintGroup! ) { firstView, secondView in
                    secondView.left == firstView.right
                    secondView.width == firstView.width
                    secondView.top == firstView.top
                    secondView.bottom == firstView.bottom
                }

                }, completion: { (complete) -> Void in
                    self.stylePickerDetailListViewController?.view.removeFromSuperview()
                    self.stylePickerDetailListViewController = nil
            })

            if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
            }
        }
    }

    func stylePickerDetailLIstViewControllerDidSelectTextStyleModel(stylePickerDetailListViewController: StylePickerDetailListViewController, textStyleModel: TextStyleModel) {
        animateDetailListViewController(shouldShowView: false)
        delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: textStyleModel, enabled: true)
    }

    func stylePickerDetailLIstViewControllerDidTapBackButton(stylePickerDetailListViewController: StylePickerDetailListViewController) {
        animateDetailListViewController(shouldShowView: false)
    }

    @IBAction func segmentedControlValueChanged(sender : UISegmentedControl) {
        self.tableView.reloadData()
    }
}
