/*
  zOGIACLAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIACLAction.h"
#include "NSObject+zOGI.h"
#include "common.h"


@implementation zOGIACLAction

- (void)dealloc {
  [super dealloc];
}

/* accessors */

/* methods */

- (id)_getACLsForDate:(EOGlobalID *)_arg {
  NSDictionary        *appointment;
  NSArray             *writers;
  NSString            *writer, *reader;
  id                  writerList;
  NSMutableDictionary *result, *acl;
  NSEnumerator        *enumerator;

  [self logWithFormat:@"called zOGI::_getACLsForDate"];
  result = [NSMutableDictionary new];
  appointment = [[self getCTX] runCommand:@"appointment::get-by-globalid",
                                          @"gid", _arg,
                                          @"timeZone", [self _getTimeZone],
                                          nil];
  reader = [[appointment objectForKey:@"accessTeamId"] stringValue]; 
  writerList = [appointment objectForKey:@"writeAccessList"];
  if (![writerList isKindOfClass:[NSNull class]]) {
    writers = [writerList componentsSeparatedByString:@","];
    enumerator = [writers objectEnumerator];
    while ((writer = [enumerator nextObject]) != nil) {
      acl = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               [self _getEntityNameForPKey:writer], @"entityName",
               [writer stringValue], @"objectId",
               @"true", @"write",
               nil];    
      if ([writer isEqualToString:reader]) {
        [acl setObject:@"true" forKey:@"read"];
        reader = nil;
       } else
           [acl setObject:@"false" forKey:@"read"];
      [result setObject:acl forKey:[writer stringValue]];
     }
   } /* end ([writerList is null count] > 0) */
  if (reader != nil) {
    acl = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             @"Team", @"entityName",
             [reader stringValue], @"objectId",
             @"false", @"write",
             @"true", @"read",
             nil]; 
    [result setObject:acl forKey:[reader stringValue]]; 
   }
  return result;
}

- (id)_getACLsForCompany:(EOGlobalID *)_arg {
  NSDictionary		  *access;
  NSMutableDictionary *result, *acl;
  NSEnumerator        *enumerator;
  EOKeyGlobalID       *eoID;
  NSString            *rights;

  [self logWithFormat:@"called zOGI::_getACLsForCompany"];
  access = [[[self getCTX] accessManager] allowedOperationsForObjectId:_arg];
  result = [NSMutableDictionary new];
  if ([access count] == 0) {
    return [acl autorelease];
   }
  enumerator = [[access allKeys] objectEnumerator];
  while((eoID = [enumerator nextObject]) != nil) {
    acl = nil;
    rights = [NSString stringWithString:[access objectForKey:eoID]];
    acl = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             [self _getEntityNameForPKey:eoID], @"entityName",
             [self _getPKeyForEO:eoID], @"objectId",
             nil];
    if ([rights containsString:@"r"])
      [acl setObject:@"true" forKey:@"read"];
     else
       [acl setObject:@"false" forKey:@"read"];
    if ([rights containsString:@"w"])
      [acl setObject:@"true" forKey:@"write"];
     else
       [acl setObject:@"false" forKey:@"write"];
    [result setObject:acl forKey:[self _getPKeyForEO:eoID]];
   }
  return result;
}

- (id)getACLsForObjectIdAction {
  NSArray                 *eoIDs;
  NSMutableDictionary     *result;
  NSDictionary            *acl;
  int                     i;
  NSString                *pkey, *entityName;
  
  [self logWithFormat:@"called zOGI::getACLsForObjectId"];
  eoIDs = [self _getEOsForPKeys:[self arg1]];  
  result = [NSMutableDictionary new];
  //acls = [[[self getCTX] accessManager] allowedOperationsForObjectIds:eoIDs];
  for (i = 0; i < [eoIDs count]; i++ ) {
     entityName = [self _getEntityNameForPKey:[eoIDs objectAtIndex:i]];
     pkey = [self _getPKeyForEO:[eoIDs objectAtIndex:i]];
     acl = nil;
     if ([entityName isEqualToString:@"Date"]) {
         /* Date */
         acl = [NSDictionary dictionaryWithObjectsAndKeys:
                  entityName, @"entityName",
                  pkey, @"objectId",
                  [self _getACLsForDate:[eoIDs objectAtIndex:i]], @"acls",
                  nil];
        } else if ([entityName isEqualToString:@"Person"] ||
                   [entityName isEqualToString:@"Enterprise"]) {
            /* Company - Person or Enterprise */
            acl = [NSDictionary dictionaryWithObjectsAndKeys:
                     entityName, @"entityName",
                     pkey, @"objectId",
                     [self _getACLsForCompany:[eoIDs objectAtIndex:i]], @"acls",
                     nil];
           } else {
               /* Other type of object */
               acl = [NSDictionary dictionaryWithObjectsAndKeys:
                        entityName, @"entityName",
                        pkey, @"objectId",
                        nil];
              }
      if (acl != nil)
        [result setObject:acl forKey:pkey];
   } /* end for eoIDs count */

  return [result autorelease];
}

/*  arg1 = operation  - String
    arg2 = target(s) - String or array
    arg3 = client - String or number or absent
    Can {arg1} be performed {arg2} by {arg3}? 
    If {arg3} is no supplied current user is assumed 
    TODO: Needs to deal with non-company objects */
- (id)checkOperationPermittedAction {
  NSArray      *eoIDs;
  BOOL         access;
  
  /* Make array of eoIDs from arg2 */
  eoIDs = [self _getEOsForPKeys:arg2];

  /* Setup arg3, client */
  if (![arg3 isNotNull]) 
    arg3 = [[[self getCTX] valueForKey:LSAccountKey] globalID];
   else
     arg3 = [self _getEOForPKey:[self arg3]];
  
  access = [[[self getCTX] accessManager] 
                             operation:arg1
                             allowedOnObjectIDs:eoIDs
                             forAccessGlobalID:arg3];

  return [NSNumber numberWithBool:access];
 }

/*  arg1 = operations  - String or Dictionary
    arg2 = target - String or number
    arg3 = client - String or number or absent
    Can {arg1} be performed {arg2} by {arg3}? 
    If {arg3} is no supplied current user is assumed 
    TODO: Needs to deal with non-company objects */
- (id)setPermittedOperationAction {
  id         access;
  
  /* Make array of eoIDs from arg2 */
  arg2 = [self _getEOForPKey:arg2];

  /* Setup arg3, client */
  if (![arg3 isNotNull]) 
    arg3 = [[[self getCTX] valueForKey:LSAccountKey] globalID];
   else
     arg3 = [self _getEOForPKey:[self arg3]];

  if ([[self _getEntityNameForPKey:arg2] isEqualToString:@"Date"]) {
    /* Target is a date */
   } else if ([[self _getEntityNameForPKey:arg2] isEqualToString:@"Person"] ||
              [[self _getEntityNameForPKey:arg2] isEqualToString:@"Enterprise"]) {
       /* Assuming it is a company object */
       access = [[[self getCTX] accessManager] 
                                  setOperation:arg1
                                  onObjectId:arg2
                                  forAccessGlobalID:arg3];
      } else access = [NSNumber numberWithBool:NO];

  return access;
 }
@end
