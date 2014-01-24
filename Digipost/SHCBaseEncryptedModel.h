//
//  SHCBaseEncryptedModel.h
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString *const kBaseEncryptionModelEntityName;

@interface SHCBaseEncryptedModel : NSManagedObject

@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *fileType;

- (NSString *)encryptedFilePath;
- (NSString *)decryptedFilePath;

@end
