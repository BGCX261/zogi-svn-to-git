include <LSFoundation/LSDBObjectNewCommand.h>

@class NSString;

@interface LSNewJournalEntryCommand : LSDBObjectNewCommand
{
@private
  NSMutableString *_text;
}
@end

#include "common.h"

@implementation LSNewJournalEntryCommand


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

- (void)_prepareForExecutionInContext:(id)_context {

  id account   = [_context valueForKey:LSAccountKey];
  [self takeValue:[account valueForKey:@"companyId"]] forKey:@"companyId"];
  [self takeValue:[NSCalendarDate date] forKey:@"creationDate"];
  [self takeValue:[self _entryText] forKey:@"entryText"];
  [super _prepareForExecutionInContext:_context];
  // obj = [self object];
  // [obj takeValue:[self _entryText] forKey:@"entryText"];
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
