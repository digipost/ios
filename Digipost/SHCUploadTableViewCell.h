//
//  SHCUploadTableViewCell.h
//  Digipost
//
//  Created by Eivind Bohler on 23.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kUploadTableViewCellIdentifier;

@class THProgressView;

@interface SHCUploadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@end
