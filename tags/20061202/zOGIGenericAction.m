/*
  zOGIGenericAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIAction.h"
#include "NSObject+zOGI.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Enterprise.h"
#include "zOGIAction+Project.h"
#include "zOGIAction+Resource.h"
#include "zOGIAction+Task.h"
#include "zOGIAction+Account.h"
#include "zOGIAction+Team.h"
#include "common.h"

/*
  zOGI Generic Action
*/
@interface zOGIGenericAction : zOGIAction
{
}
@end

@implementation zOGIGenericAction

- (void)dealloc {
  [super dealloc];
}

/* methods */

-(id)getTypeOfObjectAction {
  [self logWithFormat:@"getTypeForObjectIdAction(%@)", arg1];
  return [self _getEntityNameForPKey:[self arg1]];
  //return [self arg];
}

-(id)flagFavoritesAction {
  NSArray      *objectList;
  NSEnumerator *enumerator;
  id            objectId;

  if (![arg1 isKindOfClass:[NSArray class]])
    objectList = [NSArray arrayWithObject:arg1];
   else 
     objectList = arg1;
  enumerator = [objectList objectEnumerator];
  while ((objectId = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Project"])
      [self _favoriteProject:objectId];
     else if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Enterprise"])
        [self _favoriteEnterprise:objectId];
       else if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Person"])
         [self _favoriteContact:objectId];
   }
  return nil;
}

-(id)unflagFavoritesAction {
  NSArray      *objectList;
  NSEnumerator *enumerator;
  id            objectId;

  if (![arg1 isKindOfClass:[NSArray class]])
    objectList = [NSArray arrayWithObject:arg1];
   else 
     objectList = arg1;
  enumerator = [objectList objectEnumerator];
  while ((objectId = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Project"])
      [self _unfavoriteProject:objectId];
     else if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Enterprise"])
        [self _unfavoriteEnterprise:objectId];
       else if ([[self _getEntityNameForPKey:objectId] isEqualToString:@"Person"])
         [self _unfavoriteContact:objectId];
   }
  return nil;
}

-(id)getObjectsByObjectIdAction {
  
  NSArray    	  *objectList;
  NSMutableArray  *result;
  NSEnumerator    *enumerator;
  NSString        *entityName;
  id              objectId;

  [self logWithFormat:@"getObjectsByObjectId(%@, %@)", arg1, arg2];
  if (![arg1 isKindOfClass:[NSArray class]])
    objectList = [NSArray arrayWithObject:arg1];
   else 
     objectList = arg1;
  enumerator = [objectList objectEnumerator];
  result = [[NSMutableArray alloc] initWithCapacity:[objectList count]];
  while ((objectId = [enumerator nextObject]) != nil) {
    [self logWithFormat:@"getObjectsByObjectId(...):objectId is a %@", [objectId class]];
    entityName = [self _getEntityNameForPKey:objectId];
    [self logWithFormat:@"getObjectsByObjectId(...):%@ is a %@", objectId, entityName];
    if ([entityName isEqualToString:@"Date"]) {
	  [result addObject:[self _getDateForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"Enterprise"]) {
         [result addObject:[self _getEnterpriseForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"Person"]) {
         [result addObject:[self _getContactForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"Job"]) {
         [result addObject:[self _getTaskForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"Team"]) {
         [result addObject:[self _getTeamForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"Project"]) {
         [result addObject:[self _getProjectForKey:objectId withDetail:arg2]];
     } else if ([entityName isEqualToString:@"appointmentResource"]) {
         [result addObject:[self _getResourceForKey:objectId withDetail:arg2]];
        }
    [self logWithFormat:@"%@ %@ loaded", entityName, objectId];
   }
  return result;
}

-(id)getObjectByObjectIdAction {
  NSDictionary  *result;
  NSString      *entityName;

  [self logWithFormat:@"getObjectByObjectId(%@, %@)", arg1, arg2];
  entityName = [self _getEntityNameForPKey:arg1];
  if ([entityName isEqualToString:@"Date"])
    result = [self _getDateForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"Enterprise"])
    result = [self _getEnterpriseForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"Person"])
    result = [self _getContactForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"Job"])
    result = [self _getTaskForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"Team"])
    result = [self _getTeamForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"Project"])
    result = [self _getProjectForKey:arg1 withDetail:arg2];
  else if ([entityName isEqualToString:@"appointmentResource"])
    result = [self _getResourceForKey:arg1 withDetail:arg2];
  return result;
}

-(id)getObjectVersionsByObjectIdAction {
  NSArray    	  *objectList;
  NSMutableArray  *result;
  NSEnumerator    *enumerator;
  NSNumber        *version;
  id              objectId;
  id              document;

  [self logWithFormat:@"getObjectVersionsByObjectId(%@, %@)", arg1, arg2];
  if (![arg1 isKindOfClass:[NSArray class]])
    objectList = [NSArray arrayWithObject:arg1];
   else 
     objectList = arg1;
  enumerator = [objectList objectEnumerator];
  result = [[NSMutableArray alloc] initWithCapacity:[objectList count]];
  while ((objectId = [enumerator nextObject]) != nil) {
    document = [[self getCTX] runCommand:@"object::get-by-globalid", 
                                         @"gid", [self _getEOForPKey:objectId], 
                                         nil];
    if (document != nil) {
      version = [document valueForKey:@"objectVersion"];
      if (version != nil) {
        [result addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             objectId, @"objectId", 
                             version, @"version",
                             nil]];
       } // End If version is not nil
     } // End if document is not nil
   } // End while nextObject
  return result;
}

- (id)putObjectAction { 
  NSString      *objectId;

  [self logWithFormat:@"====================================================="];
  [self logWithFormat:@"putObject(%@)", arg1];
  [self logWithFormat:@"====================================================="];

  // Determine objectId
  objectId = [arg1 objectForKey:@"objectId"];
  if (objectId == nil)
    objectId = [NSString stringWithString:@"0"];
  else if ([objectId isKindOfClass:[NSNumber class]])
    objectId = [objectId stringValue];
  [self logWithFormat:@"putObject(...):objectId=%s", objectId];

  if ([objectId isEqualToString:@"0"]) {
    // We are creating an object
   [self logWithFormat:@"putObject(...):create"];
    return [self _createObject:arg1];
  } else {
      // We are updating an existing object (present non-zero objectId)
      [self logWithFormat:@"putObject(...):update"];
      return [self _updateObject:arg1 objectId:objectId];
     }
} // End putObjectAction

- (id)searchForObjectsAction {

  [self logWithFormat:@"===================================================="];
  [self logWithFormat:@"searchForObjects(%@, %@, %@)", arg1, arg2, arg3];
  [self logWithFormat:@"===================================================="];
  if ([arg1 isEqualToString:@"Person"])
    return [self _searchForContacts:arg2 withDetail:arg3];
  else if ([arg1 isEqualToString:@"Enterprise"])
    return [self _searchForEnterprises:arg2 withDetail:arg3];
  //return AUTORELEASE([NSNumber numberWithBool:NO]);
  return [NSNumber numberWithBool:NO];
}

- (id)_createObject:(NSDictionary *)dictionary {
  NSString      *entityName;

  entityName = [arg1 objectForKey:@"entityName"];
  if ([entityName isEqualToString:@"Task"])
    return [self _createTask:dictionary];
  return nil;
}

- (id)_updateObject:(NSDictionary *)dictionary objectId:(NSString *)objectId {
  NSString      *entityName;

  entityName = [arg1 objectForKey:@"entityName"];
  if ([entityName isEqualToString:@"Task"])
    return [self _updateTask:dictionary objectId:objectId];
  return nil;
}

@end
