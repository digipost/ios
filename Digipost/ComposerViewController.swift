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

class ComposerViewController: UIViewController, ModuleSelectorViewControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDelegateReorderExtension {

    @IBOutlet var tableView: UITableView!
    var deleteComposerModuleView: DeleteComposerModuleView!
    var initialIndexPathForMovingRow: NSIndexPath!
    
    var tableViewDataSource: ComposerTableViewDataSource!
    var currentlyEditingTextView: UITextView?
    var recipients = [Recipient]()

    // used when calculating size of textviews for cells that are bigger than one line
    var exampleTextView : UITextView?

    // the selected digipost address for the mailbox that should show as sender when sending current compsing letter
    var mailboxDigipostAddress : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - TableView Delegate Reorder functions
    
    func tableView(tableView: UITableView!, beganMovingRowAtPoint point: CGPoint) {
        println("Began moving row at point \(point)")
        initialIndexPathForMovingRow = tableView.indexPathForRowAtPoint(point)
        deleteComposerModuleView = NSBundle.mainBundle().loadNibNamed("DeleteComposerModuleView", owner: self, options: nil)[0] as! DeleteComposerModuleView
        deleteComposerModuleView.frame = CGRectMake(0, view.frame.height , self.view.frame.width, 88)
        self.view.addSubview(deleteComposerModuleView)
        deleteComposerModuleView.show()

    }
    
    func tableView(tableView: UITableView!, changedPositionOfRowAtPoint point: CGPoint) {
        println("Position of row changed to point: \(point)")
    }
    
    func tableView(tableView: UITableView!, endedMovingRowAtPoint point: CGPoint) {
        println("Position of moving row ended at point: \(point)")
        let translatedPoint = tableView.convertPoint(point, toView: deleteComposerModuleView)
        if deleteComposerModuleView.pointInside(translatedPoint, withEvent: nil){
            deleteComposerModule()
        }
        
    }
    
    func deleteComposerModule(){
        if initialIndexPathForMovingRow != nil {
            println("Delete")
        }
        initialIndexPathForMovingRow = nil

        deleteComposerModuleView.hide()
    }
    
    // MARK: - TableView Setup
    
    func setupTableView(){
        tableViewDataSource = ComposerTableViewDataSource(asDataSourceForTableView: tableView)
        let textModuleTableViewCellNib = UINib(nibName: "TextModuleTableViewCell", bundle: nil)
        tableView.registerNib(textModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.textModuleCellIdentifier)
        let imageModuleTableViewCellNib = UINib(nibName: "ImageModuleTableViewCell", bundle: nil)
        tableView.registerNib(imageModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.imageModuleCellIdentifier)
        tableView.delegate = self

        setupKeyboardNotifcationListenerForScrollView(self.tableView)
    }

    // MARK: - UITextVeiew Delegate
    
    func textViewDidChange(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = tableViewDataSource.tableData[indexPath.row] as? TextComposerModule {
                textModule.text = textView.text
                textModule.textAlignment = textView.textAlignment
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        currentlyEditingTextView = textView

    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = tableViewDataSource.tableData[indexPath.row] as? TextComposerModule {
                textModule.text = textView.text
            }
        }
        currentlyEditingTextView = nil
    }
    
    func indexPathForCellContainingTextView(textView: UITextView) -> NSIndexPath? {
        let location = tableView.convertPoint(textView.center, fromView: textView)
        return tableView.indexPathForRowAtPoint(location)
    }
    
    // MARK: - ModuleSelectorViewController Delegate
    
    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule) {
        tableViewDataSource.tableData.append(module)
        tableView.reloadData()
        if let imageModule = module as? ImageComposerModule {
            let squareSize = CGSizeMake(tableView.frame.width, tableView.frame.width)
            if let imageModule = module as? ImageComposerModule {
                imageModule.image.scaleToSize(squareSize)
            }
        } else if let imageModule = module as? TextComposerModule {
            if let indexPath = tableViewDataSource.indexPath(module: module) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell
                let textModule = module as? TextComposerModule
                cell?.moduleTextView.font = textModule?.font
                cell?.setLabel(textModule!.font)
                cell?.moduleTextView.becomeFirstResponder()
                currentlyEditingTextView = cell?.moduleTextView
                cell?.moduleTextView.delegate = self
            }
        }

        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController) {
        moduleSelectorViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {	
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            moduleSelectViewController.delegate = self
        }
        
        if let previewViewController = segue.destinationViewController as? PreviewViewController{
            
            if let textView = currentlyEditingTextView{
                textView.resignFirstResponder()
            }
            previewViewController.recipients = recipients
            previewViewController.modules = tableViewDataSource.tableData
        }
    }

}
