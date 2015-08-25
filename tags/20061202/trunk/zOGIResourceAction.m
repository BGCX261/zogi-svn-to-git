/*
  zOGIResourceAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIResourceAction.h"

@implementation zOGIResourceAction

-(id)getResourcesByObjectIdAction {
  [self logWithFormat:@"zogi.getResourcesById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Resource"])
    return [self _getResourcesForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

@end /* zOGIResourceAction */
