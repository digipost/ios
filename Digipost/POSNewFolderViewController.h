//
//  POSNewFolderViewController.h
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POSFolder.h"
#import "POSMailbox.h"

@interface POSNewFolderViewController : UIViewController <UICollectionViewDelegate>
@property (nonatomic, strong) POSFolder *selectedFolder;
// used for creating new folder for a mailbox
@property (nonatomic, strong) POSMailbox *mailbox;
@end
