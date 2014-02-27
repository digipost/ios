//
//  UIView+AutoLayout.h
//  Digipost
//
//  Created by Håkon Bogen on 30.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AutoLayout)

- (void)addHeightConstraint: (CGFloat)height;
- (void)addSizeConstraint: (CGSize) size;
- (void)addOriginConstraintForOrigin:(CGPoint)origin containedView:(UIView*)view;
- (void)addVerticalSpaceBottomConstraintForBottom:(CGFloat)bottom fromView:(UIView*)fromView toView:(UIView*)toView;

@end
