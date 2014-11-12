//
//  SHCAPIManager+PrivateMethods.m
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSAPIManager+PrivateMethods.h"
#import "POSOAuthManager.h"
#import "POSAPIManager.h"
#import <AFHTTPSessionManager.h>

@implementation POSAPIManager (PrivateMethods)

- (void)jsonRequestWithMethod:(NSString *)method parameters:(NSDictionary *)parameters url:(NSString *)url completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    NSString *urlString = url;

    AFJSONRequestSerializer *JSONRequestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];

    NSString *contentType = [NSString stringWithFormat:@"application/vnd.digipost-%@+json", __API_VERSION__];

    [JSONRequestSerializer setValue:contentType
                 forHTTPHeaderField:@"Accept"];

    NSString *bearer = [NSString stringWithFormat:@"Bearer %@", [POSOAuthManager sharedManager].accessToken];
    [JSONRequestSerializer setValue:bearer
                 forHTTPHeaderField:@"Authorization"];

    NSMutableURLRequest *request = [JSONRequestSerializer requestWithMethod:method
                                                                  URLString:urlString
                                                                 parameters:parameters error:nil];
    [request setValue:contentType
        forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request
                                                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                            completionHandler(response,responseObject,error);
                                                        }];
    [task resume];
}

@end
