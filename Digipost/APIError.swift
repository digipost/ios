//
//  APIError.swift
//  Digipost
//
//  Created by Håkon Bogen on 20/01/15.
//  Copyright (c) 2015 Posten. All rights reserved.
//

import UIKit



class APIError: NSError {
    
    init(error: NSError) {
        
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
//    init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?)
    
    override init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    

    class func UnauthorizedOAuthTokenError() -> APIError {
        let apierror = APIError(domain: Constants.Error.apiErrorDomainOAuthUnauthorized, code: Constants.Error.Code.oAuthUnathorized.rawValue, userInfo: nil)
        return apierror
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //    m CFNetworkErrors : Int32 {
    
//    case CFHostErrorHostNotFound
//    case CFHostErrorUnknown // Query the kCFGetAddrInfoFailureKey to get the value returned from getaddrinfo; lookup in netdb.h
//    // SOCKS errors; in all cases you may query kCFSOCKSStatusCodeKey to recover the status code returned by the server
//    case CFSOCKSErrorUnknownClientVersion
//    case CFSOCKSErrorUnsupportedServerVersion // Query the kCFSOCKSVersionKey to find the version requested by the server
//    // SOCKS4-specific errors
//    case CFSOCKS4ErrorRequestFailed // request rejected or failed by the server
//    case CFSOCKS4ErrorIdentdFailed // request rejected because SOCKS server cannot connect to identd on the client
//    case CFSOCKS4ErrorIdConflict // request rejected because the client program and identd report different user-ids
//    case CFSOCKS4ErrorUnknownStatusCode
//    // SOCKS5-specific errors
//    case CFSOCKS5ErrorBadState
//    case CFSOCKS5ErrorBadResponseAddr
//    case CFSOCKS5ErrorBadCredentials
//    case CFSOCKS5ErrorUnsupportedNegotiationMethod // query kCFSOCKSNegotiationMethodKey to find the method requested
//    case CFSOCKS5ErrorNoAcceptableMethod
//    // FTP errors; query the kCFFTPStatusCodeKey to get the status code returned by the server
//    case CFFTPErrorUnexpectedStatusCode
//    // HTTP errors
//    case CFErrorHTTPAuthenticationTypeUnsupported
//    case CFErrorHTTPBadCredentials
//    case CFErrorHTTPConnectionLost
//    case CFErrorHTTPParseFailure
//    case CFErrorHTTPRedirectionLoopDetected
//    case CFErrorHTTPBadURL
//    case CFErrorHTTPProxyConnectionFailure
//    case CFErrorHTTPBadProxyCredentials
//    case CFErrorPACFileError
//    case CFErrorPACFileAuth
//    case CFErrorHTTPSProxyConnectionFailure
//    case CFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod
//    
//    // Error codes for CFURLConnection and CFURLProtocol
//    case CFURLErrorBackgroundSessionInUseByAnotherProcess
//    case CFURLErrorBackgroundSessionWasDisconnected
//    case CFURLErrorUnknown
//    case CFURLErrorCancelled
//    case CFURLErrorBadURL
//    case CFURLErrorTimedOut
//    case CFURLErrorUnsupportedURL
//    case CFURLErrorCannotFindHost
//    case CFURLErrorCannotConnectToHost
//    case CFURLErrorNetworkConnectionLost
//    case CFURLErrorDNSLookupFailed
//    case CFURLErrorHTTPTooManyRedirects
//    case CFURLErrorResourceUnavailable
//    case CFURLErrorNotConnectedToInternet
//    case CFURLErrorRedirectToNonExistentLocation
//    case CFURLErrorBadServerResponse
//    case CFURLErrorUserCancelledAuthentication
//    case CFURLErrorUserAuthenticationRequired
//    case CFURLErrorZeroByteResource
//    case CFURLErrorCannotDecodeRawData
//    case CFURLErrorCannotDecodeContentData
//    case CFURLErrorCannotParseResponse
//    case CFURLErrorInternationalRoamingOff
//    case CFURLErrorCallIsActive
//    case CFURLErrorDataNotAllowed
//    case CFURLErrorRequestBodyStreamExhausted
//    case CFURLErrorFileDoesNotExist
//    case CFURLErrorFileIsDirectory
//    case CFURLErrorNoPermissionsToReadFile
//    case CFURLErrorDataLengthExceedsMaximum
//    // SSL errors
//    case CFURLErrorSecureConnectionFailed
//    case CFURLErrorServerCertificateHasBadDate
//    case CFURLErrorServerCertificateUntrusted
//    case CFURLErrorServerCertificateHasUnknownRoot
//    case CFURLErrorServerCertificateNotYetValid
//    case CFURLErrorClientCertificateRejected
//    case CFURLErrorClientCertificateRequired
//    case CFURLErrorCannotLoadFromNetwork
//    // Download and file I/O errors
//    case CFURLErrorCannotCreateFile
//    case CFURLErrorCannotOpenFile
//    case CFURLErrorCannotCloseFile
//    case CFURLErrorCannotWriteToFile
//    case CFURLErrorCannotRemoveFile
//    case CFURLErrorCannotMoveFile
//    case CFURLErrorDownloadDecodingFailedMidStream
//    case CFURLErrorDownloadDecodingFailedToComplete
//    
//    // Cookie errors
//    case CFHTTPCookieCannotParseCookieFile
//    
//    // Errors originating from CFNetServices
//    case CFNetServiceErrorUnknown
//    case CFNetServiceErrorCollision
//    case CFNetServiceErrorNotFound
//    case CFNetServiceErrorInProgress
//    case CFNetServiceErrorBadArgument
//    case CFNetServiceErrorCancel
//    case CFNetServiceErrorInvalid
//    case CFNetServiceErrorTimeout
//    case CFNetServiceErrorDNSServiceFailure // An error /
//    typedef CF_ENUM(int, CFNetworkErrors) {
//    
//    kCFHostErrorHostNotFound = 1,
//    kCFHostErrorUnknown = 2, // Query the
    
    var alertTitle : String {
        switch Int32(self.code) {
        case CFNetworkErrors.CFErrorHTTPConnectionLost.rawValue:
            return "connection lost"
        case CFNetworkErrors.CFURLErrorTimedOut.rawValue:
            return "Timeout"
        case CFNetworkErrors.CFURLErrorCannotConnectToHost.rawValue:
            fallthrough
        case CFNetworkErrors.CFURLErrorCannotFindHost.rawValue:
            return "cannot connect to host"
        case CFNetworkErrors.CFURLErrorResourceUnavailable.rawValue:
            return "Server nede"
        case CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue:
            return "Not connected to internet"
        case CFNetworkErrors.CFURLErrorDataNotAllowed.rawValue:
            return "Du har skrudd av datatrafikk"
        case CFNetworkErrors.CFURLErrorInternationalRoamingOff.rawValue:
            return "Skru på roaming for å bruke digipost"
        case CFNetworkErrors.CFURLErrorUnknown.rawValue:
            return "Noe feil skjedde, prøv igjen"
            
//        case kCFURLErrorTimedOut :
//            return "timeout"
        default:
            return "??????????????????"
        }
    }
    
    var altertMessage : String {
        switch self.code {
        default:
            return ""
        }
    }
    
    var shouldBeShownToUser : Bool = true
    
}
