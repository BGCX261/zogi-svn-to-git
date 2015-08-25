/*
  zOGITaskAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGITaskAction_H__
#define __zOGITaskAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Task.h"

@interface zOGITaskAction : zOGIAction
{
}

-(id)getTasksByObjectIdAction;
-(id)getTasksByListAction;
-(id)putTaskNotationAction;

@end /* End zOGITaskAction */

#endif /* __zOGITaskAction_H__ */
