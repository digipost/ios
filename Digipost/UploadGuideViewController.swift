//
//  UploadGuideViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 16.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UploadGuideViewController: UIViewController {
    @IBOutlet weak var uploadImage: UIImageView!
    
    @IBOutlet weak var horizontalUploadImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("upload guide navgationtiem title", comment: "title for navigation item on upload")
        self.uploadImage.accessibilityLabel = NSLocalizedString("upload guide image accessability hint", comment: "when user taps on image, this text should be read")
        self.uploadImage.isAccessibilityElement = true
        NSNotificationCenter.defaultCenter().addObserverForName("kFolderViewControllerNavigatedInList", object: nil, queue: nil) { note in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad ){
            uploadImage.image = UIImage.localizedImage(UIInterfaceOrientation.Portrait)
        } else {
            uploadImage.image = UIImage.localizedImage(interfaceOrientation)
            self.setImageForOrientation(interfaceOrientation)
        }
        self.pos_setDefaultBackButton()
        view.updateConstraints()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kFolderViewControllerNavigatedInList", object: nil)
    }

    func setImageForOrientation(forOrientation: UIInterfaceOrientation){
        if let horizontalImage = horizontalUploadImage {
            if (UIInterfaceOrientationIsLandscape(forOrientation)){
                horizontalImage.hidden = false
            } else {
                horizontalImage.hidden = true
            }
        }
        if let verticalImage = uploadImage {
            if (UIInterfaceOrientationIsLandscape(forOrientation)){
                verticalImage.hidden = true
            } else {
                verticalImage.hidden = false
            }
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad ){
            uploadImage.image = UIImage.localizedImage(UIInterfaceOrientation.Portrait)
        }else {
            uploadImage.image = UIImage.localizedImage(toInterfaceOrientation)
            horizontalUploadImage.image = UIImage.localizedImage(toInterfaceOrientation)
            setImageForOrientation(toInterfaceOrientation)
            
        }
    }
}
