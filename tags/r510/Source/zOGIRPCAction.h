/*
  zOGIGenericAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIRPCAction_H__
#define __zOGIRPCAction_H__

/*
  OGI Schedular Action
*/

@interface zOGIRPCAction : zOGIAction
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
-(id)_createObject:(id)_dictionary
          withFlags:(NSArray *)_flags;
-(id)_updateObject:(id)_dictionary 
          objectId:(NSString *)_objectId
         withFlags:(NSArray *)_flags;

@end

#endif /* __zOGIRPCAction_H__ */

