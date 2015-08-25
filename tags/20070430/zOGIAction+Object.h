/*
  zOGIAction+Object.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Object_H__
#define __zOGIAction_Object_H__

#include "zOGIAction.h"

@interface zOGIAction(Object)

-(NSDictionary *)_getObjectByObjectId:(id)_objectId withDetail:(NSNumber *)_detail;
-(void)_addObjectDetails:(NSMutableDictionary *)_object 
              withDetail:(NSNumber *)_detail;
-(void)_addLinksToObject:(NSMutableDictionary *)_object;
-(void)_addLogsToObject:(NSMutableDictionary *)_object;
-(id)_translateObjectLink:(NSDictionary *)_link 
               fromObject:(id)_objectId;
-(NSException *)_saveObjectLinks:(NSArray *)_links 
                       forObject:(NSString *)_objectId;
-(NSDictionary *)_makeUnknownObject:(id)_objectId;

@end /* End zOGIAction(Object) */

#endif /* __zOGIAction_Object_H__ */
