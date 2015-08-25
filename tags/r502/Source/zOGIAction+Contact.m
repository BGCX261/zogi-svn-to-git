/*
  zOGIAction+Contact.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006, 2007
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Company.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Assignment.h"

@implementation zOGIAction(Contact)

/* Render contacts at the specified detail level
   _contacts must be an array of EOGenericRecords
   _detail must be an NSNumber, this value has no default, must be provided */
-(NSArray *)_renderContacts:(NSArray *)_contacts withDetail:(NSNumber *)_detail 
{
  NSMutableArray      *result;
  EOGenericRecord     *eoContact;
  int                  count;

  /* [self logWithFormat:@"_renderContacts([%@])", _contacts]; */
  result = [NSMutableArray arrayWithCapacity:[_contacts count]];
  for (count = 0; count < [_contacts count]; count++) 
  {
    eoContact = [_contacts objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       eoContact, @"*eoObject",
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
       [self NIL:[[eoContact objectForKey:@"comment"] objectForKey:@"comment"]], 
          @"comment",
       [eoContact valueForKey:@"isPrivate"], @"isPrivate",
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
     /* Add flags */
     [[result objectAtIndex:count] 
         setObject:[self _renderCompanyFlags:eoContact entityName:@"Contact"]
           forKey:@"FLAGS"];
     /* Add detail if required */
     if([_detail intValue] > 0) 
     {
       if([_detail intValue] & zOGI_INCLUDE_COMPANYVALUES)
         [self _addCompanyValuesToCompany:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_MEMBERSHIP)
         [self _addMembershipToPerson:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_ENTERPRISES)
         [self _addEnterprisesToPerson:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PROJECTS)
         [self _addProjectsToPerson:[result objectAtIndex:count]];
       /* Call the _addObjectDetails method that adds details, if requested,
          that are appropriate to all object types */
       [self _addObjectDetails:[result objectAtIndex:count] 
                    withDetail:_detail];
     } /* End if-some-detail-has-been-requested */
     [self _stripInternalKeys:[result objectAtIndex:count]];
   } /* End rendering loop */
  return result;
} /* End _renderContacts */

/* Get the EO object from the database for the specified keys.  Keys
   can be numbers, strings or EOGlobalIDs */
-(NSArray *)_getUnrenderedContactsForKeys:(id)_arg 
{
  NSArray       *contacts;

  contacts = [[[self getCTX] runCommand:@"person::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  return contacts;
}

/*
  Singular instance of _getUnrenderedContactsForKeys;  still returns an array
  however so that it can be used with methods that also handle bulk actions.
  This array is guaranteed to be single-valued.
 */
-(id)_getUnrenderedContactForKey:(id)_arg 
{
  NSArray    *results;
 
  results = [self _getUnrenderedContactsForKeys:_arg];
  if (results == nil) return nil;
  if ([results count] == 0) return nil;
  return [results lastObject];
} /* End of _getUnrenderedContactsForKey */

/* Return the rendered contacts at the specified detail level */
-(id)_getContactsForKeys:(id)_arg withDetail:(NSNumber *)_detail 
{
  return [self _renderContacts:[self _getUnrenderedContactsForKeys:_arg] 
                    withDetail:_detail];
} /* End of _getContactsForKeys */

/* Return the rendered contacts at the default detail level, which is 0 */
-(id)_getContactsForKeys:(id)_arg 
{
  return [self _renderContacts:[self _getUnrenderedContactsForKeys:_arg] 
               withDetail:[NSNumber numberWithInt:0]];
} /* End of _getContactsForKeys */

/* Return singular contact with specified detail level */
-(id)_getContactForKey:(id)_pk withDetail:(NSNumber *)_detail 
{
  id               result;

  result = [self _getContactsForKeys:_pk withDetail:_detail];
  if ([result isKindOfClass:[NSException class]])
    return result;
  if ([result isKindOfClass:[NSMutableArray class]])
    if([result count] == 1)
      return [result objectAtIndex:0];
  return nil;
} /* End of _getContactForKey */

/* Return singular contact with specified detail leve, which is 0 */
-(id)_getContactForKey:(id)_pk 
{
  return [[self _getContactsForKeys:_pk] objectAtIndex:0];
} /* End of _getContactForKey */

/* Add enterprises to contact dictionary 
   This method may return an exception 
   Uses the _getCompanyAssignments method */
-(NSException *)_addEnterprisesToPerson:(NSMutableDictionary *)_contact 
{
  id                  assignments;
  NSMutableArray      *enterpriseList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_contact key:@"subCompanyId"]; 
  if ([assignments class] == [NSException class]) 
    return assignments;
  enterpriseList = [NSMutableArray new];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    if ([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Enterprise"]) 
    {
      assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                    source:[eo valueForKey:@"subCompanyId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [enterpriseList addObject:assignment];
    } /* end if-assignment-is-to-enterprise */
  } /* End loop-assignment-enumerator */
  [_contact setObject:enterpriseList forKey:@"_ENTERPRISES"];
  return nil;
} /* End _addEnterprisesToPerson */

/* Store the provided enterprise relationship
   Uses _saveCompanyAssignments */
-(NSException *)_saveEnterprisesToPerson:(NSArray *)_assignments 
                                objectId:(id)_objectId 
{
  return [self _saveCompanyAssignments:_assignments 
                              objectId:_objectId
                                   key:@"subCompanyId"
                          targetEntity:@"Enterprise"
                             targetKey:@"companyId"];
} /* End _saveEnterprisesToPerson */

/* Add team membership to contact dictionary
   This method may return an exception
   Uses the _getCompanyAssignments method */
-(NSException *)_addMembershipToPerson:(NSMutableDictionary *)_contact 
{
  id                   assignments;
  NSMutableArray      *teamList;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableDictionary *assignment;

  assignments = [self _getCompanyAssignments:_contact key:@"subCompanyId"];
  if ([assignments isKindOfClass:[NSException class]]) 
    return assignments;
  teamList = [NSMutableArray new];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    if ([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Team"]) 
    {
      assignment = [self _renderAssignment:[eo valueForKey:@"companyAssignmentId"]
                                    source:[eo valueForKey:@"subCompanyId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [teamList addObject:assignment];
    } /* End if-assignment-is-to-a-team */
  } /* End assignment-enumerator-loop */
  [_contact setObject:teamList forKey:@"_MEMBERSHIP"];
  return nil;
} /* End _addMembershipToPerson */

/* Adds project membership to contact dictionary
   No exception handling or production
   Uses the person::get-project-assignments Logic command */
-(NSException *)_addProjectsToPerson:(NSMutableDictionary *)_contact 
{
  id                   projects;    /* Results of logic command */
  NSMutableArray      *projectList; /* Rendered list of project assignments */
  NSEnumerator        *enumerator;  /* Enumerator for looping projects */
  EOGenericRecord     *eo;          /* Project assignment record */
  NSMutableDictionary *assignment;  /* Rendered project assignment */

  projects = [[self getCTX] runCommand:@"person::get-project-assignments",
                              @"withArchived", [NSNumber numberWithBool:YES],
                              @"object", [_contact objectForKey:@"*eoObject"],
                              nil];
  /* [self logWithFormat:@"projects=%@", projects]; */
  if ([projects isKindOfClass:[NSException class]])
    return projects;
  projectList = [NSMutableArray new];
  enumerator = [projects objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                  source:[eo valueForKey:@"companyId"]
                                  target:[eo valueForKey:@"projectId"]
                                      eo:eo];
    [projectList addObject:assignment];
  } /* End loop-project-assignments */
  [_contact setObject:projectList forKey:@"_PROJECTS"];
  return nil;
} /* End _addProjectsToPerson */

-(NSArray *)_getFavoriteContacts:(NSNumber *)_detail 
{
  NSArray      *favoriteIds;

  favoriteIds = [[self _getDefaults] arrayForKey:@"person_favorites"];
  if (favoriteIds == nil)
    return [[NSArray alloc] initWithObjects:nil];
  return [self _getContactsForKeys:favoriteIds withDetail:_detail];
} /* End _getFavoriteContacts */

/* Build up criteria and do a qsearch for contacts
   TODO: Scary!
   TODO: Should be case insensitive, is that possible?
   TODO: Support subordinate keys like address keys and telephone keys */
-(id)_searchForContacts:(NSArray *)_query withDetail:(NSNumber *)_detail 
{
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

/* Translate zOGI attribute names to OGo Logic attribute names
   TODO: Possibly it would be better to do this with SOPE rules? */
- (NSString *)_translateContactKey:(NSString *)_key 
{  
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

/*
  Delete a Contact/Person
  Currently there are no supported flags, the value of flags is ignored
*/
-(id)_deleteContact:(NSString *)_objectId
              withFlags:(NSArray *)_flags 
{
  EOGenericRecord   *eo;
  id                 result;

  eo = [self _getUnrenderedContactForKey:_objectId];
  /* delete any company assignments */
  result = [self _saveEnterprisesToPerson:[[NSArray alloc] init] 
                                 objectId:[eo objectForKey:@"companyId"]];
  if (result == nil)
  {
    /* delete the object */
    result = [[self getCTX] runCommand:@"person::delete",
                 @"object", eo,
                 @"reallyDelete", [NSNumber numberWithBool:YES],
                 nil];
  }
  eo = nil;
  if ([result isKindOfClass:[NSException class]])
  {
    [[self getCTX] rollback];
    [self logWithFormat:@"deletion of contact %@ failed with exception", _objectId];
    return [NSNumber numberWithBool:NO];
  }
  [[self getCTX] commit];
  return [NSNumber numberWithBool:YES]; 
} /* End _deleteContact */

/* Creates a new contact from the provided dictionary.
   Uses _writeContact method with a "new" command */
-(id)_createContact:(NSDictionary *)_contact
               withFlags:(NSArray *)_flags 
{
  return [self _writeContact:_contact
                 withCommand:@"new"
                   withFlags:_flags];
} /* End _createContact */

/* Update contact 
   Uses _writeContact method with a "set" command */
-(id)_updateContact:(NSDictionary *)_contact
           objectId:(NSString *)_objectId
          withFlags:(NSArray *)_flags 
{
  return [self _writeContact:_contact
                 withCommand:@"set"
                   withFlags:_flags];
} /* End _updateContact */

-(id)_writeContact:(NSDictionary *)_contact
       withCommand:(NSString *)_command
         withFlags:(NSArray *)_flags
{
  return [self _writeCompany:_contact
                 withCommand:_command
                   withFlags:_flags
                   forEntity:@"person"];
} /* End _writeContact */

@end /* End zOGIAction(Contact) */
