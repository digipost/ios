//
//  PreviewViewController.swift
//  Digipost
//
//  Created by Henrik Holmsen on 08.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var recipients = [Recipient]()
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
    
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
}
