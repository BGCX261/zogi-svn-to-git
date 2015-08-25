/*
  zOGIAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIAction.h"

@implementation zOGIAction

- (void)dealloc {
  [self->arg1 release];
  [self->arg2 release];
  [self->arg3 release];
  [self->arg4 release];
  [super dealloc];
}

/* accessors */

- (void)setArg1:(id)_arg {
  ASSIGN(self->arg1, _arg);
}

- (id)arg1 {
  return self->arg1;
}

- (void)setArg2:(id)_arg {
  ASSIGN(self->arg2, _arg);
}

- (id)arg2 {
  return self->arg2;
}

- (void)setArg3:(id)_arg {
  ASSIGN(self->arg3, _arg);
}

- (id)arg3 {
  return self->arg3;
}

- (void)setArg4:(id)_arg {
  ASSIGN(self->arg4, _arg);
}

- (id)arg4 {
  return self->arg4;
}

- (id)NIL:(id)_arg {
  if (_arg == nil)
    return [NSNull null];
  return _arg;
 }


- (id)defaultAction {
  return nil;
}

- (LSCommandContext *)getCTX {
  if (ctx == nil) {
    ctx = [[self clientObject] commandContextInContext:[self context]];
   }
  return ctx;
}

/// _arg may be an NSString or an NSNumber
/// Returns nil if the PKey is not valid
- (EOGlobalID *)_getEOForPKey:(id)_arg {
  EOGlobalID             *gid;

  //[self logWithFormat:@"_getEOForPKey([%@])", _arg];
  gid = nil;
  if ([_arg isKindOfClass:[NSString class]])
    _arg = [NSNumber numberWithInt:[_arg intValue]];
  if([_arg isKindOfClass:[NSNumber class]])
     gid = [[[self getCTX] typeManager] globalIDForPrimaryKey:_arg];
  [self logWithFormat:@"_getEOForPKey([%@]) returning [%@]", _arg, gid];
  return gid;
}

- (NSString *)_getPKeyForEO:(EOKeyGlobalID *)_arg {
    [self logWithFormat:@"_getPKeyForEO([%@])", _arg];
  return [[[_arg keyValuesArray] objectAtIndex: 0] valueForKey:@"stringValue"];
}

/* Get EOs for a collection of PKeys 
   If _arge is a single value (NSNumber or NSString) then an array of
   a single result is returned.  If the _arg is an NSDictionary each
   of the keys is assumed to be a PKey and the keys are enumerated. */
- (NSArray *)_getEOsForPKeys:(id)_arg {
 NSMutableArray      *pkeys;
 NSArray             *result;
 int                 i;

 //[self logWithFormat:@"_getEOsForPKeys([%@])", _arg];
 pkeys = nil;
 /* If the _arg is a single value */
 if ([_arg isKindOfClass:[NSString class]] ||
     [_arg isKindOfClass:[NSNumber class]]) {
     [self logWithFormat:@"_getEOsForPKeys([%@]) - single", _arg];
    result = [NSArray arrayWithObject:[self _getEOForPKey:_arg]];
    return result;
  }

 /* _arg is a multiple value */
 [self logWithFormat:@"_getEOsForPKeys([%@]) - multi", _arg];
 if ([_arg isKindOfClass:[NSArray class]]) {
   pkeys = [NSMutableArray new];
   [pkeys addObjectsFromArray: _arg] ;
  } else if ([_arg isKindOfClass:[NSDictionary class]]) {
      pkeys = [NSMutableArray new];
      [pkeys addObjectsFromArray:[_arg allKeys]];
     }
   else {
      [self logWithFormat:@"_getEOsForPKeys - Unknown arg type"];
      return [result initWithObjects: nil]; 
      /* TODO: THROW AN EXCEPTION! */
     }

 /* Normalize array values to NSNumbers */
 [self logWithFormat:@"_getEOsForPKeys - Normalizing array"];
 for(i = 0; i < [pkeys count]; i++ ) {
   if ([[pkeys objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
     /* We don't need to do anything, already a number */
    } else if ([[pkeys objectAtIndex:i] isKindOfClass:[NSString class]]) {
        /* Convert any NSString values into NSNumbers */
        [pkeys replaceObjectAtIndex:i 
               withObject:[NSNumber numberWithInt:
                                      [[pkeys objectAtIndex:i] intValue]]];
       } else {
            return nil;
             }
     } /* End of cleaning for */

  result = [[[self getCTX] typeManager] globalIDsForPrimaryKeys:pkeys];
  [self logWithFormat:@"_getEOsForPKeys([%@]) - pkeys=%@", _arg, pkeys];
  if ([result containsObject:[NSNull null]]) {
     /* TODO: THROW AN EXCEPTION */
   }
  //[pkeys dealloc];
  return result;
}


/// _arg may be a string id or an EOGlobalId
- (NSString *)_getEntityNameForPKey:(id)_arg {
  EOGlobalID             *gid;

  gid = nil;
  [self logWithFormat:@"_getEntityNameForPKey([%@])", _arg];
  /* If _args is a Number then attempt the lookup */
  if([_arg isKindOfClass:[EOGlobalID class]])
     gid = _arg;
    else
      gid = [self _getEOForPKey:_arg];
  if (gid == nil)
    return @"Unknown";
  return [[gid entityName] valueForKey:@"stringValue"];
}

/*  Check if all the provided pkeys (or EOGlobalIDs) are one of the 
    provided entityNames. 

    _pkey can be an NSString, an NSNumber, an EOGlobalID or an NSArray
       containing any of the previously listed classes.
    _entityName can be either an NSString or an NSArray of NSStrings. */
- (id)_checkEntity:(id)_pkey entityName:(id)_name {
  NSEnumerator *pkeyEnumerator, *entityEnumerator;
  NSArray      *pkeys, *entityNames;
  NSString     *entityName, *en;
  id           pkey;
  int          count;

  [self logWithFormat:@"_checkEntity(pk=[%@], name=[%@])", _pkey, _name];
  /* if _pkey is not an array, make a single entry array */
  if(![_pkey isKindOfClass:[NSArray class]])
     pkeys = [NSArray arrayWithObject:_pkey];
    else
      pkeys = _pkey;
  /* if _name is not an array, make a single entry array */
  if(![_name isKindOfClass:[NSArray class]])
     entityNames = [NSArray arrayWithObject:_name];
    else
      entityNames = _name;

  pkeyEnumerator = [pkeys objectEnumerator];
  while ((pkey = [pkeyEnumerator nextObject]) != nil) {
    entityName = [self _getEntityNameForPKey:pkey];
    count = [entityNames count];
    entityEnumerator = [entityNames objectEnumerator];
    while ((en = [entityEnumerator nextObject]) != nil) {
      if ([entityName isEqualToString:en])
        count--;
     }
    if (count == [entityNames count])
      return [NSNumber numberWithBool:NO];
   } /* End while [pkeyEnumerator nextObject] */
  return [NSNumber numberWithBool:YES];
 }

- (NSUserDefaults *)_getDefaults {
  // [self logWithFormat:@"_getDefaults()"];
  return [[self getCTX] userDefaults];
 }

- (NSString *)_getDefault:(NSString *)_value {
  // [self logWithFormat:@"called _getDefault()"];
  return [[self _getDefaults] stringForKey:_value];
 }

- (NSTimeZone *)_getTimeZone {
  NSTimeZone     *tz = nil;

  // [self logWithFormat:@"_getTimeZone()"];
  tz = [NSTimeZone timeZoneWithAbbreviation:[self _getDefault:@"timezone"]];
  if (tz == nil)
    [self logWithFormat:@"_getTimeZone() - Unable to marshall timezone"];
  return tz;
 }

@end /* zOGIAction */
