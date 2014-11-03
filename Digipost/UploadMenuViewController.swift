//
//  UploadMenuViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 03/11/14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import UIKit

class UploadMenuViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var menuDataSource = UploadMenuDataSource()
    
    
    lazy var uploadImageController = UploadImageController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(tableView)
        tableView.dataSource = menuDataSource
        tableView.delegate = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            uploadImageController.showPhotoLibraryPickerInViewController(self)
        case 1:
            uploadImageController.showCameraCaptureInViewController(self)
        default:
            // illegal index
            assert(false)
        }
    }
    
    /*
    https://www.digipost.no/?s tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                        switch (buttonIndex) {
                            case 0:
                                self.uploadImageController = [[UploadImageController alloc] init];
                                [self.uploadImageController showPhotoLibraryPickerInViewController:self];
                                break;
                            case 1:
                                self.uploadImageController = [[UploadImageController alloc] init];
                                [self.uploadImageController showCameraCaptureInViewController:self];
                                break;
                            case 2 :
                                [self performSegueWithIdentifier:@"uploadGuideSegue" sender:self];
                                break;
                            default:
                                break;
                        }
                    }];
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
