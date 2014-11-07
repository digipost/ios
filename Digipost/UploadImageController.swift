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
                let mediaInfo = info[UIImagePickerControllerMediaMetadata] as NSDictionary?
                
                var refURL = info[UIImagePickerControllerReferenceURL] as NSURL?;
                if refURL == nil {
                    refURL = info[UIImagePickerControllerMediaURL] as NSURL?;
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
                            let documentsDir = paths.firstObject as NSString?
                            if let documentsDirectory = documentsDir {
                                let localFilePath = documentsDirectory.stringByAppendingPathComponent(fileName)
                                let data = UIImageJPEGRepresentation(image, 1.0)
                                let couldCopy = data.writeToFile(localFilePath, atomically: true)
                                let localFileURL = NSURL(fileURLWithPath: localFilePath)
                                let appDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
                                picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    appDelegate.uploadImageWithURL(localFileURL)
                                    
                                })
                            }
                        }
                        }, failureBlock: { (error) -> Void in
                            
                    })
                } else {
                    let image = info[UIImagePickerControllerOriginalImage] as UIImage
                    println(image)
                    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                    let documentsDir = paths.firstObject as NSString?
                    if let documentsDirectory = documentsDir {
                        let localFilePath = documentsDirectory.stringByAppendingPathComponent(NSDate().prettyStringWithJPGExtension())
                        let data = UIImageJPEGRepresentation(image, 1.0)
                        let couldCopy = data.writeToFile(localFilePath, atomically: true)
                        let localFileURL = NSURL(fileURLWithPath: localFilePath)
                        let appDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
                        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                            appDelegate.uploadImageWithURL(localFileURL)
                        })
                    }
                }
            }else {
                // movie
                
                //            /    if (CFStringCompare ((CFStringRef) me//diaType, kUTTypeMovie, 0)
                //            == kCFCompareEqualTo) {
                //
                //                NSString *moviePath = [[info objectForKey:
                //                    UIImagePickerControllerMediaURL] path];
            }
        }
        //  picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        
        // })
        //            editedImage = (UIImage *) [info objectForKey:
        
        
        //        [picker dismissModalViewControllerAnimated:YES];
        //        imageView.image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //        NSData *webData = UIImagePNGRepresentation(imageView.image);
        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //        NSString *documentsDirectory = [paths objectAtIndex:0];
        //        NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:png];
        //        [webData writeToFile:localFilePath atomically:YES];
        //        NSLog(@"localFilePath.%@",localFilePath);
        
        
        
        
        
        
        //
        //            println(imagePathURL.absoluteURL)
        //            println(imagePathURL.relativePath)
        //            println(imagePathURL.standardizedURL)
        //
        //            println(imagePathURL.path)
        
        //            NSString *moviePath = [[info objectForKey:
        //                UIImagePickerControllerMediaURL] path];
        //                    UIImagePickerControllerEditedImage];
        //                originalImage = (UIImage *) [info objectForKey:
        //                    UIImagePickerControllerOriginalImage];
        //
        //                if (editedImage) {
        //                    imageToUse = editedImage;
        //                } else {
        //                    imageToUse = originalImage;
        //                }
        //                // Do something with image
        //        }
        //        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        //        UIImage *originalImage, *editedImage, *imageToUse;
        //
        //        // Handle a still image picked from a photo album
        //        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        //            == kCFCompareEqualTo) {
        //
        //                editedImage = (UIImage *) [info objectForKey:
        //                    UIImagePickerControllerEditedImage];
        //                originalImage = (UIImage *) [info objectForKey:
        //                    UIImagePickerControllerOriginalImage];
        //
        //                if (editedImage) {
        //                    imageToUse = editedImage;
        //                } else {
        //                    imageToUse = originalImage;
        //                }
        //                // Do something with imageToUse
        //        }
        //
        //        // Handle a movied picked from a photo album
        //        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        //            == kCFCompareEqualTo) {
        //
        //                NSString *moviePath = [[info objectForKey:
        //                    UIImagePickerControllerMediaURL] path];
        //
        //                // Do something with the picked movie available at moviePath
        //        }
        
        
        
        
        
        
    }
    
    private func setupPickerController() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = NSArray(objects:kUTTypeImage,kUTTypeVideo)
        return imagePicker
    }
}