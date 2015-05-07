//
//  ComposerViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
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
        setupComposerInputAccessoryView()
        addComposerModuleButton = AddComposerModuleButton.layoutInView(self.view)
        addComposerModuleButton.addTarget(self, action: Selector("didTapAddComposerModuleButton:"), forControlEvents: .TouchUpInside)
    }

    func didTapAddComposerModuleButton(button: UIButton) {
        performSegueWithIdentifier("presentModuleSelectorSegue", sender: self)
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
        composerInputAccessoryView.setupWithStandardLayout(self, selector: Selector("didTapTextAttributeButton:"))
    }

    func currentEditingComposerModuleAndTextView() -> (TextComposerModule, UITextView)? {
        for cell in self.tableView.visibleCells() {
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

    // MARK: - UITextView Delegate
    
    func textViewDidChange(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = composerModules[indexPath.row] as? TextComposerModule {
                textModule.text = textView.text
                textModule.textAttribute.textAlignment = textView.textAlignment
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let indexPath = NSIndexPath(forRow: textField.tag, inSection: 0)

        let textComposerModule = composerModules[textField.tag]
        if let inputAccessoryView = textField.inputAccessoryView as? ComposerInputAccessoryView {

        }

        return false
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if let textModule = composerModules[textView.tag] as? TextComposerModule {
            println(textModule.textAttribute)
            println(textView.tag)
            composerInputAccessoryView.refreshUIWithTextComposerModule(textModule)
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if let textModule = composerModules[textField.tag] as? TextComposerModule {
            composerInputAccessoryView.refreshUIWithTextComposerModule(textModule)
        }
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
                cell?.moduleTextView.font = textModule?.textAttribute.font
                cell?.moduleTextView.delegate = self
                cell?.moduleTextView.becomeFirstResponder()
            }
        }
        
        let dimView = view as? DimView
        dimView?.dim()
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController) {
        let dimView = view as? DimView
        dimView?.dim()
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
                println("Saved")
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
            
            let dimView = view as? DimView
            dimView?.dim()
        }
        
        if let previewViewController = segue.destinationViewController as? PreviewViewController{
            previewViewController.recipients = recipients
            previewViewController.modules = composerModules
            previewViewController.mailboxDigipostAddress = mailboxDigipostAddress
        }
    }
}
