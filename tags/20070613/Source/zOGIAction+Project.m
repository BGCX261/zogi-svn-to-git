/*
  zOGIAction+Project.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Project.h"
#include "zOGIAction+Note.h"
#include "zOGIAction+Assignment.h"
#include "zOGIAction+Task.h"

@implementation zOGIAction(Project)

-(NSArray *)_renderProjects:(NSArray *)_projects withDetail:(NSNumber *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoProject;
  int                  count;
  NSString            *comment;

  result = [NSMutableArray arrayWithCapacity:[_projects count]];
  for (count = 0; count < [_projects count]; count++) {
    eoProject = [_projects objectAtIndex:count];
    [[self getCTX] runCommand:@"project::get-root-document",
                              @"object", eoProject,
                              @"relationKey", @"rootDocument", 
                              nil];
    [[self getCTX] runCommand:@"project::get-comment",
                              @"object", eoProject, 
                              @"relationKey", @"comment", 
                              nil];
    [self logWithFormat:@"_renderProject([%@])", eoProject];
    comment = [[eoProject objectForKey:@"comment"] objectForKey:@"comment"];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoProject valueForKey:@"projectId"], @"objectId",
       @"Project", @"entityName",
       [self NIL:[eoProject valueForKey:@"objectVersion"]], @"version",
       [self NIL:[eoProject valueForKey:@"ownerId"]], @"ownerObjectId",
       [self NIL:[eoProject valueForKey:@"kind"]], @"kind",
       comment, @"comment",
       [self NIL:[eoProject valueForKey:@"isFake"]], @"placeHolder",
       [[eoProject valueForKey:@"rootDocument"] valueForKey:@"documentId"], 
         @"folderObjectId",
       [self NIL:[eoProject valueForKey:@"number"]], @"number",
       [self NIL:[eoProject valueForKey:@"startDate"]], @"startDate",
       [self NIL:[eoProject valueForKey:@"endDate"]], @"endDate",
       [self NIL:[eoProject valueForKey:@"name"]], @"name",
       [self NIL:[eoProject valueForKey:@"status"]], @"status",
       nil]];
     if([_detail intValue] > 0)
       [[result objectAtIndex:count] setObject:eoProject forKey:@"*eoObject"];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       if([_detail intValue] & zOGI_INCLUDE_TASKS)
         [self _addTasksToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_NOTATIONS)
         [self _addNotesToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PARTICIPANTS)
         [self _addParticipantsToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_CONTACTS)
         [self _addContactsToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_ENTERPRISES)
         [self _addEnterprisesToProject:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
      }
    }
  [self logWithFormat:@"----_renderProjects(...)-------<end>----"];
  return result;
}

-(NSArray *)_getUnrenderedProjectsForKeys:(id)_arg {
  NSArray       *projects;

  projects = [[[self getCTX] runCommand:@"project::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  /*
     What about this crap?
       We do this later on demand, only if required. It remains to be seen
       if we would be better off just always doing this up front.
  
      We know we don't need get-owner since we rely on the ownerObjectId
      [self runCommand:
            @"project::get-owner",
            @"objects",     pj,
            @"relationKey", @"owner", nil];

      There is ::get-accounts and ::get-team,  probably need to put these
      under the _MEMBERSHIP key.
      [self runCommand:
            @"project::get-team",
            @"objects",     pj,
            @"relationKey", @"team", nil];

      This is in the _getProjectAssignments method
      [self runCommand:
            @"project::get-company-assignments",
            @"objects",     pj,
            @"relationKey", @"companyAssignments", nil];
   */
  return projects;
}

-(id)_getProjectsForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  return [self _renderProjects:[self _getUnrenderedProjectsForKeys:_arg] withDetail:_detail];
}

-(id)_getProjectsForKeys:(id)_pk {
  [self logWithFormat:@"_getProjectsForKeys([%@])", _pk];
  return [self _getProjectsForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getProjectForKey:(id)_pk withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getProjectForKey([%@],[%@])", _pk, _detail];
  return [[self _getProjectsForKeys:_pk withDetail:_detail] objectAtIndex:0];
}

-(id)_getProjectForKey:(id)_pk {
  [self logWithFormat:@"_getProjectForKey([%@])", _pk];
  return [[self _getProjectsForKeys:_pk withDetail:[NSNumber numberWithInt:0]] objectAtIndex:0];
}

/* Get Companies Assigned To Project
    Used by _addContactsToProject and _addEnterprisesToProject
 */
-(NSArray *)_getProjectAssignments:(EOGenericRecord *)_eoProject {
  if ([_eoProject valueForKey:@"companyAssignments"] == nil) {
    [[self getCTX] runCommand:@"project::get-company-assignments",
                              @"object", _eoProject,
                              @"relationKey", @"companyAssignments", nil];
   }
  return [_eoProject valueForKey:@"companyAssignments"];
}

/* Add the _CONTACTS key to the project
 */
-(void)_addContactsToProject:(NSMutableDictionary *)_project {
  NSArray             *assignments;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableArray      *contactList;
  NSMutableDictionary *assignment;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  contactList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) {
    if (([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]] 
              isEqualToString:@"Person"]) &&
        ([[eo valueForKey:@"hasAccess"] intValue] == 0)) {
      assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                    source:[eo valueForKey:@"projectId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [contactList addObject:assignment];
     }
   }
  [_project setObject:contactList forKey:@"_CONTACTS"];
}

/* Add the _ENTERPRISES key to the project
 */
-(void)_addEnterprisesToProject:(NSMutableDictionary *)_project {
  NSArray             *assignments;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableArray      *enterpriseList;
  NSMutableDictionary *assignment;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  enterpriseList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];

  while ((eo = [enumerator nextObject]) != nil) {
    if (([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Enterprise"]) &&
        ([[eo valueForKey:@"hasAccess"] intValue] == 0)) {
      assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                    source:[eo valueForKey:@"projectId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [enterpriseList addObject:assignment];
     }
   }
  [_project setObject:enterpriseList forKey:@"_ENTERPRISES"];
}

-(void)_addParticipantsToProject:(NSMutableDictionary *)_project {
  NSArray         *assignments;
  NSEnumerator    *enumerator;
  EOGenericRecord *assignment;
  NSMutableArray  *memberList;
  NSString        *entityName;
  NSNumber        *companyId;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  memberList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((assignment = [enumerator nextObject]) != nil) { 
    if ([[assignment valueForKey:@"hasAccess"] intValue] == 1) {
      companyId = [assignment valueForKey:@"companyId"];
      entityName = [self _izeEntityName:[self _getEntityNameForPKey:companyId]];
      [memberList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         companyId, @"targetObjectId",
         [self NIL:[assignment valueForKey:@"accessRight"]], @"accessRight",
         [self NIL:[assignment valueForKey:@"info"]], @"info",
         [assignment valueForKey:@"projectId"], @"sourceObjectId",
         @"Project", @"sourceEntityname",
         [assignment valueForKey:@"projectCompanyAssignmentId"], @"objectId",
         @"assignment", @"entityName",
         entityName, @"targetEntityName",
         nil]];
     }
   }
  [_project setObject:memberList forKey:@"_PARTICIPANTS"];
}

/* Add _NOTES Key To Project
 */
-(void)_addNotesToProject:(NSMutableDictionary *)_project {
  NSArray        *notes;

  notes = [self _getNotesForKey:[_project valueForKey:@"objectId"]];
  [_project setObject:notes forKey:@"_NOTES"];
}

/* Add _TASKS Key To Project
 */
-(void)_addTasksToProject:(NSMutableDictionary *)_project {
  NSMutableArray *taskList;
  NSArray        *tasks;
  NSEnumerator   *enumerator;
  EOGenericRecord *task;

  [self logWithFormat:@"*****_addTasksToProject*******"];
  tasks =  [[self getCTX] 
               runCommand:@"project::get-jobs",
                          @"object", [_project objectForKey:@"*eoObject"],
                          nil];
  if (tasks == nil) 
    tasks = [NSArray array];
  taskList = [[NSMutableArray alloc] initWithCapacity:[tasks count]];
  enumerator = [tasks objectEnumerator];
  while ((task = [enumerator nextObject]) != nil) {
    [taskList addObject:[self _renderTaskFromEO:task]];
   }
  [_project setObject:taskList forKey:@"_TASKS"];
}

-(NSArray *)_getFavoriteProjects:(NSNumber *)_detail {
  NSArray      *favoriteIds;

  favoriteIds = [[self getCTX] runCommand:@"project::get-favorite-ids", nil];
  return [self _getProjectsForKeys:favoriteIds withDetail:_detail];
}

-(void)_unfavoriteProject:(NSString *)projectId {
  [[self getCTX] runCommand:@"project::remove-favorite",
                            @"projectId", projectId,
                            nil];
}

-(void)_favoriteProject:(NSString *)projectId {
  [[self getCTX] runCommand:@"project::add-favorite",
                            @"projectId", projectId,
                            nil];
}

-(id)_searchForProjects:(NSDictionary *)_query 
             withDetail:(NSNumber *)_detail {
  NSMutableDictionary   *query;
  NSArray               *keys, *result;
  NSString              *key;
  id                    value;
  int                   count;
  

  query = [[NSMutableDictionary alloc] initWithCapacity:[_query count]];
  keys = [_query allKeys];
  for (count = 0; count < [keys count]; count++) {
    key = [keys objectAtIndex:count];
    value = [_query objectForKey:key];
    if ([key isEqualToString:@"objectId"]) {
      [query setObject:value forKey:@"projectId"];
    } else if ([key isEqualToString:@"ownerObjectId"]) {
      [query setObject:value forKey:@"ownerId"];
    } else if ([key isEqualToString:@"placeHolder"]) {
      [query setObject:value forKey:@"isFake"];
    } else if ([key isEqualToString:@"placeHolder"]) {
      [query setObject:value forKey:@"isFake"];
    } else if ([key isEqualToString:@"conjunction"]) {
      /* TODO: Verify this is AND or OR */
      [query setObject:value forKey:@"operator"];
    } else [query setObject:value forKey:key];
   }
  /*
  if ([query objectForKey:@"operator"] == nil)
    [query setObject:[NSString stringWithString:@"AND"] forKey:@"operator"];
   */
  if ([query objectForKey:@"operator"] == nil)
    result = [[self getCTX] runCommand:@"project::get" arguments:query];
   else
     result = [[self getCTX] runCommand:@"project::extended-search"
                              arguments:query];
  return [self _renderProjects:result withDetail:_detail];
}

/* Translate Entity To Project
     TODO: Deal with subkeys
 */
-(id)_translateProject:(NSDictionary *)_project {
  NSMutableDictionary	*project;
  NSCalendarDate        *start, *end;
  
  project = [[NSMutableDictionary alloc] initWithCapacity:12];
  [project setObject:[_project objectForKey:@"name"] forKey:@"name"];
  if ([_project objectForKey:@"objectId"] != nil) {
    /* Updating existing project */
    [project setObject:[_project objectForKey:@"objectId"] forKey:@"projectId"];
    [project setObject:[_project objectForKey:@"number"] forKey:@"number"];
   } else {
       /* Setting up for new project */
       if ([_project objectForKey:@"number"] != nil)
         [project setObject:[_project objectForKey:@"number"] forKey:@"number"];
      }
  /* Translating other object attributes */
  if ([_project objectForKey:@"kind"] != nil)
    [project setObject:[_project objectForKey:@"kind"] forKey:@"kind"];
   else
     [project setObject:[EONull null] forKey:@"kind"];
  if ([_project objectForKey:@"version"] != nil)
    [project setObject:[_project objectForKey:@"version"] 
                forKey:@"objectVersion"];
  if ([_project objectForKey:@"placeHolder"] != nil)
    [project setObject:[_project objectForKey:@"placeHolder"] forKey:@"isFake"];
   else
     [project setObject:[NSNumber numberWithBool:NO] forKey:@"isFake"];
  if ([_project objectForKey:@"ownerObjectId"] != nil)
    [project setObject:[_project objectForKey:@"ownerObjectId"] 
                forKey:@"ownerId"];
   else [project setObject:[self _getCompanyId] forKey:@"ownerId"];
  if ([_project objectForKey:@"status"] != nil)
    [project setObject:[_project objectForKey:@"status"] forKey:@"status"];
  if ([_project objectForKey:@"comment"] != nil)
    [project setObject:[_project objectForKey:@"comment"] forKey:@"comment"];
  /* Deal with start and end date, these seem to be required fields */
  if ([_project objectForKey:@"startDate"] == nil) {
    start = [NSCalendarDate calendarDate];
   } else {
       start = [self _makeCalendarDate:[_project objectForKey:@"startDate"]];
       if (start == nil)
         return [NSException exceptionWithHTTPStatus:500
                   reason:@"Invalid start date specified for project"];
     }
  [start setTimeZone:[self _getTimeZone]];
  if ([_project objectForKey:@"endDate"] == nil) {
    end = [self _makeCalendarDate:@"2032-12-31 18:59"];
   } else {
       end = [self _makeCalendarDate:[_project objectForKey:@"endDate"]];
       if (end == nil)
         return [NSException exceptionWithHTTPStatus:500
                   reason:@"Invalid end date specified for project"];
      }
  [end setTimeZone:[self _getTimeZone]];
  [project setObject:end forKey:@"endDate"];
  [project setObject:start forKey:@"startDate"];
  return project;
}

/* Create a new project 
     TODO: Support sub-keys
 */
-(id)_createProject:(NSDictionary *)dictionary 
          withFlags:(NSArray *)_flags {
  id project;

  [self logWithFormat:@"_createProject"];
  project = [self _translateProject:dictionary];
  if ([project class] == [NSException class])
    return project;
  project = [[self getCTX] runCommand:@"project::new" 
                            arguments:project];
  if ([project class] == [NSException class]) {
    [[self getCTX] rollback];
    return project;
   }
  [[self getCTX] commit];
  project = [self _getProjectForKey:[project objectForKey:@"projectId"]
                         withDetail:[NSNumber numberWithInt:65535]];
  return project;
}

/* Update an existing project 
   TODO: Implement
 */
-(id)_updateProject:(NSDictionary *)dictionary 
           objectId:(NSString *)objectId 
          withFlags:(NSArray *)_flags {
  id project;

  [self logWithFormat:@"_updateProject"];
  project = [self _translateProject:dictionary];
  if ([project class] == [NSException class])
    return project;
  project = [[self getCTX] runCommand:@"project::set" 
                            arguments:project];
  if ([project class] == [NSException class]) {
    [[self getCTX] rollback];
    return project;
   }
  [[self getCTX] commit];
  project = [self _getProjectForKey:[project objectForKey:@"projectId"]
                         withDetail:[NSNumber numberWithInt:65535]];
  return project;
}

@end /* End zOGIAction(Project) */
