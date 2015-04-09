//
//  UIScrollViewExtensions.swift
//  Digipost
//
//  Created by Henrik Holmsen on 13.02.15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension UIScrollView{
    
    var totalPageProgressInPercentage:CGFloat {
        get {
            let maxHorizontalOffset = self.contentSize.width - pageSize.width
            let currentHorizontalOffset = self.contentOffset.x
            return currentHorizontalOffset / maxHorizontalOffset
        }
    }
    
    var pageProgressInPercentage:CGFloat {
        get { return self.contentOffset.x / pageSize.width }
    }
    
    var pageSize:CGSize {
        get { return self.frame.size }
    }
    
    var currentPage:Int {
        get { return Int(floor((self.contentOffset.x * 2.0 + self.frame.width) / (self.frame.width * 2.0)))}
    }
    
    var scrollableEdgeOffset:CGFloat {
        get { return self.frame.width / 3}
    }
}
