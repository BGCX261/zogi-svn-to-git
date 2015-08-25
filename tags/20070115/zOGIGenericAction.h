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
-(id)getTypeOfObjectAction;
-(id)getFavoritesByTypeAction;
-(id)flagFavoritesAction;
-(id)unflagFavoritesAction;
-(id)getObjectsByObjectIdAction;
-(id)getObjectByObjectIdAction;
-(id)getObjectVersionsByObjectIdAction;
-(id)putObjectAction;
-(id)deleteObjectAction;
-(id)searchForObjectsAction;
-(id)_createObject:(NSDictionary *)_dictionary 
         withFlags:(NSArray *)_flags;
-(id)_updateObject:(NSDictionary *)_dictionary 
          objectId:(NSString *)_objectId
         withFlags:(NSArray *)_flags;

@end

#endif /* __zOGIGenericAction_H__ */

