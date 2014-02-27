//
//  UIView+AutoLayout.m
//  Digipost
//
//  Created by Håkon Bogen on 30.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)
- (void)replaceIfExistsConstraintForContainingView:(UIView *)view costraint:(NSLayoutConstraint *) newCostraint
{
    NSParameterAssert(newCostraint);
    NSLayoutConstraint *oldConstraint = nil;
    for (NSLayoutConstraint *constraint in view.constraints) {
        if ([constraint.firstItem isEqual:view]){
            if (constraint.firstItem == newCostraint.firstItem) {
                if (constraint.firstAttribute == newCostraint.firstAttribute) {
                    if (constraint.relation == newCostraint.relation) {
                        oldConstraint = constraint;
                        break;
                    }
                }
            }
        }
    }
    
    [view removeConstraint:oldConstraint];
    [view addConstraint:newCostraint];
}
- (void)addVerticalSpaceBottomConstraintForBottom:(CGFloat)bottom fromView:(UIView*)fromView toView:(UIView*)toView
{
    [self replaceIfExistsConstraintForContainingView:self
                                           costraint:[NSLayoutConstraint constraintWithItem:fromView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem: toView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:bottom]];
    
}

- (void)addOriginConstraintForOrigin:(CGPoint)origin containedView:(UIView*)view
{
    NSParameterAssert(view);
    NSAssert([view isEqual:self] == NO, @"View cannot contain itself");
    
     [self replaceIfExistsConstraintForContainingView:self costraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:origin.x]];
    
    [self replaceIfExistsConstraintForContainingView:self costraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:origin.y]];
}

- (void)addHeightConstraint:(CGFloat)height
{
    [self replaceIfExistsConstraintForContainingView:self costraint: [NSLayoutConstraint constraintWithItem:self
                                                                                                  attribute:NSLayoutAttributeHeight
                                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                                     toItem:nil
                                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                                 multiplier:1.0
                                                                                                   constant:height]];
    
    
}

- (void)addSizeConstraint: (CGSize) size
{
    [self replaceIfExistsConstraintForContainingView:self costraint: [NSLayoutConstraint constraintWithItem:self
                                                                                                  attribute:NSLayoutAttributeWidth
                                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                                     toItem:nil
                                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                                 multiplier:1.0
                                                                                                   constant:size.width]];
    [self replaceIfExistsConstraintForContainingView:self costraint: [NSLayoutConstraint constraintWithItem:self
                                                                                                  attribute:NSLayoutAttributeHeight
                                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                                     toItem:nil
                                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                                 multiplier:1.0
                                                                                                   constant:size.height]];
}

@end
