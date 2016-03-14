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

#import "CustomInputView.h"
#import "Digipost-Swift.h"
#import <objc/runtime.h>

@interface CustomInputView ()

@end

@implementation CustomInputView

static const char *kWKContentViewName = "WKContentView";
static const char *const newWebBrowserViewClassName = "newWebBrowserViewClassName";

static Class NewWebBrowserViewClass = Nil;

- (id)viewForCustomInputView
{
    return [APIClient sharedClient].stylepickerViewController.view;
}

- (UIView *)findWKContentViewInSubviewOfView:(UIView *)aView
{
    for (UIView *subview in aView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:[NSString stringWithFormat:@"%s", kWKContentViewName]]) {
            return subview;
        } else if ([NSStringFromClass([subview class]) hasPrefix:[NSString stringWithFormat:@"%s", newWebBrowserViewClassName]]) {
            return subview;
        }
    }
    return nil;
}

- (void)setShowCustomInputViewEnabled:(BOOL)enabled containedInScrollView:(UIScrollView *)scrollView
{
    UIView *browserView = [self findWKContentViewInSubviewOfView:scrollView];
    if (browserView == nil) {
        return;
    }

    [self setNewInputViewMethodForClass:[browserView class]];

    if (enabled) {
        object_setClass(browserView, NewWebBrowserViewClass);
    } else {
        Class normalClass = objc_getClass(kWKContentViewName);
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

- (void)setNewInputViewMethodForClass:(Class)browserViewClass
{
    if (!NewWebBrowserViewClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, newWebBrowserViewClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, newWebBrowserViewClassName, 0);
        IMP newImp = [self methodForSelector:@selector(viewForCustomInputView)];

        class_addMethod(newClass, @selector(inputView), newImp, "@@:");
        objc_registerClassPair(newClass);
        NewWebBrowserViewClass = newClass;
    }
}

@end
