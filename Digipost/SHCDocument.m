//
//  SHCDocument.m
//  Digipost
//
//  Created by Eivind Bohler on 11.12.13.
//  Copyright (c) 2013 Shortcut. All rights reserved.
//

#import <TTTTimeIntervalFormatter.h>
#import "SHCDocument.h"
#import "SHCAttachment.h"
#import "SHCFolder.h"
#import "SHCModelManager.h"

// Core Data model entity names
NSString *const kDocumentEntityName = @"Document";

// API keys
NSString *const kDocumentDocumentsAPIKey = @"document";
NSString *const kDocumentCreatedAtAPIKey = @"created";
NSString *const kDocumentLinkAPIKey = @"link";
NSString *const kDocumentDeleteDocumentAPIKey = @"delete_document";
NSString *const kDocumentUpdateDocumentAPIKey = @"update_document";
NSString *const kDocumentAttachmentsAPIKey = @"attachment";

// Because of a bug in Core Data, we need to manually implement these methods
// See: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors

@implementation SHCDocument (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(SHCAttachment *)value
{
    NSMutableOrderedSet *attachmentsMutable = [NSMutableOrderedSet orderedSetWithOrderedSet:self.attachments];
    [attachmentsMutable addObject:value];
    self.attachments = [NSOrderedSet orderedSetWithOrderedSet:attachmentsMutable];
}

- (void)removeAttachmentsObject:(SHCAttachment *)value
{
    NSMutableOrderedSet *attachmentsMutable = [NSMutableOrderedSet orderedSetWithOrderedSet:self.attachments];
    [attachmentsMutable removeObject:value];
    self.attachments = [NSOrderedSet orderedSetWithOrderedSet:attachmentsMutable];
}

@end

@implementation SHCDocument

// Attributes
@dynamic createdAt;
@dynamic creatorName;
@dynamic deleteUri;
@dynamic location;
@dynamic updateUri;

// Relationships
@dynamic attachments;
@dynamic folder;

#pragma mark - Public methods

+ (instancetype)documentWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entity = [[SHCModelManager sharedManager] documentEntity];
    SHCDocument *document = [[SHCDocument alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];

    [document updateWithAttributes:attributes inManagedObjectContext:managedObjectContext];

    NSArray *attachments = attributes[kDocumentAttachmentsAPIKey];
    if ([attachments isKindOfClass:[NSArray class]]) {
        for (NSDictionary *attachmentDict in attachments) {
            if ([attachmentDict isKindOfClass:[NSDictionary class]]) {
                SHCAttachment *attachment = [SHCAttachment attachmentWithAttributes:attachmentDict inManagedObjectContext:managedObjectContext];
                [document addAttachmentsObject:attachment];
            }
        }
    }

    return document;
}

+ (instancetype)existingDocumentWithUpdateUri:(NSString *)updateUri inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] documentEntity];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSStringFromSelector(@selector(updateUri)), updateUri];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return [results firstObject];
}

+ (void)reconnectDanglingDocumentsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // At this point, all our Folder objects have been created anew.
    // Because the relationship from Folder to Document is of type Nullify,
    // this means that all Documents have their folder property set to nil.
    // Let's reconnect all Documents to their respective Folders,
    // and delete those that doesn't match.

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] folderEntity];

    NSError *error = nil;
    NSArray *folders = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    fetchRequest.entity = [[SHCModelManager sharedManager] documentEntity];

    error = nil;
    NSArray *documents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    NSMutableArray *remainingDocuments = [NSMutableArray arrayWithArray:documents];

    for (SHCDocument *document in documents) {
        for (SHCFolder *folder in folders) {
            if ([document.location compare:folder.name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [folder addDocumentsObject:document];

                [remainingDocuments removeObject:document];
            }
        }
    }

    // Delete all remaining documents that we couldn't match
    for (SHCDocument *document in remainingDocuments) {
        [managedObjectContext deleteObject:document];
    }
}

+ (NSArray *)allDocumentsInFolderWithName:(NSString *)folderName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [[SHCModelManager sharedManager] documentEntity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                              [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(folder)), NSStringFromSelector(@selector(name))],
                              folderName];

    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [[SHCModelManager sharedManager] logExecuteFetchRequestWithError:error];
    }

    return results;
}

+ (NSString *)stringForDocumentDate:(NSDate *)date
{
    NSDate *nowDate = [NSDate date];

    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date toDate:nowDate options:0];

    if (dateComponents.day > 6) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;

        return [dateFormatter stringFromDate:date];
    } else if (dateComponents.day > 1) {
        NSDateFormatter *weekdayDateFormatter = [[NSDateFormatter alloc] init];
        weekdayDateFormatter.dateFormat = @"EEEE";

        return [weekdayDateFormatter stringFromDate:date];
    } else if (dateComponents.day == 1) {
        return NSLocalizedString(@"GENERIC_YESTERDAY_TITLE", @"Yesterday");
    } else {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];

        return [timeIntervalFormatter stringForTimeIntervalFromDate:nowDate toDate:date];
    }
}

- (SHCAttachment *)mainDocumentAttachment
{
    SHCAttachment *mainDocumentAttachment = nil;

    for (SHCAttachment *attachment in self.attachments) {
        if ([attachment.mainDocument boolValue]) {
            mainDocumentAttachment = attachment;
            break;
        }
    }

    return mainDocumentAttachment;
}

- (void)updateWithAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSString *createdAtString = attributes[kDocumentCreatedAtAPIKey];
    if ([createdAtString isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";

        self.createdAt = [dateFormatter dateFromString:createdAtString];
    }

    NSString *creatorName = attributes[NSStringFromSelector(@selector(creatorName))];
    self.creatorName = [creatorName isKindOfClass:[NSString class]] ? creatorName : nil;

    NSString *location = attributes[NSStringFromSelector(@selector(location))];
    self.location = [location isKindOfClass:[NSString class]] ? [location lowercaseString] : nil;

    self.deleteUri = nil;
    self.updateUri = nil;

    NSArray *links = attributes[kDocumentLinkAPIKey];
    if ([links isKindOfClass:[NSArray class]]) {
        for (NSDictionary *link in links) {
            if ([link isKindOfClass:[NSDictionary class]]) {
                NSString *rel = link[@"rel"];
                NSString *uri = link[@"uri"];
                if ([rel isKindOfClass:[NSString class]] && [uri isKindOfClass:[NSString class]]) {

                    if ([rel hasSuffix:kDocumentDeleteDocumentAPIKey]) {
                        self.deleteUri = uri;
                    } else if ([rel hasSuffix:kDocumentUpdateDocumentAPIKey]) {
                        self.updateUri = uri;
                    }
                }
            }
        }
    }
}

@end
