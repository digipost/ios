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
    SHCAPIManagerErrorCodeUnauthorized = 1,
    SHCAPIManagerErrorCodeUploadFileDoesNotExist,
    SHCAPIManagerErrorCodeUploadFileTooBig,
    SHCAPIManagerErrorCodeUploadLinkNotFoundInRootResource,
    SHCAPIManagerErrorCodeUploadFailed
};

// Custom NSError consts
extern NSString *const kAPIManagerErrorDomain;

// Notification names
extern NSString *const kAPIManagerUploadProgressStartedNotificationName;
extern NSString *const kAPIManagerUploadProgressChangedNotificationName;
extern NSString *const kAPIManagerUploadProgressFinishedNotificationName;

@class SHCFolder;
@class SHCBaseEncryptedModel;
@class SHCDocument;
@class SHCInvoice;
@class SHCReceipt;

@interface SHCAPIManager : NSObject

@property (assign, nonatomic, getter = isUpdatingRootResource) BOOL updatingRootResource;
@property (assign, nonatomic, getter = isUpdatingBankAccount) BOOL updatingBankAccount;
@property (assign, nonatomic, getter = isUpdatingDocuments) BOOL updatingDocuments;
@property (assign, nonatomic, getter = isUpdatingReceipts) BOOL updatingReceipts;
@property (assign, nonatomic, getter = isDownloadingBaseEncryptionModel) BOOL downloadingBaseEncryptionModel;
@property (assign, nonatomic, getter = isUploadingFile) BOOL uploadingFile;
@property (strong, nonatomic) NSProgress *uploadProgress;

+ (instancetype)sharedManager;

- (void)startLogging;
- (void)stopLogging;
- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingRootResource;
- (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingBankAccount;
- (void)sendInvoiceToBank:(SHCInvoice *)invoice withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)updateDocumentsInFolderWithName:(NSString *)folderName folderUri:(NSString *)folderUri success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingDocuments;
- (void)downloadBaseEncryptionModel:(SHCBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)moveDocument:(SHCDocument *)document toLocation:(NSString *)location withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)deleteDocument:(SHCDocument *)document withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)logoutWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelDownloadingBaseEncryptionModels;
- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress uri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUpdatingReceipts;
- (void)deleteReceipt:(SHCReceipt *)receipt withSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)uploadFileWithURL:(NSURL *)fileURL success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelUploadingFiles;
- (BOOL)responseCodeIsUnauthorized:(NSURLResponse *)response;
- (BOOL)responseCodeForOAuthIsUnauthorized:(NSURLResponse *)response;

@end
