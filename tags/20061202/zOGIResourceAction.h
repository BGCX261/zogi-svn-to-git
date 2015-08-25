/*
  zOGIResourceAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIResourceAction_H__
#define __zOGIResourceAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Resource.h"

@interface zOGIResourceAction : zOGIAction
{
}

-(id)getResourcesByObjectIdAction;

@end /* End zOGIResourceAction */

#endif /* __zOGIResourceAction_H__ */
