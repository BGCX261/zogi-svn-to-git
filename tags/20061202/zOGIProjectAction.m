/*
  zOGIProjectAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIProjectAction.h"

@implementation zOGIProjectAction

-(id)getProjectsByObjectIdAction {
  [self logWithFormat:@"zogi.getProjectsById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Project"])
    return [self _getProjectsForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getFavoriteProjectsAction {
  return [self _getProjectsForKeys:[[self getCTX] runCommand:@"project::get-favorite-ids", nil] withDetail:arg1];
}

@end /* zOGIProjectAction */
