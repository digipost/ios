//
//  SHCReceiptTableViewCell.h
//  Digipost
//
//  Created by Eivind Bohler on 20.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kReceiptTableViewCellIdentifier;

@interface SHCReceiptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardLabel;
@property (weak, nonatomic) IBOutlet UILabel *franchiseLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
