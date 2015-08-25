/*
  zOGIEnterpriseAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIEnterpriseAction_H__
#define __zOGIEnterpriseAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Enterprise.h"

@interface zOGIEnterpriseAction : zOGIAction
{
}

-(id)getEnterprisesByObjectIdAction;
-(id)getFavoriteEnterprisesAction;

@end /* End zOGIEnterpriseAction */

#endif /* __zOGIEnterpriseAction_H__ */
