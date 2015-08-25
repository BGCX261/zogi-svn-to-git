/*
  zOGIAction+Team.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Team.h"

@implementation zOGIAction(Team)

-(NSArray *)_renderTeams:(NSArray *)_teams withDetail:(NSNumber *)_detail {
  NSMutableArray *result;
  NSDictionary   *eoTeam;
  int             count;

  [self logWithFormat:@"_renderTeams([%@],[%@])", _teams, _detail];
  result = [NSMutableArray arrayWithCapacity:[_teams count]];
  for (count = 0; count < [_teams count]; count++) {
    eoTeam = [_teams objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoTeam valueForKey:@"companyId"], @"objectId",
       [eoTeam valueForKey:@"objectVersion"], @"objectVersion",
       @"Team", @"entityName",
       [eoTeam valueForKey:@"ownerId"], @"ownerObjectId",
       [self NIL:[eoTeam valueForKey:@"description"]], @"name",
       nil]];
     if([_detail intValue] > 0) {
       [[result objectAtIndex:count] setObject:eoTeam forKey:@"eoObject"];
       if([_detail intValue] & zOGI_INCLUDE_CONTACTS)
         [self _addContactsToTeam:[result objectAtIndex:count]];
      [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
      [[result objectAtIndex:count] removeObjectForKey:@"eoObject"];
     }
   }
  return result;
}

/*
{'isLocationTeam': 0, 
 'description': 'other team 1', 
 'companyId': 25850, 
 'isReadonly': 1, 
 'isTeam': 1, 
 'objectVersion': 1, 
 'number': 'OGo25850', 
 'ownerId': 10000, 
 'isPrivate': 0, 
 'dbStatus': 'inserted', 
 'login': 'OGo25850'}, 
*/

-(id)_getUnrenderedTeamsForKeys:(id)_arg {
  NSArray       *teams;

  [self logWithFormat:@"_getUnrenderedTeamsForKeys([%@])", _arg];
  teams = [[[self getCTX] runCommand:@"team::get-by-globalid",
                                     @"gids", [self _getEOsForPKeys:_arg],
                                     nil] retain];
  return teams;
}

-(id)_getTeamsForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getTeamsForKeys([%@])", _arg];
  return [self _renderTeams:[self _getUnrenderedTeamsForKeys:_arg] withDetail:_detail];
}

-(id)_getTeamForKey:(id)_arg withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getTeamForKey([%@])", _arg];
  return [[self _renderTeams:[self _getUnrenderedTeamsForKeys:_arg] withDetail:_detail] lastObject];
}

-(void)_addContactsToTeam:(NSMutableDictionary *)_team {
  NSArray     *memberList;
  NSArray            *members;

  members = [[self getCTX] runCommand:@"team::members",
                                      @"team",[_team objectForKey:@"eoObject"],
                                      nil];
  if (members != nil) {
    [self logWithFormat:@"__addContactsToTeam:%@", members];
    memberList = [self _renderContacts:members withDetail:0];
   } else { memberList = [NSArray new]; }
  [_team setObject:memberList forKey:@"_CONTACTS"];
}
@end /* End zOGIAction(Team) */
