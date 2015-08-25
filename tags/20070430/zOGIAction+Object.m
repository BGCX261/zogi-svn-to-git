/*
  zOGIAction+Object.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include <LSFoundation/OGoObjectLinkManager.h>
#include <LSFoundation/OGoObjectLink.h>
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Property.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+Team.h"
#include "zOGIAction+Enterprise.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Task.h"
#include "zOGIAction+Project.h"
#include "zOGIAction+Resource.h"
#include "zOGIAction+Document.h"

@implementation zOGIAction(Object)

-(NSDictionary *)_getObjectByObjectId:(id)_objectId withDetail:(NSNumber *)_detail {
  NSDictionary  *result;
  NSString      *entityName;

  [self logWithFormat:@"_getObjectByObjectId(%@, %@)", _objectId, _detail];
  result = nil;
  entityName = [self _getEntityNameForPKey:_objectId];
  if ([entityName isEqualToString:@"Date"])
    result = [self _getDateForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Enterprise"])
    result = [self _getEnterpriseForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Person"])
    result = [self _getContactForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Job"])
    result = [self _getTaskForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Team"])
    result = [self _getTeamForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Project"])
    result = [self _getProjectForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"AppointmentResource"])
    result = [self _getResourceForKey:_objectId withDetail:_detail];
  else if ([entityName isEqualToString:@"Doc"])
    result = [self _getDocumentForKey:_objectId withDetail:_detail];
  [self logWithFormat:@"_getObjectByObjectId; complete"];
  if (result != nil)
    return result;
   else
     return [self _makeUnknownObject:(id)_objectId];
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
  [self _stripInternalKeys:_object];
  [self logWithFormat:@"----_addObjectDetails(...)-------<end>----"];
}

-(void)_addLinksToObject:(NSMutableDictionary *)_object {
  NSMutableArray      *linkList;
  NSArray             *links;
  NSEnumerator        *enumerator;
  EOGlobalID          *eo;
  id                  link;

  eo = [self _getEOForPKey:[_object valueForKey:@"objectId"]];
  linkList = [NSMutableArray new];
  links = [[[self getCTX] linkManager] allLinksTo:(id)eo];
  if (links != nil) {
    enumerator = [links objectEnumerator];
    while ((link = [enumerator nextObject]) != nil) {
      [linkList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         @"to", @"direction",
         [self _getPKeyForEO:(id)[link globalID]], @"objectId",
         @"objectLink", @"entityName",
         [self _getPKeyForEO:(id)[link sourceGID]], @"sourceObjectId",
         [self _getPKeyForEO:(id)[link targetGID]], @"targetObjectId",
         [self _izeEntityName:[self _getEntityNameForPKey:[link sourceGID]]], @"sourceEntityName",
         [self _izeEntityName:[self _getEntityNameForPKey:[link targetGID]]], @"targetEntityName",
         [self NIL:[link linkType]], @"type",
         [self NIL:[link label]], @"label",
         nil]];  
     }
   }
  links = [[[self getCTX] linkManager] allLinksFrom:(id)eo];
  if (links != nil) {
    enumerator = [links objectEnumerator];
    while ((link = (id)[enumerator nextObject]) != nil) {
      [linkList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         @"from", @"direction",
         [self _getPKeyForEO:(id)[link globalID]], @"objectId",
         @"objectLink", @"entityName",
         [self _getPKeyForEO:(id)[link targetGID]], @"targetObjectId",
         [self _getPKeyForEO:(id)[link sourceGID]], @"sourceObjectId",
         [self _izeEntityName:[self _getEntityNameForPKey:[link targetGID]]], @"targetEntityName",
         [self _izeEntityName:[self _getEntityNameForPKey:[link sourceGID]]], @"sourceEntityName",
         [self NIL:[link linkType]], @"type",
         [self NIL:[link label]], @"label",
         nil]];  
     }
   }
  [_object setObject:linkList forKey:@"_OBJECTLINKS"];
}

-(void)_addLogsToObject:(NSMutableDictionary *)_object {
  EOGlobalID      *eo;
  id              object;
  NSArray         *logs;
  NSMutableArray  *logEntries;
  NSDictionary    *logEntry;
  NSEnumerator    *enumerator;
 
  [self logWithFormat:@"_addLogsToObject()"];
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
       [_object valueForKey:@"objectId"], @"entityObjectId",
       nil]];
   }
  [_object setObject:logEntries forKey:@"_LOGS"];
}

/*
  _saveObjectLinks syncronizes the list of object lists provided in _links
  with the Object Links present in the OpenGroupware database.  If _links 
  is NIL then no operations are performed.  Only the links *FROM* the
  _objectId specified are syncronized; object links must be modified from 
  the source.
 */
-(NSException *)_saveObjectLinks:(NSArray *)_links forObject:(NSString *)_objectId {
  NSEnumerator        *clientEnumerator, *serverEnumerator;
  NSDictionary        *clientLink;
  NSArray             *serverLinks;
  id                  linkManager, objectLink, serverLink;
  NSString            *linkPK;
  int                 match;

  [self logWithFormat:@"_saveObjectLinks(%@)", [_links class]];
  linkManager = [[self getCTX] linkManager];
  if (_links == nil) {
    [self logWithFormat:@"_saveObjectLinks(); no links to save"];
    return nil;
   }
  if ([_links count] == 0) {
    [self logWithFormat:@"_saveObjectLinks(); no links; delete all!"];
    [linkManager deleteLinksFrom:(id)[self _getEOForPKey:_objectId]
                            type:[NSString stringWithString:@""]];             
    return nil;
   }
  serverLinks = [linkManager allLinksFrom:(id)[self _getEOForPKey:_objectId]];
  // Check for links to create (objectId = 0)
  clientEnumerator = [_links objectEnumerator];
  while ((clientLink = [clientEnumerator nextObject]) != nil) {
    if ([[clientLink objectForKey:@"objectId"] isEqualToString:@"0"]) {
      [self logWithFormat:@"_saveObjectLinks(); create link to %@", 
          [clientLink objectForKey:@"targetObjectId"]];
      [linkManager createLink:[self _translateObjectLink:clientLink
                                              fromObject:_objectId]];
     } // End objectId == 0
   } // End while clientLink = [clientEnumerator nextObject]
  //[clientEnumerator release];
  /* Loop through links on server to finds ones modified by client
     or removed by the client;  if the client provided _OBJECTLINKS on
     and object put then we assume that links no longer provided should
     be deleted. */
  serverEnumerator = [serverLinks objectEnumerator];
  while ((serverLink = [serverEnumerator nextObject]) != nil) {
    linkPK = [self _getPKeyForEO:(id)[serverLink globalID]];
    match = 0;
    clientEnumerator = [_links objectEnumerator];
    while ((clientLink = [clientEnumerator nextObject]) != nil) {
      if ([linkPK isEqualToString:[clientLink objectForKey:@"objectId"]]) {
        objectLink = (OGoObjectLink *)[self _translateObjectLink:clientLink
                                                      fromObject:_objectId];
        match = 1;
        if (!([objectLink isEqualToObjectLink:serverLink])) {
          // This link exists but the client has changed something
          // Replace the link on the server; links cannot be updated
          [linkManager deleteLink:serverLink];
          [linkManager createLink:objectLink];
         } // End if !([clientLink isEqualToObjectLink:serverLink])
       } // End if serverLink is clientLink
     } // End while clientLink = [clientEnumerator nextObject]
    if (match == 0)
      [linkManager deleteLink:serverLink];
   } // End while serverLink = [serverEnumerator nextObject]
  return nil;
} // End _saveObjectLinks

/*
  _translateObjectLink turns the _link ObjectLink dictionary into
  a OGoObjectLink object.  OGoObjectLink is the object used by the
  OpenGroupware logic layer to represent an Object Link.
 */
-(id)_translateObjectLink:(NSDictionary *)_link fromObject:(id)_objectId {
  id objectLink;
  EOGlobalID   *sourceEO, *targetEO;

  sourceEO = [self _getEOForPKey:_objectId];
  targetEO = [self _getEOForPKey:[_link objectForKey:@"targetObjectId"]];
  objectLink = [[OGoObjectLink alloc] initWithSource:(id)sourceEO 
                   target:(id)targetEO
                   type:[_link objectForKey:@"type"]
                   label:[_link objectForKey:@"label"]];
  return objectLink;
}

-(NSDictionary *)_makeUnknownObject:(id)_objectId {
  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"Unknown", @"entityName",
    _objectId, @"objectId",
    nil];
}

@end
