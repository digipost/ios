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

#import <UIKit/UIKit.h>
#import <GAI.h>

// Segue identifiers (to enable programmatic triggering of segues)
extern NSString *const kPresentOAuthModallyIdentifier;

@protocol SHCOAuthViewControllerDelegate;

@interface SHCOAuthViewController : GAITrackedViewController

@property (weak, nonatomic) id<SHCOAuthViewControllerDelegate> delegate;

@end

@protocol SHCOAuthViewControllerDelegate <NSObject>

@required

- (void)OAuthViewControllerDidAuthenticate:(SHCOAuthViewController *)OAuthViewController;

@end