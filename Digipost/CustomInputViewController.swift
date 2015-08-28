//
//  CustomInputViewController.swift
//  Digipost
//
//  Created by Håkon Bogen on 17/08/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class CustomInputViewController: UIInputViewController {

    var calculatorView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(r: 230, g: 231, b: 233, alpha: 1)
    }

        // load the nib file
//        var calculatorNib = UINib(nibName: "DeleteComposerModuleView", bundle: nil)
        // instantiate the view
//        calculatorView = calculatorNib.instantiateWithOwner(self, options: nil)[0] as! UIView

        // add the interface to the main view
//        view.addSubview(calculatorView)

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
