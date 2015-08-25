/*
  zOGIAccountAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIAccountAction.h"

@implementation zOGIAccountAction

-(id)getLoginAccountAction {
  [self logWithFormat:@"zogi.getLoginAccount(%@)", arg1];
  return [self _getLoginAccount:arg1];
}

@end /* zOGIAccountAction */
