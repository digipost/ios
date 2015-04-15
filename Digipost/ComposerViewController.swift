//
//  ComposerViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class ComposerViewController: UIViewController, ModuleSelectorViewControllerDelegate, UITextViewDelegate, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var tableViewDataSource: ComposerTableViewDataSource!
    var currentlyEditingTextView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - TableView Setup
    
    func setupTableView(){
        tableViewDataSource = ComposerTableViewDataSource(asDataSourceForTableView: tableView)
        let textModuleTableViewCellNib = UINib(nibName: "TextModuleTableViewCell", bundle: nil)
        tableView.registerNib(textModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.textModuleCellIdentifier)
        let imageModuleTableViewCellNib = UINib(nibName: "ImageModuleTableViewCell", bundle: nil)
        tableView.registerNib(imageModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.imageModuleCellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    // MARK: - UITextVeiew Delegate
    
    func textViewDidChange(textView: UITextView) {
        if let row = indexPathForCellContainingTextView(textView)?.row{
            let newHeight = textView.frame.height
            tableViewDataSource.resizeHeight(newHeight, forCellAtRow: row)
            if let textModule = tableViewDataSource.tableData[row] as? ComposerTextModule{
                textModule.height = newHeight
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        currentlyEditingTextView = textView
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let indexPath = indexPathForCellContainingTextView(textView){
            if let textModule = tableViewDataSource.tableData[indexPath.row] as? ComposerTextModule {
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
        
        switch module.type{
            
        case .ImageModule:
            
            let squareSize = CGSizeMake(tableView.frame.width, tableView.frame.width)
            
            if let imageModule = module as? ComposerImageModule {
                imageModule.image?.scaleToSize(squareSize)
            }
            
        case .TextModule:
            
            if let indexPath = tableViewDataSource.indexPath(module: module) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? TextModuleTableViewCell
                let textModule = module as? ComposerTextModule
                cell?.moduleTextView.font = textModule?.font
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
        
        if segue.destinationViewController.isKindOfClass(ModuleSelectorViewController){
            let moduleSelectViewController = segue.destinationViewController as! ModuleSelectorViewController
            moduleSelectViewController.delegate = self
            
        } else if segue.destinationViewController.isKindOfClass(PreviewViewController){
            
            if let textView = currentlyEditingTextView{
                textView.resignFirstResponder()
            }
            
            let previewViewController = segue.destinationViewController as! PreviewViewController
            previewViewController.modules = tableViewDataSource.tableData
            
        }
    }
    

}
