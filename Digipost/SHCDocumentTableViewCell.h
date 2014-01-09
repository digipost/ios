//
//  SHCDocumentTableViewCell.h
//  Digipost
//
//  Created by Eivind Bohler on 16.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kDocumentTableViewCellIdentifier;

@interface SHCDocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

@end
