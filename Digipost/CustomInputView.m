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
