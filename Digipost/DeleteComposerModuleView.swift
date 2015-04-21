//
//  DeleteComposerModuleView.swift
//  Digipost
//
//  Created by Henrik Holmsen on 20.04.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit

class DeleteComposerModuleView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func addToView(view: UIView) {
        self.frame = CGRectMake(0, view.frame.height, view.frame.width, 88)
        view.addSubview(self)
    }

    func show() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.origin.y -= self.frame.height
            }) { (Bool) -> Void in
                
        }
    }
    
    func hide() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.origin.y += self.frame.height
            }) { (Bool) -> Void in
                self.removeFromSuperview()
        }
    }
}
