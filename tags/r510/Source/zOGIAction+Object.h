/*
  zOGIAction+Object.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006, 2007
*/
#ifndef __zOGIAction_Object_H__
#define __zOGIAction_Object_H__

#include "zOGIAction.h"
#include "zOGIAction+Property.h"

@interface zOGIAction(Object)

-(NSDictionary *)_getObjectByObjectId:(id)_objectId 
                           withDetail:(NSNumber *)_detail;
-(void)_addObjectDetails:(NSMutableDictionary *)_object 
              withDetail:(NSNumber *)_detail;
-(NSException *)_addACLsToObject:(NSMutableDictionary *)_object;
-(NSException *)_saveACLs:(NSArray *)_acls 
                forObject:(id)_objectId;
-(void)_addLinksToObject:(NSMutableDictionary *)_object;
-(void)_addLogsToObject:(NSMutableDictionary *)_object;
-(id)_translateObjectLink:(NSDictionary *)_link 
               fromObject:(id)_objectId;
-(NSException *)_saveObjectLinks:(NSArray *)_links 
                       forObject:(NSString *)_objectId;
-(NSDictionary *)_makeUnknownObject:(id)_objectId;
-(void)_unfavoriteObject:(id)_objectId defaultKey:(NSString *)_key;
-(void)_favoriteObject:(id)_objectId defaultKey:(NSString *)_key;

@end /* End zOGIAction(Object) */

#endif /* __zOGIAction_Object_H__ */
