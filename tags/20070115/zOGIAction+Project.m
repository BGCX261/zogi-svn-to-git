/*
  zOGIAction+Project.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Project.h"
#include "zOGIAction+Task.h"

@implementation zOGIAction(Project)

-(NSArray *)_renderProjects:(NSArray *)_projects withDetail:(NSNumber *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoProject;
  int                  count;

  result = [NSMutableArray arrayWithCapacity:[_projects count]];
  for (count = 0; count < [_projects count]; count++) {
    eoProject = [_projects objectAtIndex:count];
    [[self getCTX] runCommand:@"project::get-root-document",
                              @"object", eoProject,
                              @"relationKey", @"rootDocument", 
                              nil];
    [self logWithFormat:@"_renderProject([%@])", eoProject];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoProject valueForKey:@"projectId"], @"objectId",
       @"Project", @"entityName",
       [self NIL:[eoProject valueForKey:@"objectVersion"]], @"version",
       [self NIL:[eoProject valueForKey:@"ownerId"]], @"ownerObjectId",
       [self NIL:[eoProject valueForKey:@"kind"]], @"kind",
       [self NIL:[eoProject valueForKey:@"isFake"]], @"placeHolder",
       [[eoProject valueForKey:@"rootDocument"] valueForKey:@"documentId"], 
         @"folderObjectId",
       [self NIL:[eoProject valueForKey:@"number"]], @"number",
       [self NIL:[eoProject valueForKey:@"name"]], @"name",
       [self NIL:[eoProject valueForKey:@"status"]], @"status",
       nil]];
     if([_detail intValue] > 0)
       [[result objectAtIndex:count] setObject:eoProject forKey:@"eoObject"];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       if([_detail intValue] & zOGI_INCLUDE_TASKS)
         [self _addTasksToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_NOTATIONS)
         [self _addNotesToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_CONTACTS)
         [self _addContactsToProject:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_ENTERPRISES)
         [self _addEnterprisesToProject:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
       [[result objectAtIndex:count] removeObjectForKey:@"eoObject"];
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
      [self runCommand:
            @"project::get-owner",
            @"objects",     pj,
            @"relationKey", @"owner", nil];
      [self runCommand:
            @"project::get-team",
            @"objects",     pj,
            @"relationKey", @"team", nil];
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

-(NSArray *)_getProjectAssignments:(EOGenericRecord *)_eoProject {
  if ([_eoProject valueForKey:@"companyAssignments"] == nil) {
    [[self getCTX] runCommand:@"project::get-company-assignments",
                              @"object", _eoProject,
                              @"relationKey", @"companyAssignments", nil];
   }
  return [_eoProject valueForKey:@"companyAssignments"];
}

-(void)_addContactsToProject:(NSMutableDictionary *)_project {
  NSArray         *assignments;
  NSEnumerator    *enumerator;
  EOGenericRecord *assignment;
  NSMutableArray  *contactList;

  [self logWithFormat:@"*****_addContactsToProject********"];
  assignments = [self _getProjectAssignments:[_project valueForKey:@"eoObject"]];
  contactList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((assignment = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:[assignment valueForKey:@"companyId"]] 
            isEqualToString:@"Person"]) {
      [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         [NSNull null], @"enterpriseObjectId",
         [self NIL:[assignment valueForKey:@"hasAccess"]], @"hasAccess",
         [self NIL:[assignment valueForKey:@"accessRight"]], @"accessRight",
         [self NIL:[assignment valueForKey:@"info"]], @"info",
         [self NIL:[assignment valueForKey:@"number"]], @"number",
         [assignment valueForKey:@"projectId"], @"projectObjectId",
         [assignment valueForKey:@"projectCompanyAssignmentId"], @"objectId",
         @"assignment", @"entityName",
         [assignment valueForKey:@"companyId"], @"contactObjectId",
         [NSNull null], @"isChief",  // only related to enterprise/contact assignments
         [NSNull null], @"function", // only related to enterprise/contact assignments
         [NSNull null], @"isHeadquarters", // only related to enterprise/contact assignments
         nil]];
     }
   }
  [_project setObject:contactList forKey:@"_CONTACTS"];
}

-(void)_addEnterprisesToProject:(NSMutableDictionary *)_project {
  NSArray         *assignments;
  NSEnumerator    *enumerator;
  EOGenericRecord *assignment;
  NSMutableArray  *enterpriseList;

  [self logWithFormat:@"*****_addEnterprisesToProject********"];
  assignments = [self _getProjectAssignments:[_project valueForKey:@"eoObject"]];
  enterpriseList = [[NSMutableArray alloc]initWithCapacity:[assignments count]];
  enumerator = [assignments objectEnumerator];
  while ((assignment = [enumerator nextObject]) != nil) {
    if ([[self _getEntityNameForPKey:[assignment valueForKey:@"companyId"]] 
            isEqualToString:@"Enterprise"]) {
      [enterpriseList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
         [assignment valueForKey:@"companyId"], @"enterpriseObjectId",
         [self NIL:[assignment valueForKey:@"hasAccess"]], @"hasAccess",
         [self NIL:[assignment valueForKey:@"accessRight"]], @"accessRight",
         [self NIL:[assignment valueForKey:@"info"]], @"info",
         [assignment valueForKey:@"projectId"], @"projectObjectId",
         [assignment valueForKey:@"projectCompanyAssignmentId"], @"objectId",
         @"assignment", @"entityName",
         [NSNull null], @"contactObjectId",
         [NSNull null], @"isChief",  // only related to enterprise/contact assignments
         [NSNull null], @"function", // only related to enterprise/contact assignments
         [NSNull null], @"isHeadquarters", // only related to enterprise/contact assignments
         nil]];
     }
   }
  [_project setObject:enterpriseList forKey:@"_ENTERPRISES"];
}

/*
    <EOGenericRecord: description ProjectCompanyAssignment attributes={
    accessRight = "";
    companyId = 21060;
    dbStatus = inserted;
    hasAccess = 0;
    info = "";
    projectCompanyAssignmentId = 31520;
    projectId = 29420;
}>
*/

-(void)_addNotesToProject:(NSMutableDictionary *)_project {
  NSMutableArray    *noteList;
  NSArray           *notes;
  EOGenericRecord   *note;
  int               count;

  noteList = [NSMutableArray new];
  notes = [[self getCTX]
              runCommand:@"note::get",
                         @"projectId", [_project valueForKey:@"objectId"],
                         @"returnType", intObj(LSDBReturnType_ManyObjects),
                         nil];
  if (notes == nil)
    notes = [NSArray array];
  [[self getCTX] runCommand:@"note::get-attachment-name", @"notes", notes, nil];
  for (count = 0; count < [notes count]; count++) {
    note = [notes objectAtIndex:count];
    [noteList addObject:
       [NSDictionary dictionaryWithObjectsAndKeys:
          [note valueForKey:@"documentId"], @"objectId",
          @"note", @"entityName",
          [note valueForKey:@"title"], @"title",
          [note valueForKey:@"firstOwnerId"], @"creatorObjectId",
          [note valueForKey:@"currentOwnerId"], @"ownerObjectId",
          [note valueForKey:@"creationDate"], @"createdTime",
          //[note valueForKey:@"creationDate"], @"createdTime",
          [_project valueForKey:@"objectId"], @"projectObjectId",
          [NSString stringWithContentsOfFile:[note valueForKey:@"attachmentName"]],
            @"content",
          [NSNull null], @"dateObjectId",
          nil]];
   }
  [_project setObject:noteList forKey:@"_NOTES"];
}

-(void)_addTasksToProject:(NSMutableDictionary *)_project {
  NSMutableArray *taskList;
  NSArray        *tasks;
  NSEnumerator   *enumerator;
  EOGenericRecord *task;

  [self logWithFormat:@"*****_addTasksToProject*******"];
  tasks =  [[self getCTX] 
               runCommand:@"project::get-jobs",
                          @"object", [_project objectForKey:@"eoObject"],
                          nil];
  if (tasks == nil) 
    tasks = [NSArray array];
   /* else
      [[self getCTX] runCommand:@"job::get-job-executants",
                                @"objects", tasks,
                                @"relationKey", @"executant", nil]; */
  taskList = [[NSMutableArray alloc] initWithCapacity:[tasks count]];
  enumerator = [tasks objectEnumerator];
  while ((task = [enumerator nextObject]) != nil) {
    [taskList addObject:[self _renderTaskFromEO:task]];
   }
  [_project setObject:taskList forKey:@"_TASKS"];
}

-(NSArray *)_getFavoriteProjects:(NSNumber *)_detail {
 return [self _getProjectsForKeys:[[self getCTX] runCommand:@"project::get-favorite-ids", nil] withDetail:_detail];
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

@end /* End zOGIAction(Project) */
