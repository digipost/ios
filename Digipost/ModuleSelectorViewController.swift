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

class ModuleSelectorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker = UIImagePickerController()
    var delegate: ModuleSelectorViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addHeadline(sender: AnyObject) {
        addTextModule(UIFontTextStyleHeadline)
    }
    
    @IBAction func addSubheadline(sender: AnyObject) {
        addTextModule(UIFontTextStyleSubheadline)
    }

    @IBAction func addBody(sender: AnyObject) {
        addTextModule(UIFontTextStyleBody)
    }
 
    @IBAction func addCaption(sender: AnyObject) {
        addTextModule(UIFontTextStyleCaption1)
    }
    @IBAction func addFootnote(sender: AnyObject) {
        addTextModule(UIFontTextStyleFootnote)
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        delegate?.moduleSelectorViewControllerWasDismissed(self)
    }
    
    func addTextModule(textStyle: String){
        let selectedModule = TextComposerModule(moduleWithFont: UIFont.preferredFontForTextStyle(textStyle))
        delegate?.moduleSelectorViewController(self, didSelectModule: selectedModule)
    }
    @IBAction func addImage(sender: UIButton) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
