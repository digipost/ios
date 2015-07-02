//
//  APIClient+Recipients.swift
//  Digipost
//
//  Created by Hannes Waller on 2015-04-08.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import Foundation

extension APIClient {

    func getRecipients(searchString: String, success: (Dictionary<String,AnyObject>) -> Void , failure: (error: APIError) -> ()) {
        let encodedSearchString:String =  searchString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let safeString = encodedSearchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let searchUri = POSRootResource.existingRootResourceInManagedObjectContext(POSModelManager.sharedManager().managedObjectContext).searchUri
        let urlString = "\(searchUri)?recipientId=\(safeString!)"
        let task = urlSessionJSONTask(url: urlString, success: success) { (error) -> () in
            if error.code == Constants.Error.Code.oAuthUnathorized {
                self.getRecipients(urlString, success: success, failure: failure)
            } else {
                failure(error: error)
            }
        }
//        validateTokensThenPerformTask(task!)
    }


}