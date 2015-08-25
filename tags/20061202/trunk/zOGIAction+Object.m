/*
  zOGIAction+Object.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include <LSFoundation/OGoObjectLinkManager.h>
#include <LSFoundation/OGoObjectLink.h>
#include "zOGIAction.h"
#include "zOGIAction+Object.h"

@implementation zOGIAction(Object)

-(NSDictionary *)_getObjectProperties:(id)_arg {
  return nil;
}

-(id)_storeProperties:(id)_pk withValues:(NSDictionary *)_values {
  return nil;
}

-(void)_addObjectDetails:(NSMutableDictionary *)_object withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"----_addObjectDetails(...)-------<start>----"];
  if([_detail intValue] > 0) {
    if([_detail intValue] & zOGI_INCLUDE_OBJLINKS)
      [self _addLinksToObject:_object];
    if([_detail intValue] & zOGI_INCLUDE_PROPERTIES)
      [self _addPropertiesToObject:_object];
    if([_detail intValue] & zOGI_INCLUDE_LOGS)
      [self _addLogsToObject:_object];
   }
  [self logWithFormat:@"----_addObjectDetails(...)-------<end>----"];
}

-(void)_addLinksToObject:(NSMutableDictionary *)_object {
  NSMutableArray      *linkList;
  NSArray             *links;
  NSEnumerator        *enumerator;
  EOGlobalID          *eo;
  id                  *link;

  [self logWithFormat:@"----_addLinksToObject(...)-------<start>----"];
  eo = [self _getEOForPKey:[_object valueForKey:@"objectId"]];
  linkList = [NSMutableArray new];
  //links = [[[self getCTX] linkManager] allLinksTo:eo type:@"generic"];
  links = [[[self getCTX] linkManager] allLinksTo:eo];
  if (links != nil) {
    [self logWithFormat:@"_addLinksToObject(...), %d links found", [links count]];
    enumerator = [links objectEnumerator];
    while ((link = [enumerator nextObject]) != nil) {
      [self logWithFormat:@"_addLinksToObject(...); link = %@", [link globalID]];
      [linkList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         @"to", @"direction",
         [self _getPKeyForEO:[link globalID]], @"objectId",
         [self _getEntityNameForPKey:[link globalID]], @"entityName",
         [self _getPKeyForEO:[link sourceGID]], @"sourceObjectId",
         [self _getEntityNameForPKey:[link sourceGID]], @"sourceEntityName",
         [self NIL:[link linkType]], @"type",
         [self NIL:[link label]], @"label",
         nil]];  
     }
   }
  //links = [[[self getCTX] linkManager] allLinksFrom:eo type:@"generic"];
  links = [[[self getCTX] linkManager] allLinksFrom:eo];
  if (links != nil) {
    [self logWithFormat:@"_addLinksToObject(...), %d links found", [links count]];
    enumerator = [links objectEnumerator];
    while ((link = [enumerator nextObject]) != nil) {
      [self logWithFormat:@"_addLinksToObject(...); link = %@", [link globalID]];
      [linkList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         @"from", @"direction",
         [self _getPKeyForEO:[link globalID]], @"objectId",
         [self _getEntityNameForPKey:[link globalID]], @"entityName",
         [self _getPKeyForEO:[link targetGID]], @"targetObjectId",
         [self _getEntityNameForPKey:[link targetGID]], @"targetEntityName",
         [self NIL:[link linkType]], @"type",
         [self NIL:[link label]], @"label",
         nil]];  
     }
   }
  [_object setObject:linkList forKey:@"_OBJECTLINKS"];
  [self logWithFormat:@"----_addLinksToObject(...)-------<end>----"];
}

-(NSString *)_takeNamespaceFromProperty:(NSString *)_property {
  //NSString      *namespace;

  return [[[_property componentsSeparatedByString:@"}"] objectAtIndex:0] substringFromIndex:1];
}

-(NSString *)_takeAttributeFromProperty:(NSString *)_property {
  //NSString      *namespace;

  return [[_property componentsSeparatedByString:@"}"] objectAtIndex:1];
}


-(void)_addPropertiesToObject:(NSMutableDictionary *)_object {
  NSMutableArray *propertyList;
  NSDictionary   *properties;
  NSEnumerator   *enumerator;
  NSString       *key;
  EOGlobalID     *eo;

  [self logWithFormat:@"----_addPropertiesToObject(...)-------<start>----"];
  eo = [self _getEOForPKey:[_object valueForKey:@"objectId"]];
  properties = [[[self getCTX] propertyManager] propertiesForGlobalID: eo];
  propertyList = [[NSMutableArray alloc] initWithCapacity:6];
  enumerator = [properties keyEnumerator];
  while ((key = [enumerator nextObject]) != nil) {
    [propertyList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
       key, @"property",
       [self _takeNamespaceFromProperty:key], @"namespace",
       [self _takeAttributeFromProperty:key] , @"attribute",
       [self NIL:[properties valueForKey:key]], @"value",
       @"objectProperty", @"entityName",
       nil]];
   }
  [_object setObject:propertyList forKey:@"_PROPERTIES"];
  [self logWithFormat:@"----_addPropertiesToObject(...)-------<end>----"];
}

-(void)_addLogsToObject:(NSMutableDictionary *)_object {
  EOGlobalID      *eo;
  id              object;
  NSArray         *logs;
  NSMutableArray  *logEntries;
  NSDictionary    *logEntry;
  NSEnumerator    *enumerator;
 
  [self logWithFormat:@"----_addLogsToObject(...)-------<start>----"];
  eo = [self _getEOForPKey:[_object valueForKey:@"objectId"]];
  object = [[[self getCTX] runCommand:@"object::get-by-globalid",
                                     @"gid", eo,
                                     nil] lastObject];
  logs = [[self getCTX] runCommand:@"object::get-logs", 
                                   @"object", object,
                                   nil];
  logEntries = [[NSMutableArray alloc] initWithCapacity:[logs count]];
  enumerator = [logs objectEnumerator];
  while((logEntry = [enumerator nextObject]) != nil) {
    [logEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys:
       [logEntry valueForKey:@"logId"], @"objectId",
       @"logEntry", @"entityName",
       [logEntry valueForKey:@"creationDate"], @"actionDate",
       [self NIL:[logEntry valueForKey:@"logText"]], @"message",
       [logEntry valueForKey:@"action"], @"action",
       [logEntry valueForKey:@"accountId"], @"actorObjectId",
       nil]];
   }
  [_object setObject:logEntries forKey:@"_LOGS"];
  [self logWithFormat:@"----_addLogsToObject(...)-------<end>----"];
}

@end
