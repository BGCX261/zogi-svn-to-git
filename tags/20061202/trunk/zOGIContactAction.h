/*
  zOGIContactAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIContactAction_H__
#define __zOGIContactAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Contact.h"

@interface zOGIContactAction : zOGIAction
{
}

-(id)getContactsByObjectIdAction;
-(id)getFavoriteContactsAction;
-(id)searchForContactsAction;

@end /* End zOGIContactAction */

#endif /* __zOGIContactAction_H__ */
