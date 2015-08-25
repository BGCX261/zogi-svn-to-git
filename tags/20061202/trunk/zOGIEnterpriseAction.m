/*
  zOGIEnterpriseAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIEnterpriseAction.h"

@implementation zOGIEnterpriseAction

-(id)getEnterprisesByObjectIdAction {
  [self logWithFormat:@"zogi.getEnteprisesById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Enterprise"])
    return [self _getEnterprisesForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getFavoriteEnterprisesAction {
  return [self _getEnterprisesForKeys:[[self _getDefaults] arrayForKey:@"enterprise_favorites"] withDetail:arg1];
}

@end /* zOGIContactAction */
