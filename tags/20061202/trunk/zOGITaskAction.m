/*
  zOGITaskAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGITaskAction.h"

@implementation zOGITaskAction

-(id)getTasksByObjectIdAction {
  [self logWithFormat:@"zogi.getTasksById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Task"])
    return [self _getTasksForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getTasksByListAction {
  NSArray      *taskList;

  [self logWithFormat:@"zogi.getTasksByList(%@)", arg1];
  taskList = [self _getTaskList:arg1 withDetail:arg2];
  [self logWithFormat:@"zogi.getTasksByList(%@) = %@", arg1, taskList];
  return taskList;
}

-(id)putTaskNotationAction {
  return [self _doTaskAction:arg1 action:arg2 withComment:arg3];
}

@end /* zOGITaskAction */
