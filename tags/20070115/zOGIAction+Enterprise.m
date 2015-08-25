/*
  zOGIAction+Enterprise.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Company.h"
#include "zOGIAction+Enterprise.h"

@implementation zOGIAction(Enterprise)

-(NSArray *)_renderEnterprises:(NSArray *)_enterprises withDetail:(NSNumber *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoEnterprise;
  int                  count;

  result = [NSMutableArray arrayWithCapacity:[_enterprises count]];
  for (count = 0; count < [_enterprises count]; count++) {
    eoEnterprise = [_enterprises objectAtIndex:count];
    [self logWithFormat:@"_renderEnterprises([%@])", eoEnterprise];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
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
     if([_detail intValue] > 0)
       [[result objectAtIndex:count] setObject:eoEnterprise forKey:@"eoObject"];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       if([_detail intValue] & zOGI_INCLUDE_COMPANYVALUES)
         [self _addCompanyValuesToCompany:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_CONTACTS)
         [self _addContactsToEnterprise:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PROJECTS)
         [self _addProjectsToEnterprise:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
       [[result objectAtIndex:count] removeObjectForKey:@"eoObject"];
      }
    }
  return result;
}

-(NSArray *)_getUnrenderedEnterprisesForKeys:(id)_arg {
  NSArray       *enterprises;

  enterprises = [[[self getCTX] runCommand:@"enterprise::get-by-globalid",
                                           @"gids", [self _getEOsForPKeys:_arg],
                                           nil] retain];
  return enterprises;
}

-(id)_getEnterprisesForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  return [self _renderEnterprises:
            [self _getUnrenderedEnterprisesForKeys:_arg] withDetail:_detail];
}

-(id)_getEnterpriseForKeys:(id)_pk {
  [self logWithFormat:@"_getEnterprisesForKeys([%@])", _pk];
  return [self _getEnterprisesForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getEnterpriseForKey:(id)_pk withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getEnterpriseForKey([%@],[%@])", _pk, _detail];
  return [[self _getEnterprisesForKeys:_pk withDetail:_detail] objectAtIndex:0];
}

-(id)_getEnterpriseForKey:(id)_pk {
  [self logWithFormat:@"_getEnterpriseForKey([%@])", _pk];
  return [[self _getEnterprisesForKeys:_pk 
                   withDetail:[NSNumber numberWithInt:0]] objectAtIndex:0];
}

-(void)_addProjectsToEnterprise:(NSMutableDictionary *)_enterprise {
  NSArray        *projects;
  NSMutableArray *projectList;
  NSEnumerator   *enumerator;
  id             project;

  projects = [[self getCTX] runCommand:@"enterprise::get-projects",
                                       @"object", [_enterprise objectForKey:@"eoObject"],
                                       nil];
  if (projects == nil) projects = [NSArray array];
  projectList = [[NSMutableArray alloc] initWithCapacity:[projects count]];
  enumerator = [projects objectEnumerator];
  while ((project = [enumerator nextObject]) != nil) {
    [self logWithFormat:@"_addProjectsToEnterprise([%@])", project];
    [projectList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
       [self NIL:[project valueForKey:@"objectVersion"]], @"version",
       [self NIL:[project valueForKey:@"ownerId"]], @"ownerObjectId",
       [self NIL:[project valueForKey:@"kind"]], @"kind",
       [self NIL:[project valueForKey:@"projectId"]], @"objectId",
       [self NIL:[project valueForKey:@"isFake"]], @"placeHolder",
       [self NIL:[project valueForKey:@"number"]], @"number",
       [self NIL:[project valueForKey:@"name"]], @"name",
       [self NIL:[project valueForKey:@"status"]], @"status",
       nil]];
   }
  [_enterprise setObject:projectList forKey:@"_PROJECTS"];
}

-(void)_addContactsToEnterprise:(NSMutableDictionary *)_enterprise {
  NSArray        *contacts;
  NSMutableArray *contactList;
  NSEnumerator   *enumerator;
  id             contact;

  contacts = [[self getCTX] runCommand:@"companyassignment::get",
                 @"returnType", intObj(LSDBReturnType_ManyObjects),
                 @"companyId", [NSNumber numberWithInt:[[_enterprise objectForKey:@"objectId"] intValue]],
                 nil];
  if (contacts == nil) contacts = [NSArray array];
  contactList = [[NSMutableArray alloc] initWithCapacity:[contacts count]];
  enumerator = [contacts objectEnumerator];
  while ((contact = [enumerator nextObject]) != nil) {
    [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
       [self NIL:[contact valueForKey:@"companyAssignmentId"]], @"objectId",
       @"assignment", @"entityName",
       [self NIL:[contact valueForKey:@"subCompanyId"]], @"contactObjectId",
       [self NIL:[contact valueForKey:@"companyId"]], @"enterpriseObjectId",
       [self NIL:[contact valueForKey:@"isChief"]], @"isChief",
       [self NIL:[contact valueForKey:@"function"]], @"function",
       [NSNull null], @"projectId",  // only related to project assignments
       [NSNull null], @"accessRight",  // only related to project assignments
       [NSNull null], @"info", // only related to project assignments
       nil]];
   }
  [_enterprise setObject:contactList forKey:@"_CONTACTS"];
}

-(NSArray *)_getFavoriteEnterprises:(NSNumber *)_detail {
  NSArray      *favoriteIds;
  [self logWithFormat:@"_getFavoriteEnterprises()"];
  favoriteIds = [[self _getDefaults] arrayForKey:@"enterprise_favorites"];
  [self logWithFormat:@"_getFavoriteEnterprises() = %@", favoriteIds];
  return [self _getEnterprisesForKeys:favoriteIds withDetail:_detail];
}

-(void)_unfavoriteEnterprise:(NSString *)enterpriseId {
  NSMutableArray    *favIds;

  favIds = [[NSMutableArray alloc] initWithArray:[self _getFavoriteEnterprises]];
  [favIds removeObject:enterpriseId];
  [[self _getDefaults] setObject:favIds forKey:@"enterprise_favorites"];
  [[self _getDefaults] synchronize];
  [favIds release];
}

-(void)_favoriteEnterprise:(NSString *)enterpriseId {
  NSMutableArray    *favIds;

  favIds = [[NSMutableArray alloc] initWithArray:[self _getFavoriteEnterprises]];
  [favIds addObject:enterpriseId];
  [[self _getDefaults] setObject:favIds forKey:@"enterprise_favorites"];
  [[self _getDefaults] synchronize];
  [favIds release];
}

-(id)_searchForEnterprises:(id)_query withDetail:(NSNumber *)_detail {
  NSArray         *results;

  results = [[self getCTX] runCommand:@"enterprise::qsearch"
                             @"qualifier", _query,
                             @"maxSearchCount", [NSNumber numberWithInt:25],
                             @"fetchGlobalIDs", [NSNumber numberWithBool:YES],
              nil];
  [self logWithFormat:@"_searchForEnterprise(%@)=%@", _query, results];
  return results;
}

@end /* End zOGIAction(Enterprise) */
