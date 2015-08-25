/*
  zOGIAction+Contact.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Company.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Assignment.h"

@implementation zOGIAction(Contact)

-(NSArray *)_renderContacts:(NSArray *)_contacts withDetail:(NSNumber *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoContact;
  int                  count;

  /* [self logWithFormat:@"_renderContacts([%@])", _contacts]; */
  result = [NSMutableArray arrayWithCapacity:[_contacts count]];
  for (count = 0; count < [_contacts count]; count++) {
    eoContact = [_contacts objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoContact valueForKey:@"companyId"], @"objectId",
       @"Contact", @"entityName",
       [eoContact valueForKey:@"objectVersion"], @"version",
       [eoContact valueForKey:@"ownerId"], @"ownerObjectId",
       [self NIL:[eoContact valueForKey:@"assistantName"]], @"assistantName",
       [self NIL:[eoContact valueForKey:@"associatedCategories"]], @"associatedCategories",
       [self NIL:[eoContact valueForKey:@"associatedCompany"]], @"associatedCompany",
       [self NIL:[eoContact valueForKey:@"associatedContacts"]], @"associatedContacts",
       [self NIL:[eoContact valueForKey:@"birthday"]], @"birthDate",
       [self NIL:[eoContact valueForKey:@"nickname"]], @"displayName",
       [self NIL:[eoContact valueForKey:@"bossname"]], @"managersName",
       [self NIL:[eoContact valueForKey:@"degree"]], @"degree",
       [self NIL:[eoContact valueForKey:@"department"]], @"department",
       [self NIL:[eoContact valueForKey:@"description"]], @"description",
       [self NIL:[eoContact valueForKey:@"fileas"]], @"fileAs",
       [self NIL:[eoContact valueForKey:@"firstname"]], @"firstName",
       [self NIL:[eoContact valueForKey:@"middlename"]], @"middleName",
       [self NIL:[eoContact valueForKey:@"name"]], @"lastName",
       [self NIL:[eoContact valueForKey:@"imAddress"]], @"imAddress",
       [self NIL:[[eoContact objectForKey:@"comment"] objectForKey:@"comment"]], @"comment",
       //[eoContact valueForKey:@"isPrivate"], @"isPrivate",
       [eoContact valueForKey:@"isAccount"], @"isAccount",
       [self NIL:[eoContact valueForKey:@"keywords"]], @"keywords",
       [self NIL:[eoContact valueForKey:@"occupation"]], @"occupation",
       [self NIL:[eoContact valueForKey:@"office"]], @"office",
       [self NIL:[eoContact valueForKey:@"salutation"]], @"salutation",
       [self NIL:[eoContact valueForKey:@"sensitivity"]], @"sensitivity",
       [self NIL:[eoContact valueForKey:@"sex"]], @"gender",
       [self NIL:[eoContact valueForKey:@"url"]], @"url",
       nil]];
       [self _addAddressesToCompany:[result objectAtIndex:count]];
       [self _addPhonesToCompany:[result objectAtIndex:count]];
     if([_detail intValue] > 0)
       [[result objectAtIndex:count] setObject:eoContact forKey:@"*eoObject"];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       if([_detail intValue] & zOGI_INCLUDE_COMPANYVALUES)
         [self _addCompanyValuesToCompany:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_MEMBERSHIP)
         [self _addMembershipToPerson:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_ENTERPRISES)
         [self _addEnterprisesToPerson:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PROJECTS)
         [self _addProjectsToPerson:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
       [[result objectAtIndex:count] removeObjectForKey:@"*eoObject"];
      }
    }
  return result;
}

-(NSArray *)_getUnrenderedContactsForKeys:(id)_arg {
  NSArray       *contacts;

  /* [self logWithFormat:@"_getUnrenderedContactsForKeys([%@])", _arg]; */
  contacts = [[[self getCTX] runCommand:@"person::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  return contacts;
}

-(id)_getContactsForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  /* [self logWithFormat:@"_getContactsForKeys([%@])", _arg]; */
  return [self _renderContacts:[self _getUnrenderedContactsForKeys:_arg] withDetail:_detail];
}

-(id)_getContactsForKeys:(id)_arg {
  return [self _renderContacts:[self _getUnrenderedContactsForKeys:_arg] 
               withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getContactForKey:(id)_pk withDetail:(NSNumber *)_detail {
  /* [self logWithFormat:@"_getContactForKey([%@],[%@])", _pk, _detail]; */
  return [[self _getContactsForKeys:_pk withDetail:_detail] objectAtIndex:0];
}

-(id)_getContactForKey:(id)_pk {
  /* [self logWithFormat:@"_getContactForKey([%@])", _pk]; */
  return [[self _getContactsForKeys:_pk] objectAtIndex:0];
}

-(NSException *)_addEnterprisesToPerson:(NSMutableDictionary *)_contact {
  id                  assignments;
  NSMutableArray      *enterpriseList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_contact key:@"subCompanyId"]; 
  if ([assignments class] == [NSException class]) return assignments;
  enterpriseList = [[NSMutableArray alloc] initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Enterprise"]) {
      assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                    source:[eo valueForKey:@"subCompanyId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [enterpriseList addObject:assignment];
     }
   }
  [_contact setObject:enterpriseList forKey:@"_ENTERPRISES"];
  return nil;
}

-(NSException *)_addMembershipToPerson:(NSMutableDictionary *)_contact {
  id                   assignments;
  NSMutableArray      *teamList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_contact key:@"subCompanyId"];
  if ([assignments class] == [NSException class]) return assignments;
  teamList = [[NSMutableArray alloc] initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Team"]) {
      assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                    source:[eo valueForKey:@"subCompanyId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [teamList addObject:assignment];
     }
   }
  [_contact setObject:teamList forKey:@"_MEMBERSHIP"];
  return nil;
}

-(NSException *)_addProjectsToPerson:(NSMutableDictionary *)_contact {
  NSMutableArray      *projectList;
  NSArray             *projects;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  projects = [[self getCTX] runCommand:@"person::get-project-assignments",
                                       @"withArchived", [NSNumber numberWithBool:YES],
                                       @"object", [_contact objectForKey:@"*eoObject"],
                                       nil];
  /* [self logWithFormat:@"projects=%@", projects]; */
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
  [_contact setObject:projectList forKey:@"_PROJECTS"];
  return nil;
}

-(NSArray *)_getFavoriteContacts:(NSNumber *)_detail {
  NSArray      *favoriteIds;

  [self logWithFormat:@"_getFavoriteContacts()"];
  favoriteIds = [[self _getDefaults] arrayForKey:@"person_favorites"];
  if (favoriteIds == nil)
    return [[NSArray alloc] initWithObjects:nil];
  return [self _getContactsForKeys:favoriteIds withDetail:_detail];
}

-(void)_unfavoriteContact:(NSString *)contactId {
  NSMutableArray    *favIds;

  favIds = [[NSMutableArray alloc] initWithArray:[self _getFavoriteContacts:[NSNumber numberWithInt:0]]];
  [favIds removeObject:contactId];
  [[self _getDefaults] setObject:favIds forKey:@"person_favorites"];
  [[self _getDefaults] synchronize];
  [favIds release];
}

-(void)_favoriteContact:(NSString *)contactId {
  NSMutableArray    *favIds;

  favIds = [[NSMutableArray alloc] initWithArray:[self _getFavoriteContacts:[NSNumber numberWithInt:0]]];
  [favIds addObject:contactId];
  [[self _getDefaults] setObject:favIds forKey:@"person_favorites"];
  [[self _getDefaults] synchronize];
  [favIds release];
}

-(id)_searchForContacts:(NSArray *)_query withDetail:(NSNumber *)_detail {
  NSArray         *results;
  NSString        *query;
  NSDictionary    *qualifier;
  int             count;
  NSMutableString *value;

  [self logWithFormat:@"_searchForContacts(%@, %@)", _query, _detail];
  query = [NSString stringWithString:@""];
  for(count = 0; count < [_query count]; count++) {
    qualifier = [_query objectAtIndex:count];
    [self logWithFormat:@"_searchForContacts(...):qualifier %d = %@", count, qualifier];
    if (count > 0) {
      if ([qualifier objectForKey:@"conjunction"] != nil) {
        if ([[qualifier objectForKey:@"conjunction"] isEqualToString:@"AND"])
          query = [query stringByAppendingString:@" AND "];
        else if ([[qualifier objectForKey:@"conjunction"] isEqualToString:@"OR"])
          query = [query stringByAppendingString:@" OR "];
        else {
          // \todo Throw exception for unsupported conjunction
         [self logWithFormat:@"_searchForContacts(...):unsupported conjunction"];
         }
       } else {
           // \todo Throw exception for absent conjunction
           [self logWithFormat:@"_searchForContacts(...):absent conjunction"];
          }
     } // End if (count > 0)
    if([qualifier objectForKey:@"key"] != nil) {
      if([self _translateContactKey:[qualifier objectForKey:@"key"]] != nil) {
        query = [query stringByAppendingString:[self _translateContactKey:[qualifier objectForKey:@"key"]]];
       } else {
           // \todo Throw exception for unsupported key
           [self logWithFormat:@"_searchForContacts(...):unsupported key"];
          }
     } else {
         // \todo Throw exception for absent key
         [self logWithFormat:@"_searchForContacts(...):absent key"];
        }
    if ([qualifier objectForKey:@"expression"] != nil) {
      if ([[qualifier objectForKey:@"expression"] isEqualToString:@"EQUALS"])
        query = [query stringByAppendingString:@" = "];
      else if ([[qualifier objectForKey:@"expression"] isEqualToString:@"LIKE"])
        query = [query stringByAppendingString:@" LIKE "];
      else {
        // \todo Throw exception for unsupported expression
        [self logWithFormat:@"_searchForContacts(...):unsupported expression"];
       }
     } else {
       // \todo Throw exception for absent expression
       [self logWithFormat:@"_searchForContacts(...):absent expression"];
      }
    if([qualifier objectForKey:@"value"] != nil) {
      if ([[qualifier objectForKey:@"value"] isKindOfClass:[NSNumber class]]) {
        // value is an NSNumber
        query = [query stringByAppendingString:[[qualifier objectForKey:@"value"] stringValue]];
       } else if ([[qualifier objectForKey:@"value"] isKindOfClass:[NSString class]]) {
           // Value is an NSString; must be wrapped in quotes
           query = [query stringByAppendingString:@"\""];
           value = [NSMutableString stringWithString:[qualifier objectForKey:@"value"]];
           //[value replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:nil searchName:NSMakeRange(0, [value length])];
           // If expression is LIKE replace * with %
           if ([[qualifier objectForKey:@"expression"] isEqualToString:@"LIKE"]) {
             //[value replaceOccurrencesOfString:@"*" withString:@"%"];
            }
           query = [query stringByAppendingString:value];
           query = [query stringByAppendingString:@"\""];
           [value release];
          } else {
              // \todo Throw exception for unhandled value class type
              [self logWithFormat:@"_searchForContacts(...):unhandled value type"];
             }
     } else {
       // \todo Throw exception for absent value
       [self logWithFormat:@"_searchForContacts(...):absent value"];
      }
   } // End for loop of qualifiers
  [self logWithFormat:@"_searchForContacts(...):query=%@", query];
  results = [[self getCTX] runCommand:@"person::qsearch",
                             @"qualifier", query, 
                             nil];
  if (results == nil) {
    [self logWithFormat:@"_searchForContacts(...):=nil"];
    return [NSNumber numberWithBool:NO];
   }
  /* [self logWithFormat:@"_searchForContacts(...):=%@", results]; */
  return [self _renderContacts:results withDetail:_detail];
}

- (NSString *)_translateContactKey:(NSString *)_key {
  
  if ([_key isEqualToString:@"displayName"]) 
    return [NSString stringWithString:@"nickname"];
  else if ([_key isEqualToString:@"birthDate"])
    return [NSString stringWithString:@"birthday"];
  else if ([_key isEqualToString:@"managersName"])
    return [NSString stringWithString:@"bossname"];
  else if ([_key isEqualToString:@"fileAs"])
    return [NSString stringWithString:@"fileas"];
  else if ([_key isEqualToString:@"firstName"])
    return [NSString stringWithString:@"firstname"];
  else if ([_key isEqualToString:@"middleName"])
    return [NSString stringWithString:@"middlename"];
  else if ([_key isEqualToString:@"lastName"])
    return [NSString stringWithString:@"name"];
  else if ([_key isEqualToString:@"objectId"])
    return [NSString stringWithString:@"companyId"];
  else if ([_key isEqualToString:@"version"])
    return [NSString stringWithString:@"objectVersion"];
  else if ([_key isEqualToString:@"ownerObjectId"])
    return [NSString stringWithString:@"ownerId"];
  else if ([_key isEqualToString:@"managersName"])
    return [NSString stringWithString:@"bossname"];
  return _key;
} /* End _translateContactKey */

-(id)_updateContact:(NSDictionary *)_contact
           objectId:(NSString *)_objectId
          withFlags:(NSArray *)_flags {
  NSArray              *keys;
  NSString             *key;
  id                   value, contact;
  int                  count;

  contact = [[NSMutableDictionary alloc] initWithCapacity:[_contact count]];
  keys = [_contact allKeys]; 
  for (count = 0; count < [keys count]; count++) {
    key = [self _translateContactKey:[keys objectAtIndex:count]];
    if (key != nil)
      [contact setObject:[_contact objectForKey:[keys objectAtIndex:count]] 
                  forKey:key];
   }
  if ([_contact objectForKey:@"_COMPANYVALUES"] != nil) {
    for (count = 0;
         count < [[_contact objectForKey:@"_COMPANYVALUES"] count];
         count ++) {
      value = [[_contact objectForKey:@"_COMPANYVALUES"] objectAtIndex:count];
      [contact setObject:[value objectForKey:@"value"]
                  forKey:[value objectForKey:@"attribute"]];
     }
   }
  contact = [[self getCTX] runCommand:@"person::set"
                            arguments:contact];
  if ([contact class] == [NSException class]) {
    [[self getCTX] rollback];
    return contact;
   }
  [[self getCTX] commit];
  contact = [self _getContactForKey:[contact objectForKey:@"companyId"]
                         withDetail:[NSNumber numberWithInt:65535]];
  return contact;
 } /* End _updateContact */

-(id)_createContact:(NSDictionary *)_contact
          withFlags:(NSArray *)_flags {
  NSArray              *keys;
  NSString             *key;
  id                   value, contact;
  int                  count;

  contact = [[NSMutableDictionary alloc] initWithCapacity:[_contact count]];
  keys = [_contact allKeys];
  for (count = 0; count < [keys count]; count++) {
    key = [self _translateContactKey:[keys objectAtIndex:count]];
    if (key != nil)
      if(![key isEqualToString:@"companyId"])
        [contact setObject:[_contact objectForKey:[keys objectAtIndex:count]]
                    forKey:key];
   }
  if ([_contact objectForKey:@"_COMPANYVALUES"] != nil) {
    for (count = 0; 
         count < [[_contact objectForKey:@"_COMPANYVALUES"] count]; 
         count ++) {
      value = [[_contact objectForKey:@"_COMPANYVALUES"] objectAtIndex:count];
      [contact setObject:[value objectForKey:@"value"] 
                  forKey:[value objectForKey:@"attribute"]];
     }
   }
  contact = [[self getCTX] runCommand:@"person::new"
                            arguments:contact];
  if ([contact class] == [NSException class]) {
    [[self getCTX] rollback];
    return contact;
   }
  [[self getCTX] commit];
  contact = [self _getContactForKey:[contact objectForKey:@"companyId"]
                         withDetail:[NSNumber numberWithInt:65535]];
  return contact;
 } /* End _createContact */


@end /* End zOGIAction(Contact) */
