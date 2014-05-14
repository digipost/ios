//
//  POSReceiptFolderTableViewCell.h
//  Digipost
//
//  Created by Håkon Bogen on 14.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POSReceiptFolderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *franchiseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReceiptsLabel;

@end
