/*
  zOGIAction+Object.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Object_H__
#define __zOGIAction_Object_H__

#include "zOGIAction.h"

@interface zOGIAction(Object)

-(NSDictionary *)_getObjectProperties:(id)_arg;
-(id)_storeProperties:(id)_pk withValues:(NSDictionary *)_values;
-(void)_addObjectDetails:(NSMutableDictionary *)_object withDetail:(NSNumber *)_detail;
-(void)_addLinksToObject:(NSMutableDictionary *)_object;
-(void)_addPropertiesToObject:(NSMutableDictionary *)_object;
-(void)_addLogsToObject:(NSMutableDictionary *)_object;

@end /* End zOGIAction(Object) */

#endif /* __zOGIAction_Object_H__ */
