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
