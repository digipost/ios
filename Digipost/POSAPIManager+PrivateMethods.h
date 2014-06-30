//
//  SHCAPIManager+PrivateMethods.h
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSAPIManager.h"

@interface POSAPIManager (PrivateMethods)

- (void)jsonRequestWithMethod:(NSString *)method parameters:(NSDictionary *)parameters url:(NSString *)url completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
@end
