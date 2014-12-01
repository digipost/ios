//
// Copyright (C) Posten Norge AS
//
//
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <objc/runtime.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import "POSAPIManager.h"
#import "POSAPIManager+PrivateMethods.h"
#import "POSMailbox.h"
#import "POSOAuthManager.h"
#import "POSModelManager.h"
#import "POSFolder.h"
#import "POSDocument.h"
#import "SHCLoginViewController.h"
#import "NSError+ExtraInfo.h"
#import "POSAttachment.h"
#import "POSFileManager.h"
#import "NSString+SHA1String.h"
#import "POSRootResource.h"
#import "POSInvoice.h"
#import "POSReceipt.h"
#import "POSDocument+Methods.h"
#import "Digipost-swift.h"

static void *kSHCAPIManagerStateContext = &kSHCAPIManagerStateContext;
static void *kSHCAPIManagerRequestWasSuspended = &kSHCAPIManagerRequestWasSuspended;
static void *kSHCAPIManagerKVOContext = &kSHCAPIManagerKVOContext;

// Custom NSError consts
NSString *const kAPIManagerErrorDomain = @"APIManagerErrorDomain";

// Notification names
NSString *const kAPIManagerUploadProgressStartedNotificationName = @"UploadProgressStartedNotification";
NSString *const kAPIManagerUploadProgressChangedNotificationName = @"UploadProgressChangedNotification";
NSString *const kAPIManagerUploadProgressFinishedNotificationName = @"UploadProgressFinishedNotification";

@interface POSAPIManager ()

@property (assign, nonatomic) SHCAPIManagerState state;
@property (copy, nonatomic) void (^lastSuccessBlock)(void);
@property (copy, nonatomic) void (^lastSuccessBlockWithAttachmentAttributes)(NSDictionary *);
@property (copy, nonatomic) void (^lastFailureBlock)(NSError *);
@property (strong, nonatomic) NSURLResponse *lastURLResponse;
@property (strong, nonatomic) id lastResponseObject;
@property (copy, nonatomic) NSString *lastFolderName;
@property (copy, nonatomic) NSString *lastMailboxDigipostAddress;
@property (copy, nonatomic) NSString *lastFolderUri;
@property (strong, nonatomic) NSError *lastError;
@property (strong, nonatomic) POSDocument *lastDocument;
@property (strong, nonatomic) POSReceipt *lastReceipt;
@property (strong, nonatomic) AFHTTPSessionManager *fileTransferSessionManager;
@property (copy, nonatomic) NSString *lastBankAccountUri;
@property (copy, nonatomic) NSString *lastReceiptsUri;
@property (strong, nonatomic) NSURLSessionDataTask *uploadTask;
@property (copy, nonatomic) NSString *lastOAuth2Scope;

@end

@implementation POSAPIManager

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {

        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

        _state = SHCAPIManagerStateIdle;

        [self addObserver:self
               forKeyPath:NSStringFromSelector(@selector(state))
                  options:NSKeyValueObservingOptionNew
                  context:kSHCAPIManagerStateContext];

        NSURL *baseURL = [NSURL URLWithString:__SERVER_URI__];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;

        NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];

        // Default session manager
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                   sessionConfiguration:configuration];

        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:contentType
                                 forHTTPHeaderField:@"Accept"];

        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *acceptableContentTypesMutable = [NSMutableSet setWithSet:_sessionManager.responseSerializer.acceptableContentTypes];
        [acceptableContentTypesMutable addObject:contentType];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:acceptableContentTypesMutable];

        // File transfer session manager
        _fileTransferSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL
                                                               sessionConfiguration:configuration];
        _fileTransferSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _fileTransferSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

#if (__ACCEPT_SELF_SIGNED_CERTIFICATES__)

        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _fileTransferSessionManager.securityPolicy.allowInvalidCertificates = YES;

#endif
    }

    return self;
}

- (void)dealloc
{
    [self stopLogging];

    @try {
        [self removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(state))
                     context:kSHCAPIManagerStateContext];
    }
    @catch (NSException *exception)
    {
        DDLogWarn(@"Caught an exception: %@", exception);
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kSHCAPIManagerStateContext && [keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        SHCAPIManagerState state = [change[@"new"] integerValue];

        NSString *stateString = nil;
        switch (state) {
            case SHCAPIManagerStateIdle:
                stateString = @"SHCAPIManagerStateIdle";
                break;
            case SHCAPIManagerStateValidatingAccessToken:
                stateString = @"SHCAPIManagerStateValidatingAccessToken";
                break;
            case SHCAPIManagerStateValidatingAccessTokenFinished:
                stateString = @"SHCAPIManagerStateValidatingAccessTokenFinished";
                break;
            case SHCAPIManagerStateRefreshingAccessToken:
                stateString = @"SHCAPIManagerStateRefreshingAccessToken";
                break;
            case SHCAPIManagerStateRefreshingAccessTokenFinished:
                stateString = @"SHCAPIManagerStateRefreshingAccessTokenFinished";
                break;
            case SHCAPIManagerStateRefreshingAccessTokenFailed:
                stateString = @"SHCAPIManagerStateRefreshingAccessTokenFailed";
                break;
            case SHCAPIManagerStateUpdatingRootResource:
                stateString = @"SHCAPIManagerStateUpdatingRootResource";
                break;
            case SHCAPIManagerStateUpdatingRootResourceFinished:
                stateString = @"SHCAPIManagerStateUpdatingRootResourceFinished";
                break;
            case SHCAPIManagerStateUpdatingRootResourceFailed:
                stateString = @"SHCAPIManagerStateUpdatingRootResourceFailed";
                break;
            case SHCAPIManagerStateUpdatingDocuments:
                stateString = @"SHCAPIManagerStateUpdatingDocuments";
                break;
            case SHCAPIManagerStateUpdatingDocumentsFinished:
                stateString = @"SHCAPIManagerStateUpdatingDocumentsFinished";
                break;
            case SHCAPIManagerStateUpdatingDocumentsFailed:
                stateString = @"SHCAPIManagerStateUpdatingDocumentsFailed";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModel:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModel";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFinished:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModelFinished";
                break;
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFailed:
                stateString = @"SHCAPIManagerStateDownloadingBaseEncryptionModelFailed";
                break;
            case SHCAPIManagerStateMovingDocument:
                stateString = @"SHCAPIManagerStateMovingDocument";
                break;
            case SHCAPIManagerStateMovingDocumentFinished:
                stateString = @"SHCAPIManagerStateMovingDocumentFinished";
                break;
            case SHCAPIManagerStateMovingDocumentFailed:
                stateString = @"SHCAPIManagerStateMovingDocumentFailed";
                break;
            case SHCAPIManagerStateDeletingDocument:
                stateString = @"SHCAPIManagerStateDeletingDocument";
                break;
            case SHCAPIManagerStateDeletingDocumentFinished:
                stateString = @"SHCAPIManagerStateDeletingDocumentFinished";
                break;
            case SHCAPIManagerStateDeletingDocumentFailed:
                stateString = @"SHCAPIManagerStateDeletingDocumentFailed";
                break;
            case SHCAPIManagerStateDeletingReceipt:
                stateString = @"SHCAPIManagerStateDeletingReceipt";
                break;
            case SHCAPIManagerStateDeletingReceiptFinished:
                stateString = @"SHCAPIManagerStateDeletingReceiptFinished";
                break;
            case SHCAPIManagerStateDeletingReceiptFailed:
                stateString = @"SHCAPIManagerStateDeletingReceiptFailed";
                break;
            case SHCAPIManagerStateUpdatingBankAccount:
                stateString = @"SHCAPIManagerStateUpdatingBankAccount";
                break;
            case SHCAPIManagerStateUpdatingBankAccountFinished:
                stateString = @"SHCAPIManagerStateUpdatingBankAccountFinished";
                break;
            case SHCAPIManagerStateUpdatingBankAccountFailed:
                stateString = @"SHCAPIManagerStateUpdatingBankAccountFailed";
                break;
            case SHCAPIManagerStateSendingInvoiceToBank:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBank";
                break;
            case SHCAPIManagerStateSendingInvoiceToBankFinished:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBankFinished";
                break;
            case SHCAPIManagerStateSendingInvoiceToBankFailed:
                stateString = @"SHCAPIManagerStateSendingInvoiceToBankFailed";
                break;
            case SHCAPIManagerStateUpdatingReceipts:
                stateString = @"SHCAPIManagerStateUpdatingReceipts";
                break;
            case SHCAPIManagerStateUpdatingReceiptsFinished:
                stateString = @"SHCAPIManagerStateUpdatingReceiptsFinished";
                break;
            case SHCAPIManagerStateUpdatingReceiptsFailed:
                stateString = @"SHCAPIManagerStateUpdatingReceiptsFailed";
                break;
            case SHCAPIManagerStateUploadingFile:
                stateString = @"SHCAPIManagerStateUploadingFile";
                break;
            case SHCAPIManagerStateUploadingFileFinished:
                stateString = @"SHCAPIManagerStateUploadingFileFinished";
                break;
            case SHCAPIManagerStateUploadingFileFailed:
                stateString = @"SHCAPIManagerStateUploadingFileFailed";
                break;
            case SHCAPIManagerStateLoggingOut:
                stateString = @"SHCAPIManagerStateLoggingOut";
                break;
            case SHCAPIManagerStateLoggingOutFailed:
                stateString = @"SHCAPIManagerStateLoggingOutFailed";
                break;
            case SHCAPIManagerStateLoggingOutFinished:
                stateString = @"SHCAPIManagerStateLoggingOutFinished";
                break;
            case SHCAPIManagerStateChangingFolderFinished:
                stateString = @"SHCAPIManagerStateChangingFolderFinished";
                break;
            case SHCAPIManagerStateChangingFolderFailed:
                stateString = @"SHCAPIManagerStateChangingFolderFailed";
                break;
            case SHCAPIManagerStateChangingFolder:
                stateString = @"SHCAPIManagerStateChangingFolder";
                break;
            case SHCAPIManagerStateDeletingFolderFinished:
                stateString = @"SHCAPIManagerStateDeletingFolderFinished";
                break;
            case SHCAPIManagerStateDeletingFolderFailed:
                stateString = @"SHCAPIManagerStateDeletingFolderFailed";
                break;
            case SHCAPIManagerStateDeletingFolder:
                stateString = @"SHCAPIManagerStateDeletingFolder";
                break;
            case SHCAPIManagerStateCreatingFolder:
                stateString = @"SHCAPIManagerStateCreatingFolder";
                break;
            case SHCAPIManagerStateCreatingFolderFinished:
                stateString = @"SHCAPIManagerStateCreatingFolderFinished";
                break;
            case SHCAPIManagerStateUpdatingFolder:
                stateString = @"SHCAPIManagerStateUpdatingFolder";
                break;
            case SHCAPIManagerStateUpdatingFolderFailed:
                stateString = @"SHCAPIManagerStateUpdatingFolderFailed";
                break;
            case SHCAPIManagerStateUpdatingFolderFinished:
                stateString = @"SHCAPIManagerStateUpdatingFolderFinished";
                break;
            case SHCAPIManagerStateMovingFolders:
                stateString = @"SHCAPIManagerStateMovingFolders";
                break;
            case SHCAPIManagerStateMovingFoldersFailed:
                stateString = @"SHCAPIManagerStateMovingFoldersFailed";
                break;
            case SHCAPIManagerStateMovingFoldersFinished:
                stateString = @"SHCAPIManagerStateMovingFoldersFinished";
                break;

            default:
                stateString = @"default";
                break;
        }

        DDLogInfo(@"state: %@", stateString);

        switch (state) {
            case SHCAPIManagerStateValidatingAccessTokenFinished:
            case SHCAPIManagerStateRefreshingAccessTokenFinished: {

                if (self.lastSuccessBlock) {
                    [self updateAuthorizationHeaderForScope:self.lastOAuth2Scope];
                    self.lastSuccessBlock();
                }

                break;
            }
            case SHCAPIManagerStateRefreshingAccessTokenFailed: {
                // Check to see if the request failed because the refresh token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse] ||
                    ([self.lastError.domain isEqualToString:kOAuth2ErrorDomain] &&
                     self.lastError.code == SHCOAuthErrorCodeInvalidRefreshTokenResponse && [self.lastOAuth2Scope isEqualToString:kOauth2ScopeFull])) {
                    // The refresh token was rejected, most likely because the user invalidated
                    // the session in the www.digipost.no web settings interface.

                    [OAuthToken removeAllTokens];
                    self.lastError.errorTitle = NSLocalizedString(@"GENERIC_REFRESH_TOKEN_INVALID_TITLE", @"Refresh token invalid title");
                    self.lastError.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];
                        
                        [OAuthToken removeAllTokens];
                            [[POSModelManager sharedManager] deleteAllObjects];
                    };

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingRootResourceFinished: {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingRootResource) {
                        [[POSModelManager sharedManager] updateRootResourceWithAttributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingRootResource = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingRootResourceFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingRootResource = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFinished: {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingDocuments) {
                        [[POSModelManager sharedManager] updateDocumentsInFolderWithName:self.lastFolderName
                                                                  mailboxDigipostAddress:self.lastMailboxDigipostAddress
                                                                              attributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingDocuments = NO;

                break;
            }
            case SHCAPIManagerStateUpdatingDocumentsFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingDocuments = NO;

                break;
            }
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                self.downloadingBaseEncryptionModel = NO;

                break;
            }
            case SHCAPIManagerStateDownloadingBaseEncryptionModelFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.downloadingBaseEncryptionModel = NO;

                break;
            }
            case SHCAPIManagerStateMovingDocumentFinished: {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {
                    //                    [[POSModelManager sharedManager] updateDocument:self.lastDocument
                    //                                                     withAttributes:responseDict];

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateMovingDocumentFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingDocumentFinished: {
                [[POSModelManager sharedManager] deleteDocument:self.lastDocument];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingDocumentFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingReceiptFinished: {
                [[POSModelManager sharedManager] deleteReceipt:self.lastReceipt];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateDeletingReceiptFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdatingBankAccountFinished: {
                NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
                if ([responseDict isKindOfClass:[NSDictionary class]]) {

                    // If the update has been canceled after the network request finished,
                    // but before we have updated the data model, we need to cancel that as well.
                    if (self.updatingBankAccount) {
                        [[POSModelManager sharedManager] updateBankAccountWithAttributes:responseDict];
                    }

                    if (self.lastSuccessBlock) {
                        self.lastSuccessBlock();
                    }
                }

                [self cleanup];

                self.updatingBankAccount = NO;
                self.lastBankAccountUri = nil;

                break;
            }
            case SHCAPIManagerStateUpdatingBankAccountFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingBankAccount = NO;
                self.lastBankAccountUri = nil;

                break;
            }
            case SHCAPIManagerStateSendingInvoiceToBankFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateSendingInvoiceToBankFailed: {
                [self stateSendingInvoiceToBankFailed];
                break;
            }
            case SHCAPIManagerStateUpdatingReceiptsFinished: {
                [self stateUpdatingReceiptsFinished];
                break;
            }
            case SHCAPIManagerStateUpdatingReceiptsFailed: {
                //                [self updatingReceiptsFailed];
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.updatingReceipts = NO;
                self.lastReceiptsUri = nil;
                self.lastMailboxDigipostAddress = nil;

                break;
            }
            case SHCAPIManagerStateUploadingFileFinished: {
                [self.uploadProgress removeObserver:self
                                         forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                self.uploadingFile = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressFinishedNotificationName
                                                                    object:nil];

                break;
            }
            case SHCAPIManagerStateUploadingFileFailed: {
                [self.uploadProgress removeObserver:self
                                         forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];

                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                self.uploadingFile = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressFinishedNotificationName
                                                                    object:nil];

                break;
            }
            case SHCAPIManagerStateLoggingOutFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateLoggingOutFailed: {
                // Check to see if the request failed because the access token was rejected
                if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

                    // The access token was rejected - let's remove it...
                    [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                } else if (![self requestWasCanceledWithError:self.lastError]) {
                    if (self.lastFailureBlock) {
                        self.lastFailureBlock(self.lastError);
                    }
                }

                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUploadingFile: {
                self.uploadingFile = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressStartedNotificationName
                                                                    object:nil];
                break;
            }
            case SHCAPIManagerStateUpdatingRootResource: {
                self.updatingRootResource = YES;
                break;
            }
            case SHCAPIManagerStateUpdatingBankAccount: {
                self.updatingBankAccount = YES;
                break;
            }

            case SHCAPIManagerStateUpdatingDocuments: {
                self.updatingDocuments = YES;
                break;
            }

            case SHCAPIManagerStateDownloadingBaseEncryptionModel: {
                self.downloadingBaseEncryptionModel = YES;
                break;
            }

            case SHCAPIManagerStateUpdatingReceipts: {
                self.updatingReceipts = YES;
                break;
            }

            case SHCAPIManagerStateCreatingFolderFinished: {

                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];
                break;
            }
            case SHCAPIManagerStateCreatingFolderFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateChangingFolder: {
                break;
            }
            case SHCAPIManagerStateChangingFolderFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];
                break;
            }
            case SHCAPIManagerStateChangingFolderFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateDeletingFolder: {

                break;
            }
            case SHCAPIManagerStateDeletingFolderFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];
                break;
            }
            case SHCAPIManagerStateDeletingFolderFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateMovingFolders: {

                break;
            }
            case SHCAPIManagerStateMovingFoldersFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }

                [self cleanup];
                break;
            }
            case SHCAPIManagerStateMovingFoldersFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateValididatingOpeningReceipt: {
                break;
            }
            case SHCAPIManagerStateValididatingOpeningReceiptFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateValididatingOpeningReceiptFinished: {
                if (self.lastSuccessBlockWithAttachmentAttributes) {
                    self.lastSuccessBlockWithAttachmentAttributes(self.lastResponseObject);
                }
                [self cleanup];

                break;
            }
            case SHCAPIManagerStateUpdateSingleDocument:
                break;
            case SHCAPIManagerStateUpdateSingleDocumentFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateUpdateSingleDocumentFinished: {
                if (self.lastResponseObject) {
                    [[POSModelManager sharedManager] updateDocument:self.lastDocument
                                                     withAttributes:self.lastResponseObject];
                }
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }
                [self cleanup];
                break;
            }
            case SHCAPIManagerStateChangeDocumentName: {

                break;
            }
            case SHCAPIManagerStateChangeDocumentNameFinished: {
                if (self.lastSuccessBlock) {
                    self.lastSuccessBlock();
                }
                [self cleanup];
                break;
            }
            case SHCAPIManagerStateChangeDocumentNameFailed: {
                [self checkStateAndCallFailureBlock];
                break;
            }
            case SHCAPIManagerStateValidatingAccessToken:
            case SHCAPIManagerStateRefreshingAccessToken:
            case SHCAPIManagerStateMovingDocument:
            case SHCAPIManagerStateDeletingDocument:
            case SHCAPIManagerStateSendingInvoiceToBank:
            case SHCAPIManagerStateLoggingOut:
            case SHCAPIManagerStateIdle:
            default:
                break;
        }
    } else if (context == kSHCAPIManagerKVOContext && object == self.uploadProgress && [keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAPIManagerUploadProgressChangedNotificationName
                                                            object:[NSNumber numberWithDouble:self.uploadProgress.fractionCompleted]];
    } else if ([super respondsToSelector:@selector(observeValueForKeyPath:
                                                                 ofObject:
                                                                   change:
                                                                  context:)]) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)checkStateAndCallFailureBlock
{
    if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

        // The access token was rejected - let's remove it...
        [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

        if (self.lastFailureBlock) {
            self.lastFailureBlock(self.lastError);
        }
    } else if (![self requestWasCanceledWithError:self.lastError]) {
        if (self.lastFailureBlock) {
            self.lastFailureBlock(self.lastError);
        }
    }

    [self cleanup];
}

- (void)stateSendingInvoiceToBankFailed
{
    // Check to see if the request failed because the access token was rejected
    if ([self responseCodeIsUnauthorized:self.lastURLResponse]) {

        // The access token was rejected - let's remove it...
        [OAuthToken removeAcessTokenForOAuthTokenWithScope:self.lastOAuth2Scope];

        if (self.lastFailureBlock) {
            self.lastFailureBlock(self.lastError);
        }
    } else if (![self requestWasCanceledWithError:self.lastError]) {
        if (self.lastFailureBlock) {
            self.lastFailureBlock(self.lastError);
        }
    }

    [self cleanup];
}

- (void)stateUpdatingReceiptsFinished
{
    NSDictionary *responseDict = (NSDictionary *)self.lastResponseObject;
    if ([responseDict isKindOfClass:[NSDictionary class]]) {

        // If the update has been canceled after the network request finished,
        // but before we have updated the data model, we need to cancel that as well.
        if (self.updatingReceipts) {
            [[POSModelManager sharedManager] updateCardAttributes:responseDict];
            [[POSModelManager sharedManager] updateReceiptsInMailboxWithDigipostAddress:self.lastMailboxDigipostAddress
                                                                             attributes:responseDict];
        }

        if (self.lastSuccessBlock) {
            self.lastSuccessBlock();
        }
    }

    [self cleanup];

    self.updatingReceipts = NO;
    self.lastReceiptsUri = nil;
    self.lastMailboxDigipostAddress = nil;
}

#pragma mark - Public methods

+ (instancetype)sharedManager
{
    static POSAPIManager *sharedInstance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[POSAPIManager alloc] init];
    });

    return sharedInstance;
}

- (void)startLogging
{
    [self stopLogging];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidStart:)
                                                 name:AFNetworkingTaskDidResumeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidSuspend:)
                                                 name:AFNetworkingTaskDidSuspendNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkRequestDidFinish:)
                                                 name:AFNetworkingTaskDidCompleteNotification
                                               object:nil];
}

- (void)stopLogging
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateRootResourceWithSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingRootResource;

    [self validateTokensForScope:kOauth2ScopeFull success:^{
        [self.sessionManager GET:__ROOT_RESOURCE_URI__
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingRootResource = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingRootResource
{
    NSURL *URL = [NSURL URLWithString:__ROOT_RESOURCE_URI__];
    NSString *pathSuffix = [URL lastPathComponent];
    [self cancelRequestsWithPathSuffix:pathSuffix];

    self.state = SHCAPIManagerStateUpdatingRootResourceFailed;
}

- (void)updateBankAccountWithUri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingBankAccount;

    [self validateTokensForScope:kOauth2ScopeFull success:^{
        self.lastBankAccountUri = uri;
        [self.sessionManager GET:uri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingBankAccountFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingBankAccountFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingBankAccount = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingBankAccount
{
    if (self.lastBankAccountUri) {
        NSURL *URL = [NSURL URLWithString:self.lastBankAccountUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];

        self.lastBankAccountUri = nil;

        self.state = SHCAPIManagerStateUpdatingBankAccountFailed;
    }
}

- (void)sendInvoiceToBank:(POSInvoice *)invoice withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateSendingInvoiceToBank;

    [self validateTokensForScope:[OAuthToken oAuthScopeForAuthenticationLevel:invoice.attachment.authenticationLevel] success:^{
        
        [self.sessionManager POST:invoice.sendToBankUri
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              self.lastSuccessBlock = success;
                              self.state = SHCAPIManagerStateSendingInvoiceToBankFinished;
                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                              self.lastFailureBlock = failure;
                              self.lastURLResponse = task.response;
                              self.lastError = error;
                              self.state = SHCAPIManagerStateSendingInvoiceToBankFailed;
                          }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateDocumentsInFolderWithName:(NSString *)folderName mailboxDigipostAddress:(NSString *)digipostAddress folderUri:(NSString *)folderUri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(digipostAddress);
    NSParameterAssert(folderName);
    NSParameterAssert(folderUri);
    self.state = SHCAPIManagerStateUpdatingDocuments;
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        self.lastFolderUri = folderUri;
        [self.sessionManager GET:folderUri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.lastFolderName = folderName;
                             self.lastMailboxDigipostAddress = digipostAddress;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.lastOAuth2Scope = kOauth2ScopeFull;
                             self.state = SHCAPIManagerStateUpdatingDocumentsFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingDocuments = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingDocuments
{
    if (self.lastFolderUri) {
        NSURL *URL = [NSURL URLWithString:self.lastFolderUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];
        self.state = SHCAPIManagerStateUpdatingDocumentsFailed;
    }
}

- (void)downloadBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateDownloadingBaseEncryptionModel;

    POSAttachment *attachment = (id)baseEncryptionModel;

    NSString *highestScope;
    NSString *scope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
    __block BOOL didChoseAHigherScope = NO;
    if ([scope isEqualToString:kOauth2ScopeFull]) {
        highestScope = kOauth2ScopeFull;
    } else {
        highestScope = [OAuthToken highestScopeInStorageForScope:scope];
        if ([highestScope isEqualToString:scope] == NO) {
            didChoseAHigherScope = YES;
        }
    }

    [self validateAndDownloadBaseEncryptionModel:baseEncryptionModel withProgress:progress scope:highestScope didChooseHigherScope:didChoseAHigherScope success:success failure:failure];
}

- (void)validateAndDownloadBaseEncryptionModel:(POSBaseEncryptedModel *)baseEncryptionModel withProgress:(NSProgress *)progress scope:(NSString *)scope didChooseHigherScope:(BOOL)didChooseHigherScope success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    OAuthToken *oauthToken = [OAuthToken oAuthTokenWithScope:scope];

    if (oauthToken == nil && didChooseHigherScope) {
        POSAttachment *attachment = (id)baseEncryptionModel;
        NSString *scope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
        oauthToken = [OAuthToken oAuthTokenWithScope:scope];
    }
    if (oauthToken == nil) {
        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                             code:SHCAPIManagerErrorCodeNeedHigherAuthenticationLevel
                                         userInfo:nil];
        self.lastError = error;
        self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFailed;
        if (failure) {
            failure(error);
        }
        return;
    }
    NSString *baseEncryptionModelUri = baseEncryptionModel.uri;
    [self validateTokensForScope:scope success:^{

        NSMutableURLRequest *urlRequest = [self.fileTransferSessionManager.requestSerializer requestWithMethod:@"GET" URLString:baseEncryptionModelUri parameters:nil error:nil];

        // Let's set the correct mime type for this file download.
        [urlRequest setValue:[self mimeTypeForFileType:baseEncryptionModel.fileType] forHTTPHeaderField:@"Accept"];
        [self.fileTransferSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            progress.completedUnitCount = totalBytesWritten;
        }];

        BOOL baseEncryptionModelIsAttachment = [baseEncryptionModel isKindOfClass:[POSAttachment class]];

        NSURLSessionDownloadTask *task = [self.fileTransferSessionManager downloadTaskWithRequest:urlRequest progress:nil destination:^NSURL * (NSURL * targetPath, NSURLResponse * response) {
            
            // Because our baseEncryptionModel may have been changed while we downloaded the file, let's fetch it again
            POSBaseEncryptedModel *changedBaseEncryptionModel = nil;
            if (baseEncryptionModelIsAttachment) {
                changedBaseEncryptionModel = [POSAttachment existingAttachmentWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
            } else {
                changedBaseEncryptionModel = [POSReceipt existingReceiptWithUri:baseEncryptionModelUri inManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
            }
            
            NSString *filePath = [changedBaseEncryptionModel decryptedFilePath];
            
            if (!filePath) {
                return nil;
            }
            
            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            return fileUrl;
                                                                                                                                               }
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            BOOL downloadFailure = NO;
                NSLog(@"%@",error);
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            if ([HTTPURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([HTTPURLResponse statusCode] != 200) {
                    downloadFailure = YES;
                }
            }
            if (error || downloadFailure) {
                if (didChooseHigherScope){
                    POSAttachment *attachment = (id)baseEncryptionModel;
                    NSString *originalScope = [OAuthToken oAuthScopeForAuthenticationLevel:attachment.authenticationLevel];
                    [self validateAndDownloadBaseEncryptionModel:baseEncryptionModel withProgress:progress scope:originalScope didChooseHigherScope:NO success:success failure:failure];
                    return;
                }
                    
                // If we're getting a 401 from the server, the error object will be nil.
                // Let's set it to something more usable that the caller can interpret.
                if (!error) {
                    error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                                code:SHCAPIManagerErrorCodeUnauthorized
                                            userInfo:nil];
                }
                
                self.lastURLResponse = response;
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFailed;
            }else {
                self.lastURLResponse = response;
                self.lastSuccessBlock = success;
                self.state = SHCAPIManagerStateDownloadingBaseEncryptionModelFinished;
            }
            }];
        [task resume];
    }
        failure:^(NSError *error) {
            self.downloadingBaseEncryptionModel = NO;
            if (failure) {
                failure(error);
            }
        }];
}

- (void)cancelDownloadingBaseEncryptionModels
{
    __block NSUInteger counter = 0;

    [self.fileTransferSessionManager.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {}];
            counter++;
        }

        if (counter > 0) {
            NSString *downloadWord = counter > 1 ? @"downloads" : @"download";
            DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, downloadWord);
        }
    }];
}

- (void)moveDocument:(POSDocument *)document toFolder:(POSFolder *)folder withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateMovingDocument;
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        
        NSString *urlString = document.updateUri;
        
        AFJSONRequestSerializer *JSONRequestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        
        NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];
        [JSONRequestSerializer setValue:contentType forHTTPHeaderField:@"Accept"];
        
        NSString *bearer = [NSString stringWithFormat:@"Bearer %@",[OAuthToken oAuthTokenWithScope:kOauth2ScopeFull].accessToken];
        [JSONRequestSerializer setValue:bearer forHTTPHeaderField:@"Authorization"];
        
        NSString *subject = [(POSAttachment *)[document.attachments firstObject] subject];
        NSString *folderLocation = @"";
        NSDictionary *parameters;
        if ([folder.name isEqualToString:@"Inbox"]){
            folderLocation = @"INBOX";
            parameters = @{NSStringFromSelector(@selector(subject)):  subject,
                                     NSStringFromSelector(@selector(location)): folderLocation,
                                     };
        
        }else {
            folderLocation = @"FOLDER";
            parameters = @{NSStringFromSelector(@selector(subject)):  subject,
                                     NSStringFromSelector(@selector(location)): folderLocation,
                                     NSStringFromSelector(@selector(folderId)): folder.folderId
                                     };
        
        }
        
    NSMutableURLRequest *request = [JSONRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastURLResponse = response;
                self.state = SHCAPIManagerStateMovingDocumentFailed;
            } else {
                self.lastSuccessBlock = success;
                self.lastResponseObject = responseObject;
                self.lastDocument = document;
                self.state = SHCAPIManagerStateMovingDocumentFinished;
            }
        }];
        
        [task resume];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteDocument:(POSDocument *)document withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(document);
    self.state = SHCAPIManagerStateDeletingDocument;

    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        [self.sessionManager DELETE:document.deleteUri
                         parameters:nil
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                self.lastSuccessBlock = success;
                                self.lastResponseObject = responseObject;
                                self.lastDocument = document;
                                self.state = SHCAPIManagerStateDeletingDocumentFinished;
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                self.lastFailureBlock = failure;
                                self.lastError = error;
                                self.lastURLResponse = task.response;
                                self.state = SHCAPIManagerStateDeletingDocumentFailed;
                            }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)logout
{
    [[POSAPIManager sharedManager] logoutWithSuccess:^{
        [OAuthToken removeAllTokens];
        [[POSModelManager sharedManager] deleteAllObjects];
    } failure:^(NSError *error) {
        [OAuthToken removeAllTokens];
        [[POSModelManager sharedManager] deleteAllObjects];
    }];
}

- (void)logoutWithSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateLoggingOut;

    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        
        POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
        
        // If we don't have a root resource yet, there's nothing to log out of - let's just return successfully
        if (!rootResource) {
            if (success) {
                success();
                self.state = SHCAPIManagerStateLoggingOutFinished;
                return;
            }
        }
        
        [self.sessionManager POST:rootResource.logoutUri
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              self.lastSuccessBlock = success;
                              self.state = SHCAPIManagerStateLoggingOutFinished;
                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                              self.lastFailureBlock = failure;
                              self.lastError = error;
                              self.lastURLResponse = task.response;
                              self.state = SHCAPIManagerStateLoggingOutFailed;
                          }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateReceiptsInMailboxWithDigipostAddress:(NSString *)digipostAddress uri:(NSString *)uri success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateUpdatingReceipts;

    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        self.lastReceiptsUri = uri;
        self.lastMailboxDigipostAddress = digipostAddress;
        
        [self.sessionManager GET:uri
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             self.lastSuccessBlock = success;
                             self.lastURLResponse = task.response;
                             self.lastResponseObject = responseObject;
                             self.state = SHCAPIManagerStateUpdatingReceiptsFinished;
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             self.lastFailureBlock = failure;
                             self.lastURLResponse = task.response;
                             self.lastError = error;
                             self.state = SHCAPIManagerStateUpdatingReceiptsFailed;
                         }];
    } failure:^(NSError *error) {
        self.updatingReceipts = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUpdatingReceipts
{
    if (self.lastReceiptsUri) {
        NSURL *URL = [NSURL URLWithString:self.lastReceiptsUri];
        NSString *pathSuffix = [URL lastPathComponent];
        [self cancelRequestsWithPathSuffix:pathSuffix];

        self.state = SHCAPIManagerStateUpdatingReceiptsFailed;
        self.lastMailboxDigipostAddress = nil;
        self.lastReceiptsUri = nil;
    }
}

- (void)deleteReceipt:(POSReceipt *)receipt withSuccess:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.state = SHCAPIManagerStateDeletingReceipt;
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        [self.sessionManager DELETE:receipt.deleteUri
                         parameters:nil
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                self.lastSuccessBlock = success;
                                self.lastResponseObject = responseObject;
                                self.lastReceipt = receipt;
                                self.state = SHCAPIManagerStateDeletingReceiptFinished;
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                self.lastFailureBlock = failure;
                                self.lastError = error;
                                self.lastURLResponse = task.response;
                                self.state = SHCAPIManagerStateDeletingReceiptFailed;
                            }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)uploadFileWithURL:(NSURL *)fileURL toFolder:(POSFolder *)folder success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{
    // Let's do a couple of checks before kicking off the upload

    // First, check if the file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileURL.path]) {

        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                             code:SHCAPIManagerErrorCodeUploadFileDoesNotExist
                                         userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // Then, check if the file is too big
    unsigned long long maxFileSize = (unsigned long long)(pow(2, 20) * 10); // Max filesize dictated by Digipost (10 MB)

    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fileURL.path
                                                                 error:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }

    unsigned long long fileSize = [fileAttributes fileSize];
    if (fileSize > maxFileSize) {
        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                             code:SHCAPIManagerErrorCodeUploadFileTooBig
                                         userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // The file is good - next, check if we have our upload documents link
    POSRootResource *rootResource = [POSRootResource existingRootResourceInManagedObjectContext:[POSModelManager sharedManager].managedObjectContext];
    if (![rootResource.uploadDocumentUri length] > 0) {
        NSError *error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                             code:SHCAPIManagerErrorCodeUploadLinkNotFoundInRootResource
                                         userInfo:nil];

        if (failure) {
            failure(error);
        }
        return;
    }

    // We're good to go - let's cancel any ongoing uploads and delete any previous temporary files
    if (self.isUploadingFile) {
        [self cancelUploadingFiles];
    }

    [self removeTemporaryUploadFiles];

    // Move the file to our special uploads folder
    NSString *uploadsFolderPath = [[POSFileManager sharedFileManager] uploadsFolderPath];

    NSString *fileName = [fileURL lastPathComponent];
    NSString *filePath = [uploadsFolderPath stringByAppendingPathComponent:fileName];
    NSURL *uploadURL = [NSURL fileURLWithPath:filePath];

    if (![fileManager moveItemAtURL:fileURL
                              toURL:uploadURL
                              error:&error]) {
        if (failure) {
            failure(error);
        }
        return;
    }

    [self removeTemporaryInboxFiles];

    // Ready!
    self.state = SHCAPIManagerStateUploadingFile;
    self.lastOAuth2Scope = kOauth2ScopeFull;

    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        NSMutableURLRequest *urlRequest = [self.fileTransferSessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:folder.uploadDocumentUri parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // Subject
            NSRange rangeOfExtension = [fileName rangeOfString:[NSString stringWithFormat:@".%@", [uploadURL pathExtension]]];
            NSString *subject = [fileName substringToIndex:rangeOfExtension.location];
            subject = [subject stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [formData appendPartWithFormData:[subject dataUsingEncoding:NSASCIIStringEncoding] name:@"subject"];
            
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:uploadURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                DDLogError(@"Error reading data: %@", [error localizedDescription]);
            }
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"application/pdf"];
        } error:nil];
        
        [urlRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        
        self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"fileName": fileName}];
        self.uploadProgress.totalUnitCount = (int64_t)fileSize;
        
        [self.uploadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:kSHCAPIManagerKVOContext];
        
        __weak typeof(self.uploadProgress) weakUploadProgress = self.uploadProgress;
        [self.fileTransferSessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            weakUploadProgress.completedUnitCount = totalBytesSent;
        }];
        
        self.uploadTask = [self.fileTransferSessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            
            BOOL uploadFailure = NO;
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            if ([HTTPURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([HTTPURLResponse statusCode] != 200) {
                    uploadFailure = YES;
                }
            }
            
            if (error || uploadFailure) {
                
                // In case we're not actually getting an error object, let's create one
                // and set it to something more usable that the caller can interpret.
                if (!error) {
                    error = [NSError errorWithDomain:kAPIManagerErrorDomain
                                                code:SHCAPIManagerErrorCodeUploadFailed
                                            userInfo:nil];
                }
                
                self.lastURLResponse = response;
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.state = SHCAPIManagerStateUploadingFileFailed;
            } else {
                self.lastURLResponse = response;
                self.lastSuccessBlock = success;
                self.state = SHCAPIManagerStateUploadingFileFinished;
            }
        }];
        
        [self.uploadTask resume];
    } failure:^(NSError *error) {
        self.uploadingFile = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)createFolderWithName:(NSString *)name iconName:(NSString *)iconName forMailBox:(POSMailbox *)mailbox success:(void (^)(void))success failure:(void (^)(NSError *))failure
{

    NSDictionary *parameters = @{ @"name" : name,
                                  @"icon" : iconName };
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
    self.state = SHCAPIManagerStateCreatingFolder;
        [self jsonRequestWithMethod:@"POST" oAuth2Scope:self.lastOAuth2Scope parameters:parameters
                                url:mailbox.createFolderUri
                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                      if (error) {
                                  NSLog(@"%@",error);
                                  self.lastFailureBlock = failure;
                                  self.lastError = error;
                                  self.lastURLResponse = response;
                                  self.state = SHCAPIManagerStateCreatingFolderFailed;
                              } else {
                                  self.lastSuccessBlock = success;
                                  self.lastResponseObject = responseObject;
                                  self.state = SHCAPIManagerStateCreatingFolderFinished;
                              }
                          }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)changeNameOfDocument:(POSDocument *)document newName:(NSString *)newName success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.lastOAuth2Scope = [OAuthToken oAuthScopeForAuthenticationLevel:document.authenticationLevelForMainAttachment];
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
            self.state = SHCAPIManagerStateChangeDocumentName;
        NSDictionary *parameters;
        NSString *folderLocation;
        if ([document.folder.name isEqualToString:@"Inbox"]){
            folderLocation = @"INBOX";
            parameters = @{NSStringFromSelector(@selector(subject)):  newName,
                           NSStringFromSelector(@selector(location)): folderLocation,
                           };
            
        }else {
            folderLocation = @"FOLDER";
            parameters = @{NSStringFromSelector(@selector(subject)):  newName,
                           NSStringFromSelector(@selector(location)): folderLocation,
                           NSStringFromSelector(@selector(folderId)): document.folder.folderId
                           };
            
        }

        [self jsonRequestWithMethod:@"POST" oAuth2Scope:self.lastOAuth2Scope  parameters:parameters url:document.updateUri completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error ){
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastURLResponse = response;
                self.state = SHCAPIManagerStateChangeDocumentNameFailed;
            } else {
                self.lastSuccessBlock = success;
                self.lastResponseObject = responseObject;
                self.state = SHCAPIManagerStateChangeDocumentNameFinished;
            }
        }];
    } failure:^(NSError *error){}];
}

- (void)changeFolder:(POSFolder *)folder newName:(NSString *)newName newIcon:(NSString *)newIcon success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    [self validateTokensForScope:kOauth2ScopeFull success:^{
        NSDictionary *parameters =@{@"id":folder.folderId,
                                    @"name":newName,
                                    @"icon":newIcon
                                    };
    self.state = SHCAPIManagerStateChangingFolder;
        [self jsonRequestWithMethod:@"PUT" oAuth2Scope:self.lastOAuth2Scope  parameters:parameters
                                url:folder.changeFolderUri
                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                      if (error) {
                          self.lastFailureBlock = failure;
                          self.lastError = error;
                          self.lastURLResponse = response;
                          self.state = SHCAPIManagerStateChangingFolderFailed;
                      } else {
                          self.lastSuccessBlock = success;
                          self.lastURLResponse = response;
                          self.lastResponseObject = responseObject;
                          self.state = SHCAPIManagerStateChangingFolderFinished;
                      }
                }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateDocument:(POSDocument *)document success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.lastOAuth2Scope = [OAuthToken oAuthScopeForAuthenticationLevel:document.authenticationLevelForMainAttachment];
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        self.state = SHCAPIManagerStateUpdateSingleDocument;
        self.lastDocument = document;
        [self.sessionManager GET:document.updateUri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            self.lastSuccessBlock = success;
            self.lastResponseObject = responseObject;
            self.state = SHCAPIManagerStateUpdateSingleDocumentFinished;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.lastFailureBlock = failure;
            self.lastError = error;
            self.state = SHCAPIManagerStateUpdateSingleDocumentFailed;
        }];
    } failure:^(NSError *error) {
        if (failure){
            failure(error);
        }
    }];
}

- (void)validateOpeningReceipt:(POSAttachment *)attachment success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        self.state = SHCAPIManagerStateValididatingOpeningReceipt;
        [self.sessionManager POST:attachment.openingReceiptUri parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            self.lastSuccessBlockWithAttachmentAttributes = success;
            self.lastResponseObject = responseObject;
            self.state = SHCAPIManagerStateValididatingOpeningReceiptFinished;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            self.lastFailureBlock = failure;
            self.lastError = error;
            self.state = SHCAPIManagerStateValididatingOpeningReceiptFailed;
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)moveFolder:(NSArray *)folderArray mailbox:(POSMailbox *)mailbox success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    NSParameterAssert(mailbox);
    NSMutableArray *folderIDs = [NSMutableArray array];
    [folderArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        POSFolder *folder = (id)obj;
        NSDictionary *folderDict = @{@"id":folder.folderId,
                                     @"name":folder.name,
                                     @"icon":folder.iconName};
        
        [folderIDs addObject:folderDict];
    }];

    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        self.state = SHCAPIManagerStateMovingFolders;
        NSDictionary *parameters = @{@"folder":folderIDs};
        [self jsonRequestWithMethod:@"PUT" oAuth2Scope:self.lastOAuth2Scope parameters:parameters url:mailbox.updateFoldersUri completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastURLResponse = response;
                self.state = SHCAPIManagerStateMovingFoldersFailed;
            } else {
                self.lastSuccessBlock = success;
                self.lastResponseObject = responseObject;
                self.state = SHCAPIManagerStateMovingFoldersFinished;
            }
        }];
    } failure:^(NSError *error){}];
}

- (void)delteFolder:(POSFolder *)folder success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
    self.lastOAuth2Scope = kOauth2ScopeFull;
    [self validateTokensForScope:self.lastOAuth2Scope success:^{
        NSDictionary *parameters =@{ @"id":folder.folderId,
                                     @"name":folder.name,
                                     @"icon":folder.iconName
                                     };
        self.state = SHCAPIManagerStateDeletingFolder;
        [self jsonRequestWithMethod:@"DELETE" oAuth2Scope:self.lastOAuth2Scope parameters:parameters url:folder.deletefolderUri completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastURLResponse = response;
                self.state = SHCAPIManagerStateDeletingFolderFailed;
                NSLog(@"failed %@",error);
            } else {
                self.lastSuccessBlock = success;
                self.lastResponseObject = responseObject;
                self.state = SHCAPIManagerStateDeletingFolderFinished;
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)cancelUploadingFiles
{
    NSUInteger counter = 0;

    for (NSURLSessionUploadTask *uploadTask in self.fileTransferSessionManager.uploadTasks) {
        [uploadTask cancel];
        counter++;
    }

    if (counter > 0) {
        NSString *uploadWord = counter > 1 ? @"uploads" : @"upload";
        DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, uploadWord);
    }
}

- (void)removeTemporaryUploadFiles
{
    NSString *uploadsPath = [[POSFileManager sharedFileManager] uploadsFolderPath];

    if (![[POSFileManager sharedFileManager] removeAllFilesInFolder:uploadsPath]) {
        return;
    }
}

- (void)removeTemporaryInboxFiles
{
    NSString *inboxPath = [[POSFileManager sharedFileManager] inboxFolderPath];

    if (![[POSFileManager sharedFileManager] removeAllFilesInFolder:inboxPath]) {
        return;
    }
}

- (BOOL)responseCodeIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 401 || // Unauthorized.
            [HTTPResponse statusCode] == 403) { // Forbidden.
            return YES;
        }
    }

    return NO;
}

- (BOOL)responseCodeForOAuthIsUnauthorized:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if ([HTTPResponse statusCode] == 400 || // Bad Request. OAuth 2.0 responds with HTTP 400 if the request is somehow invalid or unauthorized.
            [HTTPResponse statusCode] == 401 || // Unauthorized.
            [HTTPResponse statusCode] == 403) { // Forbidden.
            return YES;
        }
    }

    return NO;
}

#pragma mark - Private methods

- (void)validateTokensForScope:(NSString *)scope success:(void (^)(void))success failure:(void (^)(NSError *error))failure
{
    self.state = SHCAPIManagerStateValidatingAccessToken;

    POSOAuthManager *OAuthManager = [POSOAuthManager sharedManager];
    OAuthToken *oAuthToken = [OAuthToken oAuthTokenWithScope:scope];
    // If the OAuth manager already has its access token, we'll go ahead and try an API request using this.
    self.lastOAuth2Scope = scope;
    if (oAuthToken.accessToken) {
        self.lastSuccessBlock = success;
        self.state = SHCAPIManagerStateValidatingAccessTokenFinished;
        return;
    }

    // If the OAuth manager has its refresh token, ask it to update its access token first,
    // and then go ahead and try an API request.

    if (oAuthToken.refreshToken) {
        self.state = SHCAPIManagerStateRefreshingAccessToken;
        NSAssert(self.lastOAuth2Scope != nil, @"no scope set!");
        [OAuthManager refreshAccessTokenWithRefreshToken:oAuthToken.refreshToken scope:self.lastOAuth2Scope
            success:^{
                self.lastSuccessBlock = success;
                self.lastOAuth2Scope = scope;
                self.state = SHCAPIManagerStateRefreshingAccessTokenFinished;
            }
            failure:^(NSError *error) {
                NSLog(@"Error %@",error);
                self.lastFailureBlock = failure;
                self.lastError = error;
                self.lastOAuth2Scope = scope;
                self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
            }];

    } else if (oAuthToken == nil && scope == kOauth2ScopeFull) {
        NSLog(@"Error  No login token");
        // if no oauthtoken  and the scope is full, means user has not yet logged in, ask user to log in
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewControllerNotificationName object:nil];
        self.lastFailureBlock = failure;
        self.lastOAuth2Scope = scope;
        self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
    } else {
        NSLog(@"Error unknown error, could not refresh refresh token");
        // refresh
        self.lastFailureBlock = failure;
        self.lastOAuth2Scope = scope;
        self.state = SHCAPIManagerStateRefreshingAccessTokenFailed;
    }
}

- (void)updateAuthorizationHeaderForScope:(NSString *)scope
{
    OAuthToken *oAuthToken = [OAuthToken oAuthTokenWithScope:scope];
    NSString *bearer = [NSString stringWithFormat:@"Bearer %@", oAuthToken.accessToken];
    [self.sessionManager.requestSerializer setValue:bearer
                                 forHTTPHeaderField:@"Authorization"];
    [self.fileTransferSessionManager.requestSerializer setValue:bearer
                                             forHTTPHeaderField:@"Authorization"];
}

- (void)networkRequestDidStart:(NSNotification *)notification
{
    NSURLRequest *request = [[notification object] originalRequest];

    if (!request) {
        return;
    }

    BOOL wasSuspended = [objc_getAssociatedObject([notification object], kSHCAPIManagerRequestWasSuspended) boolValue];

    if (!wasSuspended) {
        DDLogInfo(@"%@ %@", [request HTTPMethod], [[request URL] absoluteString]);
    }
}

- (void)networkRequestDidSuspend:(NSNotification *)notification
{
    // Because requests are often put in a suspended state right after they've been started,
    // and then restarted again - we track this fact here, and then only log the requests
    // when they haven't already been suspended.

    objc_setAssociatedObject([notification object], kSHCAPIManagerRequestWasSuspended, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)networkRequestDidFinish:(NSNotification *)notification
{
    NSURLRequest *request = [[notification object] originalRequest];
    NSURLResponse *response = [[notification object] response];
    NSError *error = [[notification object] error];

    NSUInteger responseStatusCode = [(NSHTTPURLResponse *)response statusCode];

    if (error) {
        DDLogDebug(@"[Error] %@ %@ (%ld): %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, error);
    } else {
        DDLogDebug(@"%ld %@", (long)responseStatusCode, [[response URL] absoluteString]);
    }
}

- (void)cleanup
{
    self.lastSuccessBlock = nil;
    self.lastFailureBlock = nil;
    self.lastURLResponse = nil;
    self.lastResponseObject = nil;
    self.lastFolderName = nil;
    self.lastMailboxDigipostAddress = nil;
    self.lastFolderUri = nil;
    self.lastError = nil;
    self.lastDocument = nil;
    self.lastSuccessBlockWithAttachmentAttributes = nil;
    self.lastOAuth2Scope = nil;
    self.state = SHCAPIManagerStateIdle;
}

- (void)cancelRequestsWithPathSuffix:(NSString *)pathSuffix
{
    NSUInteger counter = 0;

    for (NSURLSessionDataTask *task in self.sessionManager.tasks) {
        NSString *urlString = [[task.currentRequest URL] absoluteString];
        if ([urlString length] > 0 && [pathSuffix length] > 0 && [urlString hasSuffix:pathSuffix]) {
            [task cancel];
            counter++;
        }
    }

    if (counter > 0) {
        NSString *requestWord = counter > 1 ? @"requests" : @"request";
        DDLogInfo(@"%lu %@ canceled", (unsigned long)counter, requestWord);
    }
}

- (BOOL)requestWasCanceledWithError:(NSError *)error
{
    if ([error code] == -999) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)mimeTypeForFileType:(NSString *)fileType
{
    // First, grab the UTI
    CFStringRef pathExtension = (__bridge_retained CFStringRef)fileType;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);

    // The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL) {
        CFRelease(type);
    }

    return mimeType;
}

@end
