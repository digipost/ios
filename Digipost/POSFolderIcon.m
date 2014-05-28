//
//  POSFolderIcon.m
//  Digipost
//
//  Created by Håkon Bogen on 28.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSFolderIcon.h"

@implementation POSFolderIcon

+ (POSFolderIcon *)folderIconWithName:(NSString *)name
{
    POSFolderIcon *icon = [[POSFolderIcon alloc] init];
    icon.name = [name uppercaseString];
    return icon;
    //    [items addObject:@"Archive_128"];
    //    [items addObject:@"Camera_128"];
    //    [items addObject:@"Envelope_128"];
    //    [items addObject:@"File_128"];
    //    [items addObject:@"Folder_128"];
    //    [items addObject:@"Heart_128"];
    //    [items addObject:@"Tags_128"];
    //    [items addObject:@"Home_128"];
    //    [items addObject:@"Star_128"];
    //    [items addObject:@"Suitcase_128"];
    //    [items addObject:@"Trophy_128"];
    //    [items addObject:@"USD_128"];
}
- (NSString *)upperCaseFirstLetterName
{

    NSString *lowercaseName = [_name lowercaseString];
    return [lowercaseName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                  withString:[[lowercaseName substringToIndex:1] uppercaseString]];
}
- (UIImage *)bigImage
{
    if (_bigImage == nil) {
        _bigImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self upperCaseFirstLetterName]]];
    }
    return _bigImage;
}

- (UIImage *)bigSelectedImage
{
    if (_bigSelectedImage == nil) {
        _bigSelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active", [self upperCaseFirstLetterName]]];
    }
    return _bigSelectedImage;
}
- (UIImage *)smallImage
{
    if (_smallImage == nil) {
        _smallImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_32", [self upperCaseFirstLetterName]]];
    }
    return _smallImage;
}
@end
