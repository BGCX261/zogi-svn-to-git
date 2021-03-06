/*
  zOGIAction+Task.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Project.h"
#include "zOGIAction+Task.h"

@implementation zOGIAction(Task)

/*
  \brief Render a ZOGI Task From A Job EOGenericRecord
*/
-(NSMutableDictionary *)_renderTaskFromEO:(EOGenericRecord *)_task {
  NSMutableDictionary   *task;

  task = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [self NIL:[_task valueForKey:@"objectVersion"]], @"version",
            @"Task", @"entityName",
            [_task valueForKey:@"creatorId"], @"creatorObjectId",
            [_task valueForKey:@"jobId"], @"objectId",
            [self NIL:[_task valueForKey:@"isTeamJob"]], @"isTeamJob",
            [self NIL:[_task valueForKey:@"jobStatus"]], @"status",
            [self NIL:[_task valueForKey:@"endDate"]], @"end",
            [self NIL:[_task valueForKey:@"startDate"]], @"start",
            [self NIL:[_task valueForKey:@"executantId"]], @"executantObjectId",
            [self NIL:[_task valueForKey:@"priority"]], @"priority",
            [self NIL:[_task valueForKey:@"name"]], @"name",
            [self NIL:[_task valueForKey:@"keywords"]], @"keywords",
            [self NIL:[_task valueForKey:@"kind"]], @"kind",
            [self NIL:[_task valueForKey:@"category"]], @"category",
            [self NIL:[_task valueForKey:@"projectId"]], @"objectProjectId",
            [self NIL:[_task valueForKey:@"sensitivity"]], @"sensitivity",
            [self NIL:[_task valueForKey:@"totalWork"]], @"totalWork",
            [self NIL:[_task valueForKey:@"timerDate"]], @"timerDate",
            //[self NIL:[_task valueForKey:@"parentJobId"]], @"parentJobId",
            [self NIL:[_task valueForKey:@"percentComplete"]], @"percentComplete",
            [self NIL:[_task valueForKey:@"notify"]], @"notify",
            [self NIL:[_task valueForKey:@"kilometers"]], @"kilometers",
            [self NIL:[_task valueForKey:@"completionDate"]], @"completionDate",
            [self NIL:[_task valueForKey:@"comment"]], @"comment",
            [self NIL:[_task valueForKey:@"accountingInfo"]], @"accountingInfo",
            [self NIL:[_task valueForKey:@"actualWork"]], @"actualWork",
            [self NIL:[_task valueForKey:@"associatedCompanies"]], @"associatedCompanies",
            [self NIL:[_task valueForKey:@"associatedContacts"]], @"associatedContacts",
            [self NIL:[_task valueForKey:@"lastModified"]], @"lastModified",
            nil];
  return task;
}

-(NSMutableDictionary *)_renderTask:(EOGenericRecord *)_task 
                         withDetail:(NSNumber *)_detail {
  NSMutableDictionary   *task;
  
  task = [self _renderTaskFromEO:_task];
  if([_detail intValue] > 0) {
    [task setObject:_task forKey:@"*eoObject"];
    if([_detail intValue] & zOGI_INCLUDE_NOTATIONS)
      [self _addNotesToTask:task];
    [self _addObjectDetails:task withDetail:_detail];
   }
  return task;
}

/*
  \brief Render EOGenericRecords into dictionaries
  \param _tasks Array of EOGenericRecord Job objects
  \param _detail Specifies how much detail to add to dictionary
*/
-(NSArray *)_renderTasks:(NSArray *)_tasks withDetail:(NSNumber *)_detail {
  NSMutableDictionary  *task;
  NSMutableArray       *taskList;
  int                  count;

  [self logWithFormat:@"_renderTasks(...)"];
  taskList = [[NSMutableArray alloc] initWithCapacity:[_tasks count]];
  for (count = 0; count < [_tasks count]; count++)
    [taskList addObject:[self _renderTask:[_tasks objectAtIndex:count] 
                               withDetail:_detail]];
  return taskList;
} /* End _renderTasks */

-(id)_getUnrenderedTasksForKeys:(id)_arg {
  return [[[self getCTX] runCommand:@"job::get-by-globalid",
                                    @"gids", [self _getEOsForPKeys:_arg],
                                    nil] retain];
} /* End _getUnrenderedTasksForKeys */

-(id)_getTasksForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  return [self _renderTasks:[self _getUnrenderedTasksForKeys:_arg] withDetail:_detail];
} /* End _getTasksForKeys */

-(id)_getTasksForKeys:(id)_pk {
  [self logWithFormat:@"_getTasksForKeys([%@])", _pk];
  return [self _getTasksForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
} /* _getTasksForKeys */

-(id)_getTaskForKey:(id)_pk withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getTasksForKey([%@],[%@])", _pk, _detail];
  return [[self _getTasksForKeys:_pk withDetail:_detail] objectAtIndex:0];
} /* _getTasksForKey */

-(id)_getTaskForKey:(id)_pk {
  [self logWithFormat:@"_getTasksForKey([%@])", _pk];
  return [[self _getTasksForKeys:_pk 
                   withDetail:[NSNumber numberWithInt:0]] objectAtIndex:0];
} /* _getTasksForKey */

//TODO: Test
-(id)_getTaskList:(NSString *)_list withDetail:(NSNumber *)_detail {
  NSString       *listCommand;
  NSArray        *tasks, *taskList;

  [self logWithFormat:@"----_getTaskList(%@)-------<start>----", _list];  
  if ([_list isEqualToString:@"todo"])
    listCommand = [NSString stringWithString:@"job::get-todo-jobs"];
  if ([_list isEqualToString:@"control"])
    listCommand = [NSString stringWithString:@"job::get-control-jobs"];
  if ([_list isEqualToString:@"delegated"])
    listCommand = [NSString stringWithString:@"job::get-delegated-jobs"];
  if ([_list isEqualToString:@"archived"])
    listCommand = [NSString stringWithString:@"job::get-archived-jobs"];
  if ([_list isEqualToString:@"palm"])
    listCommand = [NSString stringWithString:@"job::get-palm-jobs"];

  tasks = [[self getCTX] runCommand:listCommand,
                          @"gid", [[self getCTX] valueForKey:LSAccountKey],
                          nil];
  taskList = [self _renderTasks:tasks withDetail:_detail];
  if (taskList == nil)
    [self logWithFormat:@"_getTaskList; taskList is nil"];
  [self logWithFormat:@"_getTaskList; end"];
  return taskList;
} /* _getTaskList */

-(id)_createTaskNotation:(NSDictionary *)_notation {
  // \todo Verification & gaurdian clauses
  [self logWithFormat:@"_createTaskNotation"];
  return [self _doTaskAction:[_notation objectForKey:@"taskObjectId"]
                      action:[_notation objectForKey:@"action"]
                 withComment:[_notation objectForKey:@"comment"]];
}

//TODO: Test
-(id)_doTaskAction:(id)_pk action:(NSString *)_action 
                           withComment:(NSString *)_comment {
  id                 result;
  EOGenericRecord   *task;
  NSDictionary      *args;
  NSDictionary      *notation;

  [self logWithFormat:@"_doTaskAction"];
  task = [[self _getUnrenderedTasksForKeys:_pk] lastObject];
  if (_comment != nil) {
    /* With Comment */
    [self logWithFormat:@"_doTaskAction; recording action with comment"];
    notation = [[self getCTX] runCommand:@"job::jobaction",
                                         @"object", task,
                                         @"action", _action,
                                         @"comment", _comment,
                                         nil];
   } else {
      /* No Comment */
      [self logWithFormat:@"_doTaskAction; recording action with no comment"];
      notation = [[self getCTX] runCommand:@"job::jobaction",
                                           @"object", task,
                                           @"action", _action,
                                           nil];
     }
  if (notation == nil) {
    [self logWithFormat:@"_doTaskAction; recording task action failed!"];
    return [NSException exceptionWithHTTPStatus:500
                        reason:@"Recording of task action failed."];
   }
  if ([notation isKindOfClass:[EOGenericRecord class]]) {
    if ([_action isEqualToString:@"accept"]) {
      [self logWithFormat:@"_doTaskAction; accepting job"];
      args = [NSDictionary dictionaryWithObjectsAndKeys:
                       [self _getCompanyId], @"executantId",
                       [task valueForKey:@"jobId"], @"jobId",
                       nil];
      result = [[self getCTX] runCommand:@"job::set" arguments:args];
      if (result == nil) {
        [self logWithFormat:@"_doTaskAction; accept of task failed!"];
        return [NSException exceptionWithHTTPStatus:500
                            reason:@"Accepting of task failed."];
       }
     } // End if _action == accpet
   } else {
       [[self getCTX] rollback];
       [self logWithFormat:@"_doTaskAction; rollback"];
       return [NSException exceptionWithHTTPStatus:500
                           reason:@"Task action resulting in unkown class"];
      }
  [[self getCTX] commit];
  [self logWithFormat:@"_doTaskAction; committed"];
  return [self _renderTask:[[self _getUnrenderedTasksForKeys:_pk] lastObject] 
                withDetail:[NSNumber numberWithInt:65535]];
} /* End doTaskAction */

-(void)_addNotesToTask:(NSMutableDictionary *)_task {
  NSMutableArray    *noteList;
  NSEnumerator      *enumerator;
  id                 annotation;
 
  noteList = [[NSMutableArray alloc] initWithCapacity:16];
  [[self getCTX] runCommand:@"job::get-job-history",
                            @"object", [_task valueForKey:@"*eoObject"],
                            @"relationKey", @"jobHistory", 
                            nil];
  enumerator = [[[_task valueForKey:@"*eoObject"] valueForKey:@"jobHistory"] objectEnumerator];
  while ((annotation = [enumerator nextObject]) != nil) {
    [noteList addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
       [annotation valueForKey:@"jobHistoryId"], @"objectId",
       @"taskNotation", @"entityName",
       [annotation valueForKey:@"action"], @"action",
       [annotation valueForKey:@"actionDate"], @"actionDate",
       [annotation valueForKey:@"jobId"], @"taskObjectId",
       [annotation valueForKey:@"jobStatus"], @"taskStatus",
       [annotation valueForKey:@"actorId"], @"actorObjectId",
       [self _getCommentFromHistoryEO:annotation], @"comment",
       nil]];
   }
  [_task setObject:noteList forKey:@"_NOTES"];
} /* End _addNotesToTask */

-(NSString *)_getCommentFromHistoryEO:(EOGenericRecord *)_history {
  EOGenericRecord   *infoRecord;

  infoRecord = [_history valueForKey:@"toJobHistoryInfo"];
  return [self NIL:[[infoRecord valueForKey:@"comment"] lastObject]];
} /* _getCommentFromHistoryEO */

/*
  \brief Create a job entry from dictionary
*/
-(id)_createTask:(NSDictionary *)_task {
  NSMutableDictionary   *taskDictionary;
  NSString              *executantEntityName;
  id		        taskObject;

  taskDictionary = [self _translateTask:[self _fillTask:_task]];
  [self _validateTask:taskDictionary];
  executantEntityName = 
    [self _getEntityNameForPKey:[taskDictionary objectForKey:@"executantId"]];
  if ([executantEntityName isEqualToString:@"Team"])
    [taskDictionary setObject:[NSNumber numberWithInt:1] forKey:@"isTeamJob"];
   else
     [taskDictionary setObject:[NSNumber numberWithInt:0] forKey:@"isTeamJob"];
  taskObject = [[self getCTX] runCommand:@"job::new" 
                              arguments:taskDictionary];
  if(taskObject == nil) {
    // \todo Throw exception when task is not created
    [self logWithFormat:@"_createTask():Task creation failed!!!"];
    [self logWithFormat:@"_createTask():Translated task was %@", taskDictionary];
    return [NSException exceptionWithHTTPStatus:500
                        reason:@"Failure to create task"];
   }
  [self _saveObjectLinks:[_task objectForKey:@"_OBJECTLINKS"] 
               forObject:[taskObject valueForKey:@"jobId"]];
  [self _saveProperties:[_task objectForKey:@"_PROPERTIES"]
              forObject:[taskObject valueForKey:@"jobId"]];
  [[self getCTX] commit];
  [self logWithFormat:@"_createTask(%@):commit completed", [taskObject valueForKey:@"jobId"]];
  return [self _renderTask:taskObject withDetail:[NSNumber numberWithInt:65535]];
}

/*
  \brief Update the task object
*/
-(id)_updateTask:(NSDictionary *)_task 
        objectId:(NSString *)objectId 
       withFlags:(NSArray *)_flags {
  id    task;

  [self logWithFormat:@"_updateTask"];
  if(![self _checkEntity:[_task valueForKey:@"objectId"] entityName:@"Task"]) {
    // \todo Throw exception, this is not a task
    return [NSException exceptionWithHTTPStatus:500
                        reason:@"Update of task requested for non-task object"];
   }

  [self _validateTask:_task];
  task = [[self getCTX] runCommand:@"job::set" 
                        arguments:[self _translateTask:_task]];
  if (task == nil) {
    return [NSException exceptionWithHTTPStatus:500
                        reason:@"Update of task failed"];
   }
  // \todo deal with failure to update
  if ([_task objectForKey:@"_OBJECTLINKS"] != nil)
    [self _saveObjectLinks:[_task objectForKey:@"_OBJECTLINKS"] 
                 forObject:objectId];
  if ([_task objectForKey:@"_PROPERTIES"] != nil)
    [self _saveProperties:[_task objectForKey:@"_PROPERTIES"] 
                forObject:objectId];
  [[self getCTX] commit];
  [self logWithFormat:@"_updateTask:committed"];
  return [self _renderTask:task withDetail:[NSNumber numberWithInt:65535]];
}

/*
  \brief Fill the empty fields in a new task
  \note Will turn the NSDictionary into a NSMutableDictionary
*/
-(NSMutableDictionary *)_fillTask:(NSDictionary *)_task {
  NSMutableDictionary		*task;
  NSCalendarDate		*startDate;
  NSCalendarDate		*endDate;
  NSString                      *emptyString;

  task = [[NSMutableDictionary alloc] initWithCapacity:32];
  [task addEntriesFromDictionary:_task];
  emptyString = [NSString stringWithString:@""];
  // Name (description)
  if([task objectForKey:@"name"] == nil)
	[task setObject:[NSString stringWithString:@"Unnamed Task"]
          forKey:@"name"];
  // Executant
  if([_task objectForKey:@"executantObjectId"] == nil)
    [task setObject:[[[self getCTX] valueForKey:LSAccountKey] valueForKey:@"companyId"]
          forKey:@"executantObjectId"];
  // Start
  if([task objectForKey:@"start"] == nil) {
    startDate = [NSCalendarDate date];
    [startDate dateByAddingYears:0 months:0 days:7];
    [startDate setTimeZone:[self _getTimeZone]];
    [task setObject:startDate forKey:@"start"];
   }
  // End
  if([task objectForKey:@"end"] == nil) {
    endDate = [NSCalendarDate date];
    [endDate setTimeZone:[self _getTimeZone]];
    endDate = [endDate dateByAddingYears:0 months:0 days:7];
    [task setObject:endDate forKey:@"end"];
   }
  // Category & Associations
  if([task objectForKey:@"category"] == nil)
    [task setObject:emptyString forKey:@"category"];
  if([task objectForKey:@"associatedCompanies"] == nil)
    [task setObject:emptyString forKey:@"associatedCompanies"];
  if([task objectForKey:@"associatedContacts"] == nil)
    [task setObject:emptyString forKey:@"associatedContacts"];
  [self logWithFormat:@"_fillTask(...);Task=%@", task];
  return task;
}

/*
  \brief Check that the contents of the _task are valid
*/
-(void)_validateTask:(NSDictionary *)_task {
  [self logWithFormat:@"_validateTask([%@])", _task];
}

/*
  \brief Move a ZOGI dictionary to something the OGo Logic layer wants to see
*/
-(NSMutableDictionary *)_translateTask:(NSDictionary *)_task {
  NSMutableDictionary   *task;
  NSCalendarDate        *dateValue;
  NSArray               *keys;
  NSString              *key;
  int                   projectId;
  id                    objectId;
  int                   count;

  objectId = [_task objectForKey:@"objectId"];
  if (objectId == nil)
    objectId = [NSString stringWithString:@"0"];
  else if ([objectId isKindOfClass:[NSNumber class]])
    objectId = [objectId stringValue];

  task = [[NSMutableDictionary alloc] initWithCapacity:32];
  keys = [_task allKeys];
  for (count = 0; count < [keys count]; count++) {
    key = [keys objectAtIndex:count];
    if ([key isEqualToString:@"executantObjectId"]) {
      [task setObject:[_task objectForKey:@"executantObjectId"] 
               forKey:@"executantId"];
    } else if ([key isEqualToString:@"objectProjectId"]) {
      projectId = [[_task objectForKey:key] intValue];
      if (projectId == 0)
        [task setObject:[NSNull null] forKey:@"projectId"];
        else [task setObject:[NSNumber numberWithInt:projectId]
                      forKey:@"projectId"];
    } else if ([key isEqualToString:@"parentTaskObjectId"]) {
      // We are currently droping this attribute as the guts of
      // OGo seem to do something odd when they see it and 
      // produce an error
      //[task setObject:[_task objectForKey:@"parentTaskObjectId"] 
      //      forKey:@"parentJobId"];
      [self logWithFormat:@"_translateTask(); key %@ dropped", key];
    } else if ([key isEqualToString:@"kind"]) {
      if (![[_task objectForKey:@"kind"] isEqualToString:@""])
        [task setObject:[_task objectForKey:@"kind"]
              forKey:@"kind"];
    } else if ([key isEqualToString:@"objectId"]) {
      // Only translate this attribute if it has a non-zero value
      if ([objectId isEqualToString:@"0"]) {
        [self logWithFormat:@"_translateTask(); dropping objectId"];
      } else { 
          [task setObject:[_task objectForKey:@"objectId"] forKey:@"jobId"];
         }
    } else if ([key isEqualToString:@"entityName"] ||
               [key isEqualToString:@"isTeamJob"]) {
      // These atttributes are deliberately dropped
      [self logWithFormat:@"_translateTask(); key %@ dropped", key];
    } else if ([[key substringToIndex:1] isEqualToString:@"_"]) {
      [self logWithFormat:@"_translateTask(); subkey %s dropped", key];
    } else if ([key isEqualToString:@"start"] ||
               [key isEqualToString:@"end"]) {
         dateValue = [self _makeCalendarDate:[_task objectForKey:key]];
         if ([key isEqualToString:@"start"])
           [task setObject:dateValue forKey:@"startDate"];
           else [task setObject:dateValue forKey:@"endDate"];
    } else {
        [task setObject:[_task objectForKey:key] forKey:key];
       }
   } // End for loop through keys
  [self logWithFormat:@"_translateTask([%@])=%@", _task, task];
  return task;
}

-(NSArray *)_searchForTasks:(id)_query withDetail:(NSNumber *)_detail {
 // Task query supports a simple query where _query is a string
 // specifying a task list.
 if ([_query isKindOfClass:[NSString class]]) {
   return [self _getTaskList:_query withDetail:_detail];
  }
 return AUTORELEASE([[NSArray alloc] init]);
} /* End _searchForTasks */

@end /* End zOGIAction(Task) */
