//
//  SHCFolderTableViewCell.h
//  Digipost
//
//  Created by Eivind Bohler on 12.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kFolderTableViewCellIdentifier;

@interface SHCFolderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *folderNameLabel;

@end
