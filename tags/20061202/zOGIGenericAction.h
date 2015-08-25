/*
  zOGIGenericAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIGenericAction_H__
#define __zOGIGenericAction_H__

#include <zOGIAction.h>

/*
  OGI Schedular Action
*/

@interface zOGIGenericAction : zOGIAction
{
}

/* methods */
- (id)getTypeOfObjectAction;
- (id)flagFavoritesAction;
- (id)unflagFavoritesAction;
- (id)getObjectsByObjectIdAction;
- (id)getObjectVersionsByObjectIdAction;
- (id)putObjectAction;
- (id)searchForObjectsAction;
- (id)_createObject:(NSDictionary *)dictionary;
- (id)_updateObject:(NSDictionary *)dictionary objectId:(NSString *)objectId;

@end

#endif /* __zOGIGenericAction_H__ */

