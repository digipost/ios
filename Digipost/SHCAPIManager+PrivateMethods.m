//
//  SHCAPIManager+PrivateMethods.m
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "SHCAPIManager+PrivateMethods.h"
#import "SHCOAuthManager.h"
#import "SHCAPIManager.h"
#import <AFHTTPSessionManager.h>

@implementation SHCAPIManager (PrivateMethods)

- (void)jsonPOSTRequestWithParameters:(NSDictionary *)parameters url:(NSString *)url completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    NSString *urlString = url;

    AFJSONRequestSerializer *JSONRequestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];

    NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];
    [JSONRequestSerializer setValue:contentType
                 forHTTPHeaderField:@"Accept"];

    NSString *bearer = [NSString stringWithFormat:@"Bearer %@", [SHCOAuthManager sharedManager].accessToken];
    [JSONRequestSerializer setValue:bearer
                 forHTTPHeaderField:@"Authorization"];

    NSMutableURLRequest *request = [JSONRequestSerializer requestWithMethod:@"POST"
                                                                  URLString:urlString
                                                                 parameters:parameters];
    [request setValue:contentType
        forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request
                                                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                            completionHandler(response,responseObject,error);
                                                        }];
    [task resume];
}

@end
