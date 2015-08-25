/*
  zOGIAction+Assignment.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Assignment_H__
#define __zOGIAction_Assignment_H__

#include "zOGIAction.h"

@interface zOGIAction(Assignment)

-(id)_renderAssignment:(id)_objectId
                source:(id)_source 
                target:(id)_target 
                    eo:(id)_eo;
-(id)_getCompanyAssignments:(id)_company 
                        key:(NSString *)_key;
-(NSException *)_saveCompanyAssignments:(NSArray *)_assignments
                               objectId:(id)_objectId
                                    key:(NSString *)_key
                           targetEntity:(NSString *)_targetEntity
                              targetKey:(NSString *)_targetKey;

@end

#endif /* __zOGIAction_Assignment_H__ */
