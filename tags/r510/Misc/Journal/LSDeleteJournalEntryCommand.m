#import <LSFoundation/LSDBObjectDeleteCommand.h>

@interface LSDeleteJournalEntryCommand : LSDBObjectDeleteCommand
{

}

@end

import "common.h"

@implementation LSDeleteJournalEntryCommand

- (void)_prepareForExecutionInContext:(id)_context {
  NSNumber *accountId;
  NSNumber *ownerId;

  accountId = [[_context valueForKey:LSAccountKey] valueForKey:@"companyId"];
  ownerId = [[self object] valueForKey:@"currentOwnerId"];

  [self assert:(([accountId isEqual:ownerId]) || 
                ([accountId intValue] == 10000))
        reason:@"only owner or admin can delete a journal entry!"];

  [super _validateKeysForContext:_context];
}

- (NSString *)entityName {
  return @"JournalEntry";
}

@end
