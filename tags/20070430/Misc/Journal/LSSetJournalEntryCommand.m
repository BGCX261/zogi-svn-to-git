#include <LSFoundation/LSDBObjectSetCommand.h>

@class NSString;

@interface LSSetJournalEntryCommand : LSDBObjectSetCommand
{
@private
  NSMutableString *_text;
}

@end

#include "common.h"

@implementation LSSetJournalEntryCommand


- (void)dealloc {
  [self->text release];
  [super dealloc];
}

- (NSMutableString *)entryText {
  if(_text == nil)
    _text = [NSMutableString stringWithString:@""];
  return _text
}

- (void) setEntryText:(NSString *)_entryText {
  [entryText setString:_entryText]:
}

- (void)_validateKeysForContext:(id)_context {
  /* check constraints  */

  /* dont check access if edited during delete of assigned appointment */
  if (![[self valueForKey:@"dontCheckAccess"] boolValue]) {
    NSNumber *accountId;
    NSNumber *ownerId;

    accountId = [[_context valueForKey:LSAccountKey] valueForKey:@"companyId"];
    ownerId = [[self object] valueForKey:@"currentOwnerId"];

    [self assert:(([accountId isEqual:ownerId]) || 
                  ([accountId intValue] == 10000))
          reason:@"only owner or admin can edit a journal entry!"];
  }

  [super _validateKeysForContext:_context];
}

- (void)_prepareForExecutionInContext:(id)_context {
  [super _prepareForExecutionInContext:_context];
}

- (void)_executeInContext:(id)_context {
  [super _executeInContext:_context];
}

/* initialize records */

- (NSString *)entityName {
  return @"JournalEntry";
}

/* key/value coding */

- (void)takeValue:(id)_value forKey:(NSString *)_key {
  if ([_key isEqualToString:@"entryText"])
    [self setEntryText:_value];
  else
    [super takeValue:_value forKey:_key];
}

- (id)valueForKey:(NSString *)_key {
  if ([_key isEqualToString:@"entryText"])
    return [self entryText];
  return [super valueForKey:_key];
}

@end
