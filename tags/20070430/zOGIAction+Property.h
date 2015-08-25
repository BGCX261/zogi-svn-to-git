/*
  zOGIAction+Property.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Property_H__
#define __zOGIAction_Property_H__

#include "zOGIAction.h"

@interface zOGIAction(Property)

-(NSString *)_takeNamespaceFromProperty:(NSString *)_property;
-(NSString *)_takeAttributeFromProperty:(NSString *)_property;
-(NSDictionary *)_renderProperty:(id)_name
                       withValue:(id)_value 
                       forObject:(id)_objectId;
-(NSArray *)_propertiesForKey:(id)_objectId;
-(void)_addPropertiesToObject:(NSMutableDictionary *)_object;
-(id)_translateProperty:(NSDictionary *)_property;
-(NSException *)_saveProperties:(id)_properties
                      forObject:(id)_objectId;

@end

#endif /* __zOGIAction_Property_H__ */
