//
//  UploadGuideViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 16.09.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UploadGuideViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserverForName("kFolderViewControllerNavigatedInList", object: nil, queue: nil) { note in
           self.dismissViewControllerAnimated(false, completion: nil)
        }
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
