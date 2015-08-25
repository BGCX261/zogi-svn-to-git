#include <LSFoundation/LSGetObjectForGlobalIDs.h>

@interface LSGetJournalEntriesForGlobalIDs : LSGetObjectForGlobalIDs
@end

#include <LSFoundation/LSCommandKeys.h>
#import <Foundation/Foundation.h>
#import <EOControl/EOControl.h>
#import <GDLAccess/GDLAccess.h>

@implementation LSGetJournalEntriesForGlobalIDs

- (NSString *)entityName {
  return @"JournalEntry";
}

- (void)fetchAdditionalInfosForObjects:(NSArray *)_objs context:(id)_context { 
}

@end
