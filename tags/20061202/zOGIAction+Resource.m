/*
  zOGIAction+Resource.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Resource.h"

@implementation zOGIAction(Resource)

-(NSArray *)_renderResources:(NSArray *)_resources withDetail:(NSNumber *)_detail {
  NSMutableArray *result;
  NSDictionary   *eoResource;
  int             count;

  [self logWithFormat:@"_getResourcesForKeys([%@],[%@])", _resources, _detail];
  result = [NSMutableArray arrayWithCapacity:[_resources count]];
  for (count = 0; count < [_resources count]; count++) {
    eoResource = [_resources objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoResource valueForKey:@"appointmentResourceId"], @"objectId",
       @"Resource", @"entityName",
       [self NIL:[eoResource valueForKey:@"category"]], @"category",
       [self NIL:[eoResource valueForKey:@"email"]], @"email",
       [self NIL:[eoResource valueForKey:@"emailSubject"]], @"emailSubject",
       [self NIL:[eoResource valueForKey:@"name"]], @"name",
       [self NIL:[eoResource valueForKey:@"notificationTime"]], @"notificationTime",
       nil]];
     if([_detail intValue] > 0)
       [[result objectAtIndex:count] setObject:eoResource forKey:@"eoObject"];
   }
  if([_detail intValue] > 0) {
    for (count = 0; count < [result count]; count++) {
      [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
      [[result objectAtIndex:count] removeObjectForKey:@"eoObject"];
     }
   }
  return result;
}

/* Retrieves a resource by its *EXACT* name.
   _arg is the resource name 
   Returns either nil or an EOGenericRecord */
-(id)_getResourceByName:(NSString *)_arg {
  id             res;

  [self logWithFormat:@"_getResourceByName(%@)", _arg];
  res = [[self getCTX] runCommand:@"appointmentresource::get",
                   @"name", _arg,
                   @"returnType",
                     [NSNumber numberWithInt:LSDBReturnType_OneObject],
                 nil];
  if ([res isKindOfClass:[NSArray class]]) {
     return [res lastObject];
    }
  return nil;
}

-(NSArray *)_getUnrenderedResourcesForKeys:(id)_arg {
  NSArray       *resources;

  [self logWithFormat:@"_getUnrenderedResourcesForKeys([%@])", _arg];
  resources = [[[self getCTX] runCommand:@"appointmentresource::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  return resources;
}

-(id)_getResourcesForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"__getResourcesForKeys([%@])", _arg];
  return [self _renderResources:[self _getUnrenderedResourcesForKeys:_arg] withDetail:_detail];
}


@end /* End zOGIAction(Resource) */
