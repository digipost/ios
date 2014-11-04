//
//  UploadImageController.swift
//  Digipost
//
//  Created by Håkon Bogen on 09.10.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

import Foundation
import CoreFoundation
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = setupPickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            viewController.presentViewController(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? NSString{
            if (CFStringCompare(mediaType , kUTTypeImage, .CompareCaseInsensitive) == CFComparisonResult.CompareEqualTo ){
                let mediaInfo = info[UIImagePickerControllerMediaMetadata] as NSDictionary?
                println(mediaInfo)
                let image = info[UIImagePickerControllerOriginalImage] as UIImage
                let appDelegate = UIApplication.sharedApplication().delegate as SHCAppDelegate
                let data = UIImageJPEGRepresentation(image as UIImage, 1.0)
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
                let documentsDir = paths.firstObject as NSString?
                if let documentsDirectory = documentsDir {
                    let localFilePath = documentsDirectory.stringByAppendingPathComponent("temp.JPG")
                    let couldCopy = data.writeToFile(localFilePath, atomically: true)
                    let localFileURL = NSURL(fileURLWithPath: localFilePath)
                    picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        
                    })
                    appDelegate.uploadImageWithURL(localFileURL)
                    return
                }
            }
        }
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        
        })
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
        imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
        imagePicker
        return imagePicker
    }
}