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
@class SHCDocument;
@class SHCInvoice;

@interface SHCAPIManager : NSObject

@property (assign, nonatomic, getter = isUpdatingRootResource) BOOL updatingRootResource;
@property (assign, nonatomic, getter = isUpdatingDocuments) BOOL updatingDocuments;

+ (instancetype)sharedManager;

- (void)startLogging;
- (void)stopLogging;
- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingRootResource;
- (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingBankAccount;
- (void)sendInvoiceToBank:(SHCInvoice *)invoice success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingDocuments;
- (void)downloadAttachment:(SHCAttachment *)attachment withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)moveDocument:(SHCDocument *)document toLocation:(NSString *)location success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)deleteDocument:(SHCDocument *)document success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)logoutWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelDownloadingAttachments;
- (BOOL)responseCodeIsUnauthorized:(NSURLResponse *)response;
- (BOOL)responseCodeForOAuthIsUnauthorized:(NSURLResponse *)response;

@end
