//
//  POSMailbox.m
//  Digipost
//
//  Created by Håkon Bogen on 30.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "POSMailbox.h"
#import "POSFolder.h"
#import "POSReceipt.h"
#import "POSRootResource.h"

@implementation POSMailbox

@dynamic digipostAddress;
@dynamic owner;
@dynamic receiptsUri;
@dynamic createFolderUri;
@dynamic updateFoldersUri;
@dynamic folders;
@dynamic receipts;
@dynamic rootResource;

@end
