//
//  POSNewFolderViewController.h
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POSFolder.h"

@interface POSNewFolderViewController : UIViewController <UICollectionViewDelegate>
@property (nonatomic, strong) POSFolder *selectedFolder;
@end
