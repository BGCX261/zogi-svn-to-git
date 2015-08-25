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
  for (count = 0; count < [_tasks count]; count++) {
    task = [self _renderTaskFromEO:[_tasks objectAtIndex:count]];
    if([_detail intValue] > 0) {
      [task setObject:[_tasks objectAtIndex:count] forKey:@"eoObject"];
       if([_detail intValue] & zOGI_INCLUDE_NOTATIONS)
         [self _addNotesToTask:task];
      [self _addObjectDetails:task withDetail:_detail];
      [task removeObjectForKey:@"eoObject"];
     }
    [taskList addObject:task];
   }
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

  /// Can we use a gid here?  Original code is
  /// jobs = [[self getCTX] runCommand:listCommand, @"object", person, nil];
  tasks = [[self getCTX] runCommand:listCommand,
                          @"gid", [[self getCTX] valueForKey:LSAccountKey],
                          nil];
  taskList = [self _renderTasks:tasks withDetail:_detail];
  if (taskList == nil)
    [self logWithFormat:@"_getTaskList(...) - taskList is nil"];
  [self logWithFormat:@"----_getTaskList(...)-------<end>----"];
  return taskList;
} /* _getTaskList */

//TODO: Test
-(id)_doTaskAction:(id)_pk action:(NSString *)_action 
                           withComment:(NSString *)_comment {
  id result;
  EOGenericRecord   *task, *attributes;

  task = [[self _getUnrenderedTasksForKeys:_pk] lastObject];
  if (_comment != nil) 
    /* With Comment */
    result = [[self getCTX] runCommand:@"job::jobaction",
                                       @"object", task,
                                       @"action", _action,
                                       @"comment", _comment,
                                       nil];
   else
     /* No Comment */
     result = [[self getCTX] runCommand:@"job::jobaction",
                                        @"object", task,
                                        @"action", _action,
                                         nil];
  if ([result isKindOfClass:[EOGenericRecord class]]) {
    if ([_action isEqualToString:@"accept"] &&
        [[task valueForKey:@"isTeamJob"] boolValue]) {
          attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[[self getCTX] valueForKey:LSAccountKey]
                                          valueForKey:@"companyId"],
                                          @"executantId",
                                          [task valueForKey:@"jobId"],
                                          @"jobId",
                                          nil];

          result = [ctx runCommand:@"job::set",
                    @"attributes", attributes,
                    nil];
     }
    if ([result isKindOfClass:[EOGenericRecord class]]) {
      [[self getCTX] commit];
      return [NSNumber numberWithInt:1];
     }
   }
  [[self getCTX] rollback];
  return [NSNumber numberWithInt:0];
} /* End doTaskAction */

-(void)_addNotesToTask:(NSMutableDictionary *)_task {
  NSMutableArray    *noteList;
  NSEnumerator      *enumerator;
  id                 annotation;
 
  noteList = [[NSMutableArray alloc] initWithCapacity:16];
  [[self getCTX] runCommand:@"job::get-job-history",
                            @"object", [_task valueForKey:@"eoObject"],
                            @"relationKey", @"jobHistory", 
                            nil];
  enumerator = [[[_task valueForKey:@"eoObject"] valueForKey:@"jobHistory"] objectEnumerator];
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
-(NSMutableDictionary *)_createTask:(NSDictionary *)_task {
  NSMutableDictionary   *taskDictionary;
  id				    taskObject;

  [self logWithFormat:@"_createTask([%@])", _task];

  taskDictionary = [self _fillTask:_task];
  [self _validateTask:taskDictionary];
  taskObject = [[self getCTX] runCommand:@"job::new" 
                              arguments:[self _translateTask:taskDictionary]];
  if(taskObject == nil) {
    // \todo Throw exception when task is not created
   }
  [[self getCTX] commit];
  return [[self _renderTasks:[NSArray arrayWithObject:taskObject] 
                             withDetail:[NSNumber numberWithInt:65535]
          ] objectAtIndex:0];
}

/*
  \brief Update the task object
*/
-(NSMutableDictionary *)_updateTask:(NSDictionary *)_task objectId:(NSString *)objectId {
  id    task;

  [self logWithFormat:@"_updateTask([%@])", _task];
  if(![self _checkEntity:[_task valueForKey:@"objectId"] entityName:@"Task"]) {
    // \todo Throw exception, this is not a task
   }

  [self _validateTask:_task];
  task = [[self getCTX] runCommand:@"job::set" 
                        arguments:[self _translateTask:_task]];
  if (task == nil) {
   }
  [[self getCTX] commit];
  [self logWithFormat:@"_updateTask(...):committed"];
  // \todo deal with failure to update
  return [[self _renderTasks:[NSArray arrayWithObject:task] 
                             withDetail:[NSNumber numberWithInt:65535]
          ] objectAtIndex:0];
}

/*
  \brief Fill the empty fields in a new task
  \note Will turn the NSDictionary into a NSMutableDictionary
*/
-(NSMutableDictionary *)_fillTask:(NSDictionary *)_task {
  NSMutableDictionary	*task;
  NSCalendarDate		*startDate;
  NSCalendarDate		*endDate;

  task = [[NSMutableDictionary alloc] initWithCapacity:32];
  [task addEntriesFromDictionary:_task];
  // Name (description)
  if([task objectForKey:@"name"] == nil)
	[task setObject:[NSString stringWithString:@"Unnamed Task"]
          forKey:@"name"];
  // Executant
  if([_task objectForKey:@"executantObjectId"] == nil)
    [task setObject:[[[self getCTX] valueForKey:LSAccountKey] valueForKey:@"companyId"]
          forKey:@"executantObjectId"];
  // Start
  if([task objectForKey:@"startDate"] == nil) {
    startDate = [NSCalendarDate date];
    [startDate dateByAddingYears:0 months:0 days:7];
    [startDate setTimeZone:[self _getTimeZone]];
    [task setObject:startDate forKey:@"startDate"];
   }
  // End
  if([task objectForKey:@"endDate"] == nil) {
    endDate = [NSCalendarDate date];
    [endDate setTimeZone:[self _getTimeZone]];
    endDate = [endDate dateByAddingYears:0 months:0 days:7];
    [task setObject:endDate forKey:@"endDate"];
   }
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
-(NSDictionary *)_translateTask:(NSDictionary *)_task {
  NSMutableDictionary   *task;
  NSArray               *keys;
  NSString              *key;
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
    } else if ([key isEqualToString:@"projectObjectId"]) {
      [task setObject:[_task objectForKey:@"projectObjectId"] 
            forKey:@"projectId"];
    } else if ([key isEqualToString:@"parentTaskObjectId"]) {
      // We are currently droping this attribute as the guts of
      // OGo seem to do something odd when they see it and 
      // produce an error
      //[task setObject:[_task objectForKey:@"parentTaskObjectId"] 
      //      forKey:@"parentJobId"];
    } else if ([key isEqualToString:@"objectId"]) {
      // Only translate this attribute if it has a non-zero value
      if ([objectId isEqualToString:@"0"]) {
        [self logWithFormat:@"_translateTask(); dropping objectId"];
      } else { 
          [task setObject:[_task objectForKey:@"objectId"] forKey:@"jobId"];
         }
    } else if ([key isEqualToString:@"entityName"]) {
      // These atttributes are deliberately dropped
      [self logWithFormat:@"_translateTask(); key %s dropped", key];
    } else if ([[key substringToIndex:0] isEqualToString:@"_"]) {
      [self logWithFormat:@"_translateTask(); subkey %s dropped", key];
    } else {
        [task setObject:[_task objectForKey:key] forKey:key];
       }
   } // End for loop through keys
  [self logWithFormat:@"_translateTask([%@])=%@", _task, task];
  return task;
}

@end /* End zOGIAction(Task) */
