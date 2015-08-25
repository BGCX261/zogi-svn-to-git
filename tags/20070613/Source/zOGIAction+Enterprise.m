/*
  zOGIAction+Enterprise.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Company.h"
#include "zOGIAction+Enterprise.h"
#include "zOGIAction+Assignment.h"

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
       [[result objectAtIndex:count] setObject:eoEnterprise forKey:@"*eoObject"];
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
  projectList = [[NSMutableArray alloc] initWithCapacity:[projects count]];
  enumerator = [projects objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) {
    assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                  source:[eo valueForKey:@"companyId"]
                                  target:[eo valueForKey:@"projectId"]
                                      eo:eo];
    [projectList addObject:assignment];
   }
  [_enterprise setObject:projectList forKey:@"_PROJECTS"];
}

-(void)_addContactsToEnterprise:(NSMutableDictionary *)_enterprise {
  NSArray             *assignments;
  NSMutableArray      *contactList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_enterprise key:@"companyId"];
  contactList = [[NSMutableArray alloc] initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) {
    assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                  source:[eo valueForKey:@"companyId"]
                                  target:[eo valueForKey:@"subCompanyId"]
                                      eo:eo];
    [contactList addObject:assignment];
   }
  [_enterprise setObject:contactList forKey:@"_CONTACTS"];
}

-(NSArray *)_getFavoriteEnterprises:(NSNumber *)_detail {
  NSArray      *favoriteIds;
  [self logWithFormat:@"_getFavoriteEnterprises()"];
  favoriteIds = [[self _getDefaults] arrayForKey:@"enterprise_favorites"];
  if (favoriteIds == nil)
    return [[NSArray alloc] initWithObjects:nil];
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
