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

import UIKit
import Cartography

protocol StylePickerViewControllerDelegate {

    func stylePickerViewControllerDidSelectStyle(_ stylePickerViewController : StylePickerViewController, textStyleModel : TextStyleModel, enabled: Bool)

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
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
    }

    func viewForInputView() -> UIView {
        return self.view
    }

    func currentShowingTextStyleModels() -> [[TextStyleModel]] {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        return textStyleModels[selectedIndex]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.removeBorders()
    }

    func segmentedControlTableViewCellValueChanged(_ segmentedControlTableViewCell: SegmentedControlTableViewCell, newValue: Bool, atIndex: Int) {
        if let indexPath = tableView.indexPath(for: segmentedControlTableViewCell) {
            var models = currentShowingTextStyleModels()[indexPath.row]

            let model = models[atIndex]
            model.enabled = newValue

            delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: model, enabled: newValue)

        }
    }

    func setupForAttributedString(_ attributedString: NSAttributedString )  {
        let allModels = currentShowingTextStyleModels().flatMap({ (array) -> Array<TextStyleModel> in
            return array
        })

        for model in allModels {
            switch model.value {
            case let value as UIFontDescriptorSymbolicTraits:
                if value == UIFontDescriptorSymbolicTraits.traitBold {
                    model.enabled = attributedString.isBold()
                } else if value == UIFontDescriptorSymbolicTraits.traitItalic {
                    model.enabled = attributedString.isItalic()
                }
                break
            default:
                break
            }
        }

        self.tableView.reloadData()
    }

    func setCurrentStyling(_ styling : [AnyHashable: Any]) {
        // if the stylepicker isnt shown, don't update it
        if self.view.superview == nil {
            return
        }

        var selectedModels = [TextStyleModel]()

        if let styleArray = styling["style"] as? [String]  {
            let classesDictionary = styling["classes"] as? [AnyHashable: Any]

            let allTextStyleModels = currentShowingTextStyleModels().flatMap({ (array) -> Array<TextStyleModel> in
                return array
            })

            var classesArray = [String]()

            for (key, value) in classesDictionary! {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTextStyleModels = currentShowingTextStyleModels()[indexPath.row]

        if selectedTextStyleModels.count > 1 {
            let storyboard = UIStoryboard(name: "StylePicker", bundle: Bundle.main)
            self.stylePickerDetailListViewController = storyboard.instantiateViewController(withIdentifier: "stylePickerDetailListViewController") as? StylePickerDetailListViewController
            stylePickerDetailListViewController?.textStyleModels = selectedTextStyleModels
            stylePickerDetailListViewController?.delegate = self
            animateDetailListViewController(true)
        }
    }

    fileprivate func animateDetailListViewController(_ shouldShowView: Bool) {
        if shouldShowView {

            if let newView = self.stylePickerDetailListViewController?.view {
                self.view.addSubview(newView)
                let group = constrain(self.view, newView ) { firstView, secondView in
                    secondView.left == firstView.right
                    secondView.width == firstView.width
                    secondView.top == firstView.top
                    secondView.bottom == firstView.bottom
                }

                self.view.layoutIfNeeded()

                UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
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
                _ = constrain(self.view, self.stylePickerDetailListViewController!.view!, replace: self.stylePickerDetailListViewControllerConstraintGroup! ) { firstView, secondView in
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
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }

    func stylePickerDetailLIstViewControllerDidSelectTextStyleModel(_ stylePickerDetailListViewController: StylePickerDetailListViewController, textStyleModel: TextStyleModel) {
        animateDetailListViewController(false)
        delegate?.stylePickerViewControllerDidSelectStyle(self, textStyleModel: textStyleModel, enabled: true)
    }

    func stylePickerDetailLIstViewControllerDidTapBackButton(_ stylePickerDetailListViewController: StylePickerDetailListViewController) {
        animateDetailListViewController(false)
    }

    @IBAction func segmentedControlValueChanged(_ sender : UISegmentedControl) {
        self.tableView.reloadData()
    }
}
