/*
  zOGIAction+Project.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Project_H__
#define __zOGIAction_Project_H__

#include "zOGIAction.h"

@interface zOGIAction(Project)

-(NSMutableArray *)_renderProjects:(NSArray *)_projects withDetail:(NSNumber *)_detail;
-(id)_getUnrenderedProjectsForKeys:(id)_arg;
-(id)_getProjectsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getProjectsForKeys:(id)_pk;
-(id)_getProjectForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getProjectForKey:(id)_pk;
-(void)_addContactsToProject:(NSMutableDictionary *)_project;
-(void)_addEnterprisesToProject:(NSMutableDictionary *)_project;
-(void)_addParticipantsToProject:(NSMutableDictionary *)_project;
-(void)_addNotesToProject:(NSMutableDictionary *)_project;
-(void)_addTasksToProject:(NSMutableDictionary *)_project;
-(NSArray *)_getFavoriteProjects:(NSNumber *)_detail;
-(void)_unfavoriteProject:(NSString *)projectId;
-(void)_favoriteProject:(NSString *)projectId;

-(id)_searchForProjects:(NSDictionary *)_query 
             withDetail:(NSNumber *)_detail;

-(id)_translateProject:(NSDictionary *)_project;

-(id)_createProject:(NSDictionary *)dictionary 
          withFlags:(NSArray *)_flags;

-(id)_updateProject:(NSDictionary *)dictionary 
           objectId:(NSString *)objectId 
          withFlags:(NSArray *)_flags;

-(id)_deleteProject:(id)_objectId
          withFlags:(NSArray *)_flags;

@end

#endif /* __zOGIAction_Project_H__ */
