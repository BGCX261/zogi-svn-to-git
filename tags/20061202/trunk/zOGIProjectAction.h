/*
  zOGIProjectAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIProjectAction_H__
#define __zOGIProjectAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Project.h"

@interface zOGIProjectAction : zOGIAction
{
}

-(id)getProjectsByObjectIdAction;
-(id)getFavoriteProjectsAction;

@end /* End zOGIProjectAction */

#endif /* __zOGIProjectAction_H__ */
