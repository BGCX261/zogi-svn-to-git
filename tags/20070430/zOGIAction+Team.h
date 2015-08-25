/*
  zOGIAction+Team.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Team_H__
#define __zOGIAction_Team_H__

#include "zOGIAction.h"

@interface zOGIAction(Team)

-(NSArray *)_renderTeams:(NSArray *)_teams withDetail:(NSNumber *)_detail;
-(id)_getUnrenderedTeamsForKeys:(id)_arg;
-(id)_getTeamsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getTeamForKey:(id)_arg withDetail:(NSNumber *)_detail;
-(void)_addContactsToTeam:(NSMutableDictionary *)_team;

@end

#endif /* __zOGIAction_Team_H__ */
