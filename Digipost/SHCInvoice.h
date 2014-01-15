//
//  SHCInvoice.h
//  Digipost
//
//  Created by Eivind Bohler on 15.01.14.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Core Data model entity names
extern NSString *const kInvoiceEntityName;

@class SHCAttachment;

@interface SHCInvoice : NSManagedObject

// Attributes
@property (strong, nonatomic) NSNumber *accountNumber;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *canBePaidByUser;
@property (strong, nonatomic) NSDate *dueDate;
@property (strong, nonatomic) NSNumber *kid;
@property (strong, nonatomic) NSString *sendToBankUri;
@property (strong, nonatomic) NSDate *timePaid;
@property (strong, nonatomic) NSString *bankHomepage;

// Relationships
@property (strong, nonatomic) SHCAttachment *attachment;

+ (instancetype)invoiceWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
