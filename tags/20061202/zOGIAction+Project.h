/*
  zOGIAction+Project.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Project_H__
#define __zOGIAction_Project_H__

#include "zOGIAction.h"

@interface zOGIAction(Project)

-(NSArray *)_renderProjects:(NSArray *)_projects withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedProjectsForKeys:(id)_arg;
-(id)_getProjectsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getProjectsForKeys:(id)_pk;
-(id)_getProjectForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getProjectForKey:(id)_pk;
-(void)_addContactsToProject:(NSMutableDictionary *)_project;
-(void)_addEnterprisesToProject:(NSMutableDictionary *)_project;
-(void)_addNotesToProject:(NSMutableDictionary *)_project;
-(void)_addTasksToProject:(NSMutableDictionary *)_project;
-(void)_unfavoriteProject:(NSString *)projectId;
-(void)_favoriteProject:(NSString *)projectId;

@end

#endif /* __zOGIAction_Project_H__ */
