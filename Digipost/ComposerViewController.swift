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
import AHKActionSheet
import SingleLineKeyboardResize


@objc protocol TableViewReorderingDelegate{
    func tableView(tableView: UITableView, didStartReorderingRowAtPoint point: CGPoint)
}

class ComposerViewController: UIViewController, ModuleSelectorViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDelegateReorderExtension {
    
    @IBOutlet var tableView: UITableView!
    var deleteComposerModuleView: DeleteComposerModuleView!
    
    @IBOutlet weak var previewButton: UIBarButtonItem!
    @IBOutlet weak var documentTitleLabel: UILabel!
    @IBOutlet weak var documentTitleTextField: UITextField!
    
    var recipients = [Recipient]()
    
    var composerModules = [ComposerModule]()
    
    // used when calculating size of textviews for cells that are bigger than one line
    var exampleTextView : UITextView?
    
    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?
    
    var composerInputAccessoryView : ComposerInputAccessoryView!
    
    
    weak var stylePickerViewController : StylePickerViewController?
    
    var addComposerModuleButton : AddComposerModuleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsLongPressToReorder = true
        title = NSLocalizedString("composer view navigation bar title", comment: "Composer title")
        previewButton.title = NSLocalizedString("composer view preview button title", comment: "Preview button title")
        documentTitleLabel.text = NSLocalizedString("composer view document title label", comment: "Title label")
        documentTitleTextField.placeholder = NSLocalizedString("composer view title placeholder", comment: "Title placeholder text")
        documentTitleTextField.delegate = self
        setupTableView()
        addComposerModuleButton = AddComposerModuleButton.layoutInView(self.view)
        addComposerModuleButton.addTarget(self, action: #selector(ComposerViewController.didTapAddComposerModuleButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    func didTapAddComposerModuleButton(button: UIButton) {
        let moduleSelectorViewController = UIStoryboard(name: "DocumentComposer", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("moduleSelectorViewController") as! ModuleSelectorViewController
        moduleSelectorViewController.modalPresentationStyle = .Custom
        moduleSelectorViewController.transitioningDelegate = self
        moduleSelectorViewController.delegate = self
        presentViewController(moduleSelectorViewController, animated: true) { () -> Void in
            
        }
    }
    
    @IBAction func previewButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("goToPreview", sender: self)
    }
    
    // MARK: - TableView Setup
    func setupTableView(){
        let textModuleTableViewCellNib = UINib(nibName: "TextModuleTableViewCell", bundle: nil)
        tableView.registerNib(textModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.textModuleCellIdentifier)
        let imageModuleTableViewCellNib = UINib(nibName: "ImageModuleTableViewCell", bundle: nil)
        tableView.registerNib(imageModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.imageModuleCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        setupKeyboardNotifcationListenerForScrollView(self.tableView)
    }
    
    func setupComposerInputAccessoryView() {
        composerInputAccessoryView = NSBundle.mainBundle().loadNibNamed("ComposerInputAccesoryView", owner: self, options: nil)[0] as! ComposerInputAccessoryView
        composerInputAccessoryView.setupWithStandardLayout(self, selector: #selector(ComposerViewController.didTapTextAttributeButton(_:)))
    }
    
    func currentEditingComposerModuleAndTextView() -> (TextComposerModule, UITextView)? {
        for cell in self.tableView.visibleCells {
            if let textModuleCell = cell as? TextModuleTableViewCell {
                if textModuleCell.moduleTextView.isFirstResponder() {
                    if let indexPath = indexPathForCellContainingTextView(textModuleCell.moduleTextView){
                        if let textModule = composerModules[indexPath.row] as? TextComposerModule {
                            return (textModule,textModuleCell.moduleTextView)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func didTapTextAttributeButton(sender: UIButton) {
        // do something with the current view!
        if let textAttributeButton = sender as? TextAttributeButton {
            if let editingComposerModuleAndTextView = currentEditingComposerModuleAndTextView() as (TextComposerModule, UITextView)! {
                editingComposerModuleAndTextView.1.style(textAttribute: textAttributeButton.textAttribute)
                composerInputAccessoryView.refreshUIWithTextAttribute(textAttributeButton.textAttribute)
                let textComposerModule = editingComposerModuleAndTextView.0
                textComposerModule.textAttribute = textComposerModule.textAttribute.textAttributeByAddingTextAttribute(textAttributeButton.textAttribute)
            }
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        let range = textView.selectedRange
        if range.length > 0 {
            let attributedString = textView.attributedText.attributedSubstringFromRange(range)
            stylePickerViewController?.setupForAttributedString(attributedString)
        } else {
            stylePickerViewController?.setupForAttributedString(NSAttributedString(string: " ", attributes: textView.typingAttributes))
        }
    }
    
    // MARK: - UITextView Delegate
    func textViewDidChange(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = composerModules[indexPath.row] as? TextComposerModule {
                textModule.attributedText = textView.attributedText
                textModule.textAttribute.textAlignment = textView.textAlignment
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let indexPath = indexPathForCellContainingTextView(textView){
                if let textModule = composerModules[indexPath.row] as? TextComposerModule {
                    textModule.appendNewParagraph()
                    textView.attributedText = textModule.attributedText
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    return false
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let indexPath = NSIndexPath(forRow: textField.tag, inSection: 0)
        return false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func indexPathForCellContainingTextView(textView: UITextView) -> NSIndexPath? {
        let location = tableView.convertPoint(textView.center, fromView: textView)
        return tableView.indexPathForRowAtPoint(location)
    }
    
    
    // MARK: - ModuleSelectorViewController Delegate
    
    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule) {
        composerModules.append(module)
        tableView.reloadData()
        if let imageModule = module as? ImageComposerModule {
            let squareSize = CGSizeMake(tableView.frame.width, tableView.frame.width)
            if let imageModule = module as? ImageComposerModule {
                imageModule.image.scaleToSize(squareSize)
            }
        } else if let imageModule = module as? TextComposerModule {
            if let indexPath = indexPath(module: module) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell
                let textModule = module as? TextComposerModule
                cell?.moduleTextView.delegate = self
                let storyboard = UIStoryboard(name: "StylePicker", bundle: NSBundle.mainBundle())
                let stylePickerViewController : StylePickerViewController = {
                    if self.stylePickerViewController == nil {
                        self.stylePickerViewController = storyboard.instantiateViewControllerWithIdentifier(StylePickerViewController.storyboardIdentifier) as? StylePickerViewController
                    }
                    return self.stylePickerViewController!
                }()
                stylePickerViewController.delegate = self
                cell!.moduleTextView.inputView = stylePickerViewController.view
                cell?.moduleTextView.reloadInputViews()
                cell?.moduleTextView.becomeFirstResponder()
                cell?.moduleTextView.reloadInputViews()
            }
        }
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController) {
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancelButtonAction(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: NSLocalizedString("composer view close alert title", comment: "alert title"),
            message: NSLocalizedString("composer view close alert message", comment: "close alert message"),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveDraftAction = UIAlertAction(title: NSLocalizedString("composer view close alert save draft button title", comment: "button title"),
            style: UIAlertActionStyle.Default)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        let quitAction = UIAlertAction(title: NSLocalizedString("composer view close alert quit button title", comment: "button title"),
            style: UIAlertActionStyle.Destructive)
            { [unowned self, alertController] (action: UIAlertAction!) -> Void in
                
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
        }
        
        alertController.addAction(saveDraftAction)
        alertController.addAction(quitAction)
        
        if composerModules.isEmpty{
            self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        } else {
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {	
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let moduleSelectViewController = segue.destinationViewController  as? ModuleSelectorViewController{
            moduleSelectViewController.delegate = self
        }
        
        if let previewViewController = segue.destinationViewController as? PreviewViewController{
            previewViewController.recipients = recipients
            previewViewController.modules = composerModules
            previewViewController.mailboxDigipostAddress = mailboxDigipostAddress
        }
    }
}
