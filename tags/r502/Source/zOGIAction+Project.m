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

-(NSMutableArray *)_renderProjects:(NSArray *)_projects withDetail:(NSNumber *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoProject;
  int                  count;
  NSString            *comment;

  result = [NSMutableArray arrayWithCapacity:[_projects count]];
  for (count = 0; count < [_projects count]; count++) 
  {
    eoProject = [_projects objectAtIndex:count];
    [[self getCTX] runCommand:@"project::get-root-document",
                              @"object", eoProject,
                              @"relationKey", @"rootDocument", 
                              nil];
    [[self getCTX] runCommand:@"project::get-comment",
                              @"object", eoProject, 
                              @"relationKey", @"comment", 
                              nil];
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
    {
      [[result objectAtIndex:count] setObject:eoProject forKey:@"*eoObject"];
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
      [self _stripInternalKeys:[result objectAtIndex:count]];
    } /* End if-detail-required */
  } /* End rendering-loop */
  return result;
}

/* Get the specified projects from Logic.  This function may return fewer 
   projects then requested if an id is invalid or not a project,  it may
   also return a non-array if some kind of error occurs in Logic.  On
   success an NSMutableArray object is returned. */
-(id)_getUnrenderedProjectsForKeys:(id)_arg 
{
  id               projects;

  projects = [[[self getCTX] runCommand:@"project::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] mutableCopy];
  if (([projects isKindOfClass:[NSException class]]) && ([self isDebug]))
    [self logWithFormat:@"Exception occurred retrieving projects from Logic"];
  return projects;
} /* End _getUnrenderedProjectsForKeys */

/* Get the specified projects at the specified detail level */
-(id)_getProjectsForKeys:(id)_arg withDetail:(NSNumber *)_detail 
{
  id               result;

  result = [self _renderProjects:[self _getUnrenderedProjectsForKeys:_arg] 
                      withDetail:_detail];
  if (([result isKindOfClass:[NSException class]]) ||
      ([result isKindOfClass:[NSMutableArray class]]))
    return result;
  if ([self isDebug])
    [self logWithFormat:@"Unexpected type received from _renderProjects"];  
  return  [NSException exceptionWithHTTPStatus:500
             reason:@"Unexpected type received from _renderProjects"];
} /* End _getProjectsForKeys */

/* Get the specified projects at the default detail level (0) */
-(id)_getProjectsForKeys:(id)_pk 
{
  return [self _getProjectsForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
} /* End _getProjectsForKeys */

/* Get the specified project at the specified detail level */
-(id)_getProjectForKey:(id)_pk withDetail:(NSNumber *)_detail 
{
  id               result;

  result = [self _getProjectsForKeys:_pk withDetail:_detail];
  if ([result isKindOfClass:[NSException class]])
    return result;
  if ([result isKindOfClass:[NSMutableArray class]])
    if([result count] == 1)
      return [result objectAtIndex:0];
  return nil;
} /* End _getProjectForKey */

/* Get the specified project at the default detail level (0) */
-(id)_getProjectForKey:(id)_pk 
{
  return [self _getProjectForKey:_pk withDetail:[NSNumber numberWithInt:0]];
} /* End _getProjectForKey */

/* Get Companies Assigned To Project
    Used by _addContactsToProject and _addEnterprisesToProject */
-(NSArray *)_getProjectAssignments:(EOGenericRecord *)_eoProject 
{
  if ([_eoProject valueForKey:@"companyAssignments"] == nil) 
  {
    [[self getCTX] runCommand:@"project::get-company-assignments",
                              @"object", _eoProject,
                              @"relationKey", @"companyAssignments", nil];
  }
  return [_eoProject valueForKey:@"companyAssignments"];
}

/* Add the _CONTACTS key to the project
   Uses _getProjectAssignments */
-(void)_addContactsToProject:(NSMutableDictionary *)_project 
{
  NSArray             *assignments;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableArray      *contactList;
  NSMutableDictionary *assignment;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  contactList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((eo = [enumerator nextObject]) != nil) 
  {
    if (([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]] 
              isEqualToString:@"Person"]) &&
        ([[eo valueForKey:@"hasAccess"] intValue] == 0)) 
    {
      assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                    source:[eo valueForKey:@"projectId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [contactList addObject:assignment];
    } /* End if-assignee-is-a-person */
  } /* End loop-through-assignees */
  [_project setObject:contactList forKey:@"_CONTACTS"];
} /* End _addContactsToProject */

/* Add the _ENTERPRISES key to the project
   Uses _getProjectAssignments */
-(void)_addEnterprisesToProject:(NSMutableDictionary *)_project 
{
  NSArray             *assignments;
  NSEnumerator        *enumerator;
  EOGenericRecord     *eo;
  NSMutableArray      *enterpriseList;
  NSMutableDictionary *assignment;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  enterpriseList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];

  while ((eo = [enumerator nextObject]) != nil) 
  {
    if (([[self _getEntityNameForPKey:[eo valueForKey:@"companyId"]]
              isEqualToString:@"Enterprise"]) &&
        ([[eo valueForKey:@"hasAccess"] intValue] == 0)) 
    {
      assignment = [self _renderAssignment:[eo valueForKey:@"projectCompanyAssignmentId"]
                                    source:[eo valueForKey:@"projectId"]
                                    target:[eo valueForKey:@"companyId"]
                                        eo:eo];
      [enterpriseList addObject:assignment];
    } /* End if-assignee-is-an-enterpise */
  } /* End loop-through-assignees */
  [_project setObject:enterpriseList forKey:@"_ENTERPRISES"];
} /* End _addEnterprisesToProject */

-(void)_addParticipantsToProject:(NSMutableDictionary *)_project 
{
  NSArray         *assignments;
  NSEnumerator    *enumerator;
  EOGenericRecord *assignment;
  NSMutableArray  *memberList;
  NSString        *entityName;
  NSNumber        *companyId;

  assignments = [self _getProjectAssignments:[_project objectForKey:@"*eoObject"]];
  memberList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((assignment = [enumerator nextObject]) != nil) 
  { 
    /* What is going on here? */
    if ([[assignment valueForKey:@"hasAccess"] intValue] == 1) 
    {
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
} /* End _addParticipantsToProject */

/* Add _NOTES Key To Project */
-(void)_addNotesToProject:(NSMutableDictionary *)_project 
{
  NSArray        *notes;

  notes = [self _getNotesForKey:[_project valueForKey:@"objectId"]];
  [_project setObject:notes forKey:@"_NOTES"];
} /* End _addNotesToProject */

/* Add _TASKS Key To Project */
-(void)_addTasksToProject:(NSMutableDictionary *)_project 
{
  NSMutableArray *taskList;
  NSArray        *tasks;
  NSEnumerator   *enumerator;
  EOGenericRecord *task;

  tasks =  [[self getCTX] 
               runCommand:@"project::get-jobs",
                          @"object", [_project objectForKey:@"*eoObject"],
                          nil];
  if (tasks == nil) 
    tasks = [NSArray array];
  taskList = [[NSMutableArray alloc] initWithCapacity:[tasks count]];
  enumerator = [tasks objectEnumerator];
  while ((task = [enumerator nextObject]) != nil) 
  {
    [taskList addObject:[self _renderTaskFromEO:task]];
  }
  [_project setObject:taskList forKey:@"_TASKS"];
} /* End _addTasksToProject */

-(NSArray *)_getFavoriteProjects:(NSNumber *)_detail 
{
  NSArray      *favoriteIds;

  favoriteIds = [[self getCTX] runCommand:@"project::get-favorite-ids", nil];
  return [self _getProjectsForKeys:favoriteIds withDetail:_detail];
} /* End _getFavoriteProjects */

-(void)_unfavoriteProject:(NSString *)projectId 
{
  [[self getCTX] runCommand:@"project::remove-favorite",
                            @"projectId", projectId,
                            nil];
} /* End _unfavoriteProject */

-(void)_favoriteProject:(NSString *)projectId 
{
  [[self getCTX] runCommand:@"project::add-favorite",
                            @"projectId", projectId,
                            nil];
} /* End _favoriteProject */

/* Search for a project using provided criteria */
-(id)_searchForProjects:(NSDictionary *)_query 
             withDetail:(NSNumber *)_detail 
{
  NSMutableDictionary   *query;
  NSArray               *keys, *result;
  NSString              *key;
  id                    value;
  int                   count;
  

  query = [NSMutableDictionary dictionaryWithCapacity:[_query count]];
  keys = [_query allKeys];
  for (count = 0; count < [keys count]; count++) 
  {
    key = [keys objectAtIndex:count];
    value = [_query objectForKey:key];
    if ([key isEqualToString:@"objectId"]) 
      [query setObject:value forKey:@"projectId"];
    else if ([key isEqualToString:@"ownerObjectId"]) 
      [query setObject:value forKey:@"ownerId"];
    else if ([key isEqualToString:@"placeHolder"]) 
      [query setObject:value forKey:@"isFake"];
    else if ([key isEqualToString:@"conjunction"]) 
    {
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
} /* End _searchForProject */

/* Translate Entity To Project */
-(id)_translateProject:(NSDictionary *)_project 
{
  NSMutableDictionary	*project;
  NSCalendarDate        *start, *end;
  
  project = [[NSMutableDictionary alloc] initWithCapacity:12];
  [project setObject:[_project objectForKey:@"name"] 
              forKey:@"name"];
  if ([_project objectForKey:@"objectId"] != nil) 
  {
    /* Updating existing project */
    [project setObject:[_project objectForKey:@"objectId"] 
                forKey:@"projectId"];
    [project setObject:[_project objectForKey:@"number"] 
                forKey:@"number"];
  } else 
    {
       /* Setting up for new project */
       if ([_project objectForKey:@"number"] != nil)
         [project setObject:[_project objectForKey:@"number"] 
                     forKey:@"number"];
    }
  /* Translating other object attributes */
  /* Translate "kind", make sure is null if not provided */
  if ([_project objectForKey:@"kind"] != nil)
    [project setObject:[_project objectForKey:@"kind"] 
                forKey:@"kind"];
   else
     [project setObject:[EONull null] forKey:@"kind"];
  /* Translate version -> objectVersion */
  if ([_project objectForKey:@"version"] != nil)
    [project setObject:[_project objectForKey:@"version"] 
                forKey:@"objectVersion"];
  /* Translate placeHolder -> isFake */
  if ([_project objectForKey:@"placeHolder"] != nil)
    [project setObject:[_project objectForKey:@"placeHolder"] 
                forKey:@"isFake"];
   else
     [project setObject:[NSNumber numberWithBool:NO] 
                 forKey:@"isFake"];
  /* Translate ownerObjectId -> ownerId
     TODO: Do we need to do this?  Can we change the owner? */
  if ([_project objectForKey:@"ownerObjectId"] != nil)
    [project setObject:[_project objectForKey:@"ownerObjectId"] 
                forKey:@"ownerId"];
   else [project setObject:[self _getCompanyId] 
                    forKey:@"ownerId"];
  /* Translate status -> status */
  if ([_project objectForKey:@"status"] != nil)
    [project setObject:[_project objectForKey:@"status"] 
                forKey:@"status"];
  /* Translate comment -> comment */
  if ([_project objectForKey:@"comment"] != nil)
    [project setObject:[_project objectForKey:@"comment"] 
                forKey:@"comment"];
  /* Deal with start and end date, these seem to be required fields */
  if ([_project objectForKey:@"startDate"] == nil) 
  {
    start = [NSCalendarDate calendarDate];
  } else 
    {
      start = [self _makeCalendarDate:[_project objectForKey:@"startDate"]];
      if (start == nil)
        return [NSException exceptionWithHTTPStatus:500
                  reason:@"Invalid start date specified for project"];
    }
  [start setTimeZone:[self _getTimeZone]];
  if ([_project objectForKey:@"endDate"] == nil) 
  {
    end = [self _makeCalendarDate:@"2032-12-31 18:59"];
  } else 
    {
      end = [self _makeCalendarDate:[_project objectForKey:@"endDate"]];
      if (end == nil)
        return [NSException exceptionWithHTTPStatus:500
                  reason:@"Invalid end date specified for project"];
    }
  [end setTimeZone:[self _getTimeZone]];
  [project setObject:end forKey:@"endDate"];
  [project setObject:start forKey:@"startDate"];
  /* Return the translated project */
  return project;
} /* End _translateProject */

/* Create a new project 
     TODO: Support sub-keys such as assignments */
-(id)_createProject:(NSDictionary *)dictionary 
          withFlags:(NSArray *)_flags {
  id project;

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
} /* End _createProject */

/* Update an existing project 
   TODO: Test */
-(id)_updateProject:(NSDictionary *)dictionary 
           objectId:(NSString *)objectId 
          withFlags:(NSArray *)_flags {
  id project;

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
} /* End _updateProject */

/* Delete the specified project and all contents
   TODO: Implement
   QUESTION: What should happen to tasks?  Should they be deleted
     or just orphaned?  Perhaps that should be controlled by a
     flag? */
-(id)_deleteProject:(id)_objectId
          withFlags:(NSArray *)_flags
{
  id   project;

  project = [self _getUnrenderedProjectsForKeys:_objectId];
  if (project == nil)
    return [NSNumber numberWithBool:NO];
  if ([project isKindOfClass:[NSException class]])
    return project;
  if ([project isKindOfClass:[NSMutableArray class]])
  {
    if([project count] == 1)
    {
      project = [project lastObject];
      [project setObject:[NSNumber numberWithBool:YES] 
                  forKey:@"reallyDelete"];
      project = [[self getCTX] runCommand:@"project::delete"
                               arguments:project];
      if ([project isKindOfClass:[NSException class]])
        return [NSNumber numberWithBool:NO];
      [[self getCTX] commit];
      return [NSNumber numberWithBool:YES];
    }
  }
  return [NSNumber numberWithBool:NO];
}

@end /* End zOGIAction(Project) */
