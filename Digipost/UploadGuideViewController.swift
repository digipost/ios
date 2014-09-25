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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserverForName("kFolderViewControllerNavigatedInList", object: nil, queue: nil) { note in
           self.dismissViewControllerAnimated(false, completion: nil)
        }
        let identifier = NSLocale.autoupdatingCurrentLocale().localeIdentifier
        let segments = identifier.componentsSeparatedByString("_")
        
        if let localeName = segments[0] as String? {
            if (localeName.lowercaseString == "nb"){
                uploadImage.image = UIImage(named: "Lastopp_norsk_vertikal")
            }else {
                let image = UIImage(named: "Lastopp_engelsk_vertikal")
                uploadImage.image = UIImage(named: "Lastopp_engelsk_vertikal")
            }
            view.updateConstraints()
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kFolderViewControllerNavigatedInList", object: nil)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
            uploadImage.image = UIImage(named: "Veileder_lastopp_horisontalt")
        }else {
            uploadImage.image = UIImage(named: "Veileder")
        }
        
    }
}
