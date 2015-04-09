//
//  ComposerViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

extension UIImage{
    
    func resize(toSize size: CGSize, completionHandler: (resizedImage: UIImage, data: NSData) ->() ){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            self.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImagePNGRepresentation(resizedImage)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: resizedImage, data: imageData)
            })
        })
    }
}

class ComposerViewController: UIViewController, ModuleSelectorViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    var tableViewDataSource: ComposerTableViewDataSource?
    var tableViewDelegate: ComposerTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - TableView Setup
    
    func setupTableView(){
        tableViewDataSource = ComposerTableViewDataSource(asDataSourceForTableView: tableView)
        tableViewDelegate = ComposerTableViewDelegate(asDelegateForTableView: tableView)
        let textModuleTableViewCellNib = UINib(nibName: "TextModuleTableViewCell", bundle: nil)
        tableView.registerNib(textModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.textModuleCellIdentifier)
        let imageModuleTableViewCellNib = UINib(nibName: "ImageModuleTableViewCell", bundle: nil)
        tableView.registerNib(imageModuleTableViewCellNib, forCellReuseIdentifier: Constants.Composer.imageModuleCellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    // MARK: - ModuleSelectorViewController Delegate
    
    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didtSelectModule module: ComposerModule) {
        
        switch module.type{
            
        case .ImageModule:
            
            let squareSize = CGSizeMake(tableView.frame.width, tableView.frame.width)
            module.image?.resize(toSize: squareSize, completionHandler: { (resizedImage, data) -> () in
                module.image = resizedImage
            })
            
        case .TextModule:
            println()
        }
        
        tableViewDataSource?.tableData.append(module)
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
            let moduleSelectViewController = segue.destinationViewController as ModuleSelectorViewController
            moduleSelectViewController.delegate = self
        }
    }
    

}
