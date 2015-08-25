/*
  zOGIAction+Task.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Task_H__
#define __zOGIAction_Task_H__

#include "zOGIAction.h"

@interface zOGIAction(Task)

-(NSMutableDictionary *)_renderTaskFromEO:(EOGenericRecord *)_task;
-(NSMutableDictionary *)_renderTask:(EOGenericRecord *)_task withDetail:(NSNumber *)_detail;
-(NSArray *)_renderTasks:(NSArray *)_tasks withDetail:(NSNumber *)_detail;
-(id)_getUnrenderedTasksForKeys:(id)_arg;
-(id)_getTasksForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getTasksForKeys:(id)_pk;
-(id)_getTaskForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getTaskForKey:(id)_pk;
-(id)_getTaskList:(NSString *)_list withDetail:(NSNumber *)_detail;
-(id)_createTaskNotation:(NSDictionary *)_notation;
-(id)_doTaskAction:(id)_pk action:(NSString *)_action 
                           withComment:(NSString *)_comment;
-(void)_addNotesToTask:(NSMutableDictionary *)_task;
-(NSString *)_getCommentFromHistoryEO:(EOGenericRecord *)_history;
-(id)_createTask:(NSDictionary *)_task;
-(id)_updateTask:(NSDictionary *)_task 
        objectId:(NSString *)objectId
       withFlags:(NSArray *)_flags;
-(NSMutableDictionary *)_fillTask:(NSDictionary *)_task;
-(void)_validateTask:(NSDictionary *)_task;
-(NSMutableDictionary *)_translateTask:(NSDictionary *)_task;
-(NSArray *)_searchForTasks:(id)_query withDetail:(NSNumber *)_detail;
@end

#endif /* __zOGIAction_Task_H__ */
