/*
  zOGIAction+Resource.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Resource_H__
#define __zOGIAction_Resource_H__

#include "zOGIAction.h"

@interface zOGIAction(Resource)
-(id)_getResourceByName:(NSString *)_arg;
-(id)_getResourcesForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_searchForResources:(NSDictionary *)_query 
              withDetail:(NSNumber *)_detail;
@end

#endif /* __zOGIAction_Resource_H__ */
