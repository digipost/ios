//
//  DimView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 23.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class DimView: UIView {
    
    private var dimView: UIView!
    @IBInspectable var dimColor: UIColor!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func dim() {
        
        if dimView == nil {
            
            dimView = UIView(frame: UIScreen.mainScreen().bounds)
            dimView.backgroundColor = dimColor
            dimView.alpha = 0
            addSubview(dimView)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dimView.alpha = 0.5
            })
        } else {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dimView.alpha = 0
                }, completion: { (Bool) -> Void in
                    self.dimView.removeFromSuperview()
                    self.dimView = nil
            })
        }
    }

}
