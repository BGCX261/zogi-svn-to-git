/*
  zOGIAction+Enterprise.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006, 2007
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Company.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Enterprise.h"
#include "zOGIAction+Assignment.h"

@implementation zOGIAction(Enterprise)

-(NSArray *)_renderEnterprises:(NSArray *)_enterprises
                    withDetail:(NSNumber *)_detail 
{
  NSMutableArray      *result;
  EOGenericRecord     *eoEnterprise;
  int                  count;

  result = [NSMutableArray arrayWithCapacity:[_enterprises count]];
  for (count = 0; count < [_enterprises count]; count++) 
  {
    eoEnterprise = [_enterprises objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       eoEnterprise, @"*eoObject",
       [eoEnterprise valueForKey:@"companyId"], @"objectId",
       @"Enterprise", @"entityName",
       [eoEnterprise valueForKey:@"objectVersion"], @"version",
       [eoEnterprise valueForKey:@"ownerId"], @"ownerObjectId",
       [self NIL:[eoEnterprise valueForKey:@"associatedCategories"]], @"associatedCategories",
       [self NIL:[eoEnterprise valueForKey:@"associatedContacts"]], @"associatedContacts",
       [self NIL:[eoEnterprise valueForKey:@"associatedCompany"]], @"associatedCompany",
       [self NIL:[eoEnterprise valueForKey:@"bank"]], @"bank",
       [self NIL:[eoEnterprise valueForKey:@"bankCode"]], @"bankCode",
       [self NIL:[eoEnterprise valueForKey:@"fileas"]], @"fileAs",
       //[self NIL:[eoEnterprise valueForKey:@"isPrivate"]], @"",
       [self NIL:[eoEnterprise valueForKey:@"keywords"]], @"keywords",
       [self NIL:[eoEnterprise valueForKey:@"description"]], @"name",
       [self NIL:[eoEnterprise valueForKey:@"url"]], @"url",
       [self NIL:[eoEnterprise valueForKey:@"imAddress"]], @"imAddress",
       [self NIL:[eoEnterprise valueForKey:@"email"]], @"email",
       nil]];
     [self _addAddressesToCompany:[result objectAtIndex:count]];
     [self _addPhonesToCompany:[result objectAtIndex:count]];
     /* Add flags */
     [[result objectAtIndex:count] 
         setObject:[self _renderCompanyFlags:eoEnterprise entityName:@"Enterprise"]
            forKey:@"FLAGS"];
     /* Add detail if required */
     if([_detail intValue] > 0) 
     {
       if([_detail intValue] & zOGI_INCLUDE_COMPANYVALUES)
         [self _addCompanyValuesToCompany:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_CONTACTS)
         [self _addContactsToEnterprise:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PROJECTS)
         [self _addProjectsToEnterprise:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
     } /* End detail-is-required */
     [self _stripInternalKeys:[result objectAtIndex:count]];
  } /* End rendering loop */
  return result;
} /* End _renderEnterprises */

-(NSArray *)_getUnrenderedEnterprisesForKeys:(id)_arg 
{
  NSArray       *enterprises;

  enterprises = [[[self getCTX] runCommand:@"enterprise::get-by-globalid",
                                           @"gids", [self _getEOsForPKeys:_arg],
                                           nil] retain];
  return enterprises;
} /* End _getUnrenderedEnterprisesForKeys */

/*
  Singular instance of _getUnrenderedEnterpriseForKey;  still returns an array
  however so that it can be used with methods that also handle bulk actions.
  This array is guaranteed to be single-valued.
 */
-(id)_getUnrenderedEnterpriseForKey:(id)_arg 
{
  return [[self _getUnrenderedEnterprisesForKeys:_arg] lastObject];
} /* End of _getUnrenderedEnterpriseForKeys */

-(id)_getEnterprisesForKeys:(id)_arg withDetail:(NSNumber *)_detail
{
  return [self _renderEnterprises:
            [self _getUnrenderedEnterprisesForKeys:_arg] withDetail:_detail];
}

-(id)_getEnterpriseForKeys:(id)_pk 
{
  return [self _getEnterprisesForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getEnterpriseForKey:(id)_pk withDetail:(NSNumber *)_detail 
{
  id               result;

  result = [self _getEnterprisesForKeys:_pk withDetail:_detail];
  if ([result isKindOfClass:[NSException class]])
    return result;
  if ([result isKindOfClass:[NSMutableArray class]])
    if([result count] == 1)
      return [result objectAtIndex:0];
  return nil;
}

-(id)_getEnterpriseForKey:(id)_pk 
{
  return [self _getEnterpriseForKey:_pk withDetail:[NSNumber numberWithInt:0]];
}

-(void)_addProjectsToEnterprise:(NSMutableDictionary *)_enterprise 
{
  NSArray             *projects;
  NSMutableArray      *projectList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  projects = [[self getCTX] runCommand:@"enterprise::get-project-assignments",
                                       @"withArchived", [NSNumber numberWithBool:YES],
                                       @"object", [_enterprise objectForKey:@"*eoObject"],
                                       nil];
  if (projects == nil) projects = [NSArray array];
  projectList = [NSMutableArray arrayWithCapacity:[projects count]];
  enumerator = [projects objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                  source:[eo valueForKey:@"companyId"]
                                  target:[eo valueForKey:@"projectId"]
                                      eo:eo];
    [projectList addObject:assignment];
  }
  [_enterprise setObject:projectList forKey:@"_PROJECTS"];
} /* End _addProjectsToEnterprise */

/* Add the _CONTACTS key to the enterprise */
-(void)_addContactsToEnterprise:(NSMutableDictionary *)_enterprise 
{
  NSArray             *assignments;
  NSMutableArray      *contactList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_enterprise key:@"companyId"];
  contactList = [NSMutableArray arrayWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                  source:[eo valueForKey:@"companyId"]
                                  target:[eo valueForKey:@"subCompanyId"]
                                      eo:eo];
    [contactList addObject:assignment];
  }
  [_enterprise setObject:contactList forKey:@"_CONTACTS"];
} /* End _addContactsToEnterprise */

/* Get the favorite enterprises at the specified detail level 
   TODO: Remove the clumsy creation of an empty array */
-(NSArray *)_getFavoriteEnterprises:(NSNumber *)_detail 
{
  NSArray      *favoriteIds;
  [self logWithFormat:@"_getFavoriteEnterprises()"];
  favoriteIds = [[self _getDefaults] arrayForKey:@"enterprise_favorites"];
  if (favoriteIds == nil)
    return [[NSArray alloc] initWithObjects:nil];
  return [self _getEnterprisesForKeys:favoriteIds withDetail:_detail];
} /* End _getFavoriteEnterprises */

-(id)_searchForEnterprises:(id)_query withDetail:(NSNumber *)_detail 
{
  NSArray         *results;

  results = [[self getCTX] runCommand:@"enterprise::qsearch"
                             @"qualifier", _query,
                             @"maxSearchCount", [NSNumber numberWithInt:25],
                             @"fetchGlobalIDs", [NSNumber numberWithBool:YES],
              nil];
  [self logWithFormat:@"_searchForEnterprise(%@)=%@", _query, results];
  return results;
} /* End _searchForEnterprises */

/*
  Delete an Enterprise
  Currently there are no supported flags, the value of flags is ignored
  TODO: Do we need to delete the fake project?
  TODO: Return exceptions
*/
-(id)_deleteEnterprise:(NSString *)_objectId
              withFlags:(NSArray *)_flags 
{
  id	eo;
  
  eo = [self _getUnrenderedEnterpriseForKey:_objectId];
  /* delete any company assignments */
  [self _savePersonsToEnterprise:[[NSArray alloc] init]
                        objectId:[eo objectForKey:@"companyId"]];
  [[self getCTX] runCommand:@"enterprise::delete",
                 @"object", eo,
                 @"reallyDelete", [NSNumber numberWithBool:YES],
                 nil];
  [[self getCTX] commit];
  return [NSNumber numberWithBool:YES];
} /* End _deleteEnterprise */

-(NSString *)_translateEnterpriseKey:(NSString *)_key 
{
  if ([_key isEqualToString:@"objectId"])
    return [NSString stringWithString:@"companyId"];
  else if ([_key isEqualToString:@"version"])
    return [NSString stringWithString:@"objectVersion"];
  else if ([_key isEqualToString:@"ownerObjectId"])
    return [NSString stringWithString:@"ownerId"];
  else if ([_key isEqualToString:@"name"])
    return [NSString stringWithString:@"description"];
  else if ([_key isEqualToString:@"fileAs"])
    return [NSString stringWithString:@"fileas"];
  return _key;
} /* End _translateEnterpriseKey */

/* Creates a new enterprise from the provided dictionary. */
-(id)_createEnterprise:(NSDictionary *)_enterprise
             withFlags:(NSArray *)_flags 
{
  return [self _writeEnterprise:_enterprise
                 withCommand:@"new"
                   withFlags:_flags];
} /* End _createEnterprise */

/* Update enterprise */
-(id)_updateEnterprise:(NSDictionary *)_enterprise
              objectId:(NSString *)_objectId
             withFlags:(NSArray *)_flags 
{
  return [self _writeEnterprise:_enterprise
                     withCommand:@"set"
                       withFlags:_flags];
} /* End _updateEnterprise */

/* Store the provided enterprise relationship  
   Uses _saveCompanyAssignments */
-(NSException *)_savePersonsToEnterprise:(NSArray *)_assignments 
                                objectId:(id)_objectId 
{
  return [self _saveCompanyAssignments:_assignments 
                              objectId:_objectId
                                   key:@"companyId"
                          targetEntity:@"Person"
                             targetKey:@"subCompanyId"];
} /* End _savePersonsToEnterprise */

-(id)_writeEnterprise:(NSDictionary *)_enterprise
          withCommand:(NSString *)_command
            withFlags:(NSArray *)_flags
{
  return [self _writeCompany:_enterprise
                  withCommand:_command
                    withFlags:_flags
                    forEntity:@"enterprise"];
} /* End _writeEnterprise */

/* Save contact entries */
-(NSException *)_saveBusinessCards:(NSArray *)_contacts
                      enterpriseId:(id)_enterpriseId
{
  NSEnumerator    *enumerator;
  NSDictionary    *contact;
  NSDictionary    *tmp;
  
  if (_contacts == nil) 
    return nil;
  enumerator = [_contacts objectEnumerator];
  while((contact = [enumerator nextObject]) != nil)
  {
    tmp = [self _createContact:contact 
                     withFlags:[NSArray arrayWithObject:@"noCommit"]];
    [[self getCTX] runCommand:@"companyassignment::new"
        arguments:[NSDictionary dictionaryWithObjectsAndKeys:
                     [tmp objectForKey:@"objectId"],
                     @"subCompanyId",
                     _enterpriseId, 
                     @"companyId",
                     nil]];
  } /* End save contacts loop */
  return nil;
} /* End _saveBusinessCards */

@end /* End zOGIAction(Enterprise) */
