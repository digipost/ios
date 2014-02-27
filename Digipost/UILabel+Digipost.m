//
//  UILabel+Digipost.m
//  Digipost
//
//  Created by Håkon Bogen on 30.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UILabel+Digipost.h"

@implementation UILabel (Digipost)

+ (UILabel *)tableViewMediumHeaderLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [label setTextColor:RGB(64, 66, 69)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

+ (UILabel *)tableViewRegularHeaderLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    [label setTextColor:RGB(64, 66, 69)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
+ (UILabel *)popoverViewDescriptionLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [label setTextColor:RGB(153,153,153)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
+ (UILabel *)popoverViewLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17]];
    [label setTextColor:RGB(51,51,51)];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}
@end
