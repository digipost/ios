//
//  FontPickerViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 04/05/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class FontPickerViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView : UITableView!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Did select font!
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
