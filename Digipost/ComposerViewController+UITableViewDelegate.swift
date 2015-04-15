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
        let module = self.tableViewDataSource.composerModule(atIndexPath: indexPath)
        if let textModule = module as? TextComposerModule {
            return height(textComposerModule: textModule)
        }
        return 44
    }

    func height(#textComposerModule: TextComposerModule) -> CGFloat {
        let textView = UITextView()
        textView.text = textComposerModule.text
        textView.font = textComposerModule.font
        textView.frame.size.width = self.tableView.frame.size.width - 40 // TODO: use the actual margin!
        let size = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, 1000))
        let calculatedHeight = size.height + ComposerViewControllerDelegateConstants.textViewMarginBottom
        return max(calculatedHeight, ComposerViewControllerDelegateConstants.minimumCellSize)
    }
}
