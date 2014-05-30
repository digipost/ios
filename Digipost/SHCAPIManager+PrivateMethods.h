//
//  SHCAPIManager+PrivateMethods.h
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "SHCAPIManager.h"

@interface SHCAPIManager (PrivateMethods)

- (void)jsonPOSTRequestWithParameters:(NSDictionary *)parameters url:(NSString *)url completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler;

@end
