/*
  zOGIAction+Assignment.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"

@implementation zOGIAction(Assignment)

-(id)_renderAssignment:(id)_objectId
                source:(id)_source 
                target:(id)_target 
                    eo:(id)_eo {
  NSMutableDictionary   *assignment;
  NSString              *sourceEntity, *targetEntity;
 
  assignment = [[NSMutableDictionary alloc] initWithCapacity:16];

  if ([NSString class] == [_objectId class])
    _objectId = [NSNumber numberWithInt:[_objectId intValue]];

  if ([NSString class] == [_source class])
    _source = [NSNumber numberWithInt:[_source intValue]];
  sourceEntity = [self _izeEntityName:[self _getEntityNameForPKey:_source]];

  if ([NSString class] == [_target class])
    _target = [NSNumber numberWithInt:[_target intValue]];
  targetEntity = [self _izeEntityName:[self _getEntityNameForPKey:_target]];

  [assignment setObject:_objectId forKey:@"objectId"];
  [assignment setObject:@"assignment" forKey:@"entityName"];
  [assignment setObject:_source forKey:@"sourceObjectId"];
  [assignment setObject:sourceEntity forKey:@"sourceEntityName"];
  [assignment setObject:_target forKey:@"targetObjectId"];
  [assignment setObject:targetEntity forKey:@"targetEntityName"];
  if (_eo != nil) {
    if (([_eo class] == [EOGenericRecord class]) ||
        ([_eo class] == [NSDictionary class]) ||
        ([_eo class] == [NSMutableDictionary class])) {
       [assignment setObject:[self NIL:[_eo objectForKey:@"accessRight"]]
                      forKey:@"accessRights"];
       [assignment setObject:[self NIL:[_eo objectForKey:@"info"]]
                      forKey:@"info"];
     }
   } else {
       [assignment setObject:[NSNull null] forKey:@"accessRight"];
       [assignment setObject:[NSNull null] forKey:@"info"];
      }
  return assignment;
}

-(NSArray *)_getCompanyAssignments:(id)_company key:(NSString *)_key {
  NSNumber  *companyId;
  NSArray   *assignments;

  [self logWithFormat:@"_getCompanyAssignments([%@])", [_company class]];
  if ([_company class] == [EOGenericRecord class])
    companyId = [_company objectForKey:@"companyId"];
  else if ([_company class] == [NSNumber class])
    companyId = _company;
  else if (([_company class] == [NSDictionary class]) ||
           ([_company class] == [NSMutableDictionary class]) ||
           ([_company class] == [NSConcreteMutableDictionary class])) {
    if ([_company objectForKey:@"*companyAssignments"] != nil)
      return [_company objectForKey:@"*companyAssignments"];
    companyId = [_company objectForKey:@"objectId"];
   }
  else return [NSException exceptionWithHTTPStatus:500
                 reason:@"Invalid company specification for assignment retrieval"];

  assignments = [[self getCTX] runCommand:@"companyassignment::get",
                    _key, companyId,
                    @"returnType", intObj(LSDBReturnType_ManyObjects),
                    nil];
  if (assignments == nil)
    assignments = [NSArray array];
  if (([_company class] == [NSMutableDictionary class]) ||
      ([_company class] == [NSConcreteMutableDictionary class]))
    [_company setObject:assignments forKey:@"*companyAssignments"];
  return assignments;
}


@end /* End zOGIAction(Assignment) */
