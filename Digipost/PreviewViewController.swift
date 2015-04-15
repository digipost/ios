//
//  PreviewViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var modules: [ComposerModule] = [ComposerModule](){
        
        didSet{
            println("........................................")
            println("           Composer Contents:          ")
            println("........................................")
            
            for (index,module) in enumerate(modules) {
                
                switch module.type{
                    
                case .TextModule:
                    let textModule = module as? ComposerTextModule
                    let text = textModule?.text
                    println("TextModule: \(text!)")
                case .ImageModule:
                    let imageModule = module as? ComposerImageModule
                    println("ImageModule")
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
