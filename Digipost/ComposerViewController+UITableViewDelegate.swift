//
//  ComposerViewController+TableViewDelegate.swift
//  Digipost
//
//  Created by Håkon Bogen on 10/04/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit


struct ComposerViewControllerDelegateConstants {
    static let textViewMarginTop : CGFloat = 5
    static let textViewMarginBottom : CGFloat = 5

    static let minimumCellSize : CGFloat = 44

}

extension ComposerViewController {

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.editing == true {
            return 88
        } else {
            let module = composerModule(atIndexPath: indexPath)
            if let textModule = module as? TextComposerModule {
                return height(textComposerModule: textModule)
            }
            if let imageModule = module as? ImageComposerModule {
                return self.view.frame.width
            }
            
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }

    func height(#textComposerModule: TextComposerModule) -> CGFloat {
        let textView = UITextView()
        textView.text = textComposerModule.text
        textView.font = textComposerModule.textAttribute.font!
        textView.frame.size.width = self.tableView.frame.size.width - 40 // TODO: use the actual margin!
        let size = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, 1000))
        let calculatedHeight = size.height + ComposerViewControllerDelegateConstants.textViewMarginBottom
        return max(calculatedHeight, ComposerViewControllerDelegateConstants.minimumCellSize)
    }
}
