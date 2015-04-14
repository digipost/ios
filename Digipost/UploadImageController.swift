//
//  UploadImageController.swift
//  Digipost
//
//  Created by Håkon Bogen on 09.10.14.
//  Copyright (c) 2014 Posten. All rights reserved.
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? NSString{
            if (CFStringCompare(mediaType , kUTTypeImage, .CompareCaseInsensitive) == CFComparisonResult.CompareEqualTo ){
                let mediaInfo = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                
                var refURL = info[UIImagePickerControllerReferenceURL] as! NSURL?;
                if refURL == nil {
                    refURL = info[UIImagePickerControllerMediaURL] as! NSURL?;
                }
                if let actualMediaURL = refURL as NSURL! {
                    var fileName = "temp.jpg"
                    let assetLibrary = ALAssetsLibrary()
                    assetLibrary.assetForURL(actualMediaURL , resultBlock: { (asset: ALAsset!) -> Void in
                        if let actualAsset = asset as ALAsset? {
                            var assetRep: ALAssetRepresentation = actualAsset.defaultRepresentation()
                            fileName = assetRep.filename()
                            var iref = assetRep.fullResolutionImage().takeUnretainedValue()
                            var image = UIImage(CGImage: iref)
                            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                            let documentsDir = paths.firstObject as! NSString?
                            if let documentsDirectory = documentsDir {
                                let localFilePath = documentsDirectory.stringByAppendingPathComponent(fileName)
                                let data = UIImageJPEGRepresentation(image, 1.0)
                                let couldCopy = data.writeToFile(localFilePath, atomically: true)
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
                        let couldCopy = data.writeToFile(localFilePath, atomically: true)
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
                let moviePath = movieURL.path
                let mediaInfo = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                let documentsDir = paths.firstObject as! NSString?
                var name = movieURL.path?.componentsSeparatedByString("/").last as String!
                name = name.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
                if let documentsDirectory = documentsDir {
                    let localFilePath = documentsDirectory.stringByAppendingPathComponent(NSDate().prettyStringWithMOVExtension())
                    let data = NSData(contentsOfURL: movieURL)!
                    let couldCopy = data.writeToFile(localFilePath, atomically: true)
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
        //        let orientation = UIApplication.sharedApplication().statusBarOrientation
        return UIInterfaceOrientation.LandscapeLeft
    }
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue
    }
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    private func setupPickerController() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.translucent = false
        imagePicker.delegate = self
        imagePicker.mediaTypes = NSArray(objects:kUTTypeImage,kUTTypeVideo,kUTTypeMovie) as [AnyObject]
        return imagePicker
    }
}