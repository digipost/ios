// 
// Copyright (C) Posten Norge AS
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//         http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NSURLRequest+QueryParameters.h"

@implementation NSURLRequest (QueryParameters)

- (NSDictionary *)queryParameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    for (NSString *parameter in [[[self URL] query] componentsSeparatedByString:@"&"]) {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        if ([parts count] < 2) {
            continue;
        }

        parameters[[parts firstObject]] = parts[1];
    }

    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
