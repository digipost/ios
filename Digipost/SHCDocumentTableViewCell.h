//
//  SHCDocumentTableViewCell.h
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kDocumentTableViewCellIdentifier;

@protocol SHCDocumentTableViewCellDelegate;

@interface SHCDocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lockedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

@end
