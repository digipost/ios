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
        
//        NSString *identifier = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
//        NSArray *segments = [identifier componentsSeparatedByString:@"_"];
//        
//        if ( [segments count] > 1 ) {
//            identifier = segments[0];
//        } else {
//            identifier = identifier;
//        }
//        
//        NSString *fullname = [NSString stringWithFormat:@"%@-%@", name, identifier];
//        UIImage *image = [UIImage imageNamed:fullname];
//        
//        if ( image ) {
//            return image;
//        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kFolderViewControllerNavigatedInList", object: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
