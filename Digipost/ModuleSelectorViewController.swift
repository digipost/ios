//
//  ModuleSelectorViewController.swift
//  ModuleSendEditor
//
//  Created by Henrik Holmsen on 23.02.15.
//  Copyright (c) 2015 Nettbureau AS. All rights reserved.
//

import UIKit

protocol ModuleSelectorViewControllerDelegate{
    func moduleSelectorViewController(moduleSelectorViewController: ModuleSelectorViewController, didSelectModule module: ComposerModule)
    func moduleSelectorViewControllerWasDismissed(moduleSelectorViewController: ModuleSelectorViewController)
}

class ModuleSelectorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var textAttributes : [TextAttribute]

    required init(coder aDecoder: NSCoder) {
        self.textAttributes = [TextAttribute]()
        super.init(coder: aDecoder)
    }

    class func setup(#textAttributes: [TextAttribute]) -> ModuleSelectorViewController {
        let moduleSelectorViewController = UIStoryboard(name: "DocumentComposer", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("moduleSelectorViewController") as! ModuleSelectorViewController
        moduleSelectorViewController.textAttributes = textAttributes
        return moduleSelectorViewController
    }

    var imagePicker = UIImagePickerController()
    var delegate: ModuleSelectorViewControllerDelegate?
    @IBOutlet weak var moduleSelectorView: UIView!
    @IBOutlet weak var moduleSelectorViewTitle: UILabel!

    let moduleTypeStrings = [NSLocalizedString("big headline table view cell title", comment: "Title for table view cell"),
                            NSLocalizedString("small headline table view cell title", comment: "Title for table view cell"),
                            NSLocalizedString("normal text table view cell title", comment: "Title for table view cell"),
                            NSLocalizedString("image table view cell title", comment: "Title for table view cell")]
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
        tableView.scrollEnabled = false
        tableView.rowHeight = 50
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.delegate?.moduleSelectorViewControllerWasDismissed(self)
    }
    
    func addTextModule(textStyle: String){
        let selectedModule = TextComposerModule(moduleWithFont: UIFont.preferredFontForTextStyle(textStyle))
        delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
    }
    
    func addImage() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let selectedModule = ImageComposerModule(image: image)
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let module : ComposerModule = {
            switch indexPath.row {
            case 0:
                return TextComposerModule.paragraphModule()
            case 1:
                return TextComposerModule.paragraphModule()
            case 2:
                fallthrough
            case 3:
                fallthrough
            default:
                break;
            }
            return TextComposerModule.paragraphModule()
        }()
        delegate?.moduleSelectorViewController(self, didSelectModule: module)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("moduleCell") as! UITableViewCell
        
        cell.textLabel?.text = moduleTypeStrings[indexPath.row]
        
        return cell
    }
    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {

//        for touch: AnyObject in touches {
//            let location = touch.locationInView(moduleSelectorView)
//            if moduleSelectorView.pointInside(location, withEvent: event) == false{
//                self.delegate?.moduleSelectorViewControllerWasDismissed(self)
//            }
//            
//        }
//    }

}
