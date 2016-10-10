//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import CoreFoundation
import AssetsLibrary
import MobileCoreServices
import UIKit

protocol UploadImageProtocol {
    func didSelectImageToUpload(image:UIImage) -> UIImage
}

class UploadImageController: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func showCameraCaptureInViewController(viewController:UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = setupPickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            viewController.presentViewController(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    func showPhotoLibraryPickerInViewController(viewController:UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = setupPickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            viewController.presentViewController(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? NSString{
            if (CFStringCompare(mediaType , kUTTypeImage, .CompareCaseInsensitive) == CFComparisonResult.CompareEqualTo ){
                _ = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                
                var refURL = info[UIImagePickerControllerReferenceURL] as! NSURL?;
                if refURL == nil {
                    refURL = info[UIImagePickerControllerMediaURL] as! NSURL?;
                }
                if let actualMediaURL = refURL as NSURL! {
                    var fileName = "temp.jpg"
                    let assetLibrary = ALAssetsLibrary()
                    assetLibrary.assetForURL(actualMediaURL , resultBlock: { (asset: ALAsset!) -> Void in
                        if let actualAsset = asset as ALAsset? {
                            let assetRep: ALAssetRepresentation = actualAsset.defaultRepresentation()
                            fileName = assetRep.filename()
                            let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                            let image = UIImage(CGImage: iref)
                            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                            let documentsDir = paths.firstObject as! NSString?
                            if let documentsDirectory = documentsDir {
                                let localFilePath = documentsDirectory.stringByAppendingPathComponent(fileName)
                                let data = UIImageJPEGRepresentation(image, 1.0)
                                _ = data!.writeToFile(localFilePath, atomically: true)
                                let localFileURL = NSURL(fileURLWithPath: localFilePath)
                                let appDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
                                picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    appDelegate.uploadImageWithURL(localFileURL)
                                    UIApplication.sharedApplication().statusBarStyle = .LightContent
                                })
                            }
                        }
                        }, failureBlock: { (error) -> Void in
                            
                    })
                } else {
                    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                    let documentsDir = paths.firstObject as! NSString?
                    if let documentsDirectory = documentsDir {
                        let localFilePath = documentsDirectory.stringByAppendingPathComponent(NSDate().prettyStringWithJPGExtension())
                        let data = UIImageJPEGRepresentation(image, 1.0)
                        _ = data!.writeToFile(localFilePath, atomically: true)
                        let localFileURL = NSURL(fileURLWithPath: localFilePath)
                        let appDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
                        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                            appDelegate.uploadImageWithURL(localFileURL)
                            UIApplication.sharedApplication().statusBarStyle = .LightContent
                        })
                    }
                }
            } else {
                let movieURL = info[UIImagePickerControllerMediaURL] as! NSURL
                _ = movieURL.path
                _ = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                let documentsDir = paths.firstObject as! NSString?
                var name = movieURL.path?.componentsSeparatedByString("/").last as String!
                name = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                if let documentsDirectory = documentsDir {
                    let localFilePath = documentsDirectory.stringByAppendingPathComponent(NSDate().prettyStringWithMOVExtension())
                    let data = NSData(contentsOfURL: movieURL)!
                    _ = data.writeToFile(localFilePath, atomically: true)
                    let localFileURL = NSURL(fileURLWithPath: localFilePath)
                    let appDelegate = UIApplication.sharedApplication().delegate as! SHCAppDelegate
                    picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        appDelegate.uploadImageWithURL(localFileURL)
                        UIApplication.sharedApplication().statusBarStyle = .LightContent
                    })
                }
            }
        }
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        return orientation
    }
    
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    private func setupPickerController() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.translucent = false
        imagePicker.delegate = self
        imagePicker.mediaTypes = NSArray(objects:kUTTypeImage,kUTTypeVideo,kUTTypeMovie) as! [String]
        return imagePicker
    }
}