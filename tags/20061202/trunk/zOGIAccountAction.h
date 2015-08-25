/*
  zOGIAccountAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIAccountAction_H__
#define __zOGIAccountAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Account.h"

@interface zOGIAccountAction : zOGIAction
{
}

-(id)getLoginAccountAction;

@end /* End zOGIAccountAction */

#endif /* __zOGIAccountAction_H__ */
