//
//  POSFolderIcon.h
//  Digipost
//
//  Created by Håkon Bogen on 28.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POSFolderIcon : NSObject

+ (POSFolderIcon *)folderIconWithName:(NSString *)name;

@property (strong, nonatomic) UIImage *bigImage;
@property (strong, nonatomic) UIImage *bigSelectedImage;
@property (strong, nonatomic) UIImage *smallImage;
@property (strong, nonatomic) NSString *name;

@end
