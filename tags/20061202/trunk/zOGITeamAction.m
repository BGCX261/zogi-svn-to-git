/*
  zOGITeamAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGITeamAction.h"

@implementation zOGITeamAction

-(id)getTeamsByObjectIdAction {
  [self logWithFormat:@"zogi.getTeamsById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Team"])
    return [self _getTeamsForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

@end /* zOGITeamAction */
