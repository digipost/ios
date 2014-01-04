//
//  SHCNetworkClient.h
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>

// Custom NSError code enum
typedef NS_ENUM(NSUInteger, SHCAPIManagerErrorCode) {
    SHCAPIManagerErrorCodeUnauthorized = 1
};

// Custom NSError consts
extern NSString *const kAPIManagerErrorDomain;

@class SHCFolder;
@class SHCAttachment;

@interface SHCAPIManager : NSObject

+ (instancetype)sharedManager;

- (void)startLogging;
- (void)stopLogging;
- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingRootResource;
- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingDocuments;
- (void)downloadAttachment:(SHCAttachment *)attachment withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelDownloadingAttachments;
- (BOOL)responseCodeIsIn400Range:(NSURLResponse *)response;

@end
