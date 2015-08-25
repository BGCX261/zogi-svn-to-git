/*
  zOGIAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006

  This class is the core of the zOGI RPC.  This file provides the utility
  methods used throughout zOGI to try and provide both clean looking 
  code and mercilessly consistent results.  The actual RPC calls are
  in zOGIRPCAction and the functions specific to each document type
  are located in categories of this object;  zOGIAction+Project for
  example.  All zOGI RPC actions take a maximum of four arguments.
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

/*
  _arg may be an NSString or an NSNumber
  Returns nil if the PKey is not valid
*/
- (EOGlobalID *)_getEOForPKey:(id)_arg {
  EOGlobalID             *gid;
 
  gid = nil;
  if ([_arg isKindOfClass:[NSString class]])
    _arg = [NSNumber numberWithInt:[_arg intValue]];
  if([_arg isKindOfClass:[NSNumber class]])
     gid = [[[self getCTX] typeManager] globalIDForPrimaryKey:_arg];
  if (gid == nil)
    [self logWithFormat:@"_getEOForPKey; returning nil"];
   else
     [self logWithFormat:@"_getEOForPKey; returning %@", gid];
  return gid;
 }

/*
  Returns the primary key for the provided EOGlobalID
*/
- (NSString *)_getPKeyForEO:(EOKeyGlobalID *)_arg {
  [self logWithFormat:@"_getPKeyForEO; arg = %@", _arg];
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

  [self logWithFormat:@"_getEOsForPKeys;arg=%@ type=%@", _arg, [_arg class]];
  pkeys = nil;
  if (_arg == nil) {
    [self logWithFormat:@"_getEOsForPKeys; _arg is nil"];
    return [result initWithObjects: nil]; 
   }
  /* If the _arg is a single value */
  if ([_arg isKindOfClass:[NSString class]] ||
    [_arg isKindOfClass:[NSNumber class]]) {
    [self logWithFormat:@"_getEOsForPKeys; single", _arg];
    result = [NSArray arrayWithObject:[self _getEOForPKey:_arg]];
    return result;
   }

  /* _arg is a multiple value */
  [self logWithFormat:@"_getEOsForPKeys; multi"];
  if ([_arg isKindOfClass:[NSArray class]]) {
    // Short circuit out if the argument is already an array
    // of EOGlobalIDs.  If the last one is then we assume
    // they all are.
    if ([[_arg lastObject] isKindOfClass:[EOGlobalID class]])
      return _arg;
    pkeys = [NSMutableArray new];
    [pkeys addObjectsFromArray: _arg] ;
   } else if ([_arg isKindOfClass:[NSDictionary class]]) {
       pkeys = [NSMutableArray new];
       [pkeys addObjectsFromArray:[_arg allKeys]];
      }
   else {
     [self logWithFormat:@"_getEOsForPKeys; Unknown arg type"];
     return [result initWithObjects: nil]; 
     /* TODO: THROW AN EXCEPTION! */
    }

  /* Normalize array values to NSNumbers */
  [self logWithFormat:@"_getEOsForPKeys; Normalizing array"];
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
  [self logWithFormat:@"_getEOsForPKeys; pkeys = %@", _arg, pkeys];
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
  [self logWithFormat:@"_getEntityNameForPKey; arg = %@", _arg];
  /* If _args is a Number then attempt the lookup */
  if([_arg isKindOfClass:[EOGlobalID class]])
     gid = _arg;
    else
      gid = [self _getEOForPKey:_arg];
  if (gid == nil)
    return @"Unknown";
  return [[gid entityName] valueForKey:@"stringValue"];
}

/// _arg must be a string
- (NSString *)_izeEntityName:(NSString *)_arg {
  NSString               *result;

  if ([_arg isEqualToString:@"Date"])
    result = [NSString stringWithString:@"Appointment"];
  else if ([_arg isEqualToString:@"CompanyValue"])
    result = [NSString stringWithString:@"companyValue"];
  else if ([_arg isEqualToString:@"Telephone"])
    result = [NSString stringWithString:@"telephone"];
  else if ([_arg isEqualToString:@"Person"])
    result = [NSString stringWithString:@"Contact"];
  else if ([_arg isEqualToString:@"JobHistoryInfo"])
    result = [NSString stringWithString:@"taskAnnotation"];
  else if ([_arg isEqualToString:@"Log"])
    result = [NSString stringWithString:@"logEntry"];
  else if ([_arg isEqualToString:@"Job"])
    result = [NSString stringWithString:@"Task"];
  else if ([_arg isEqualToString:@"Doc"])
    result = [NSString stringWithString:@"File"];
  else
    result = _arg;
  return result;
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

  [self logWithFormat:@"_checkEntity; _pkey = %@ name = %@)", _pkey, _name];
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
  NSString *value;

  // [self logWithFormat:@"called _getDefault()"];
  value = [[self _getDefaults] stringForKey:_value];
  [self logWithFormat:@"default value is %@", value];
  return value;
 }

- (NSNumber *)_getCompanyId {
  return [[[self getCTX] valueForKey:LSAccountKey] valueForKey:@"companyId"];
}

- (NSTimeZone *)_getTimeZone {
  NSTimeZone     *tz = nil;

  // [self logWithFormat:@"_getTimeZone()"];
  tz = [NSTimeZone timeZoneWithAbbreviation:[self _getDefault:@"timezone"]];
  if (tz == nil)
    [self logWithFormat:@"Unable to marshall timezone"];
  return tz;
 }

- (NSCalendarDate *)_makeCalendarDate:(id)_date {
  NSCalendarDate *dateValue;

  [self logWithFormat:@"_makeCalendarDate; _date = %@", _date];
  dateValue = nil;
  if ([_date isKindOfClass:[NSCalendarDate class]])
    dateValue = _date;
  else if ([_date isKindOfClass:[NSString class]]) {
    if ([_date length] == 10)
      dateValue = [NSCalendarDate dateWithString:_date
                             calendarFormat:@"%Y-%m-%d"];
    else if ([_date length] == 16)
      dateValue = [NSCalendarDate dateWithString:_date
                             calendarFormat:@"%Y-%m-%d %H:%M"];
   }
  if (dateValue == nil) {
    // \todo Throw exception
    [self logWithFormat:@"_makeCalendarDate; returning nil"];
    return nil;
   }
  [dateValue setTimeZone:[self _getTimeZone]];
  return dateValue;
}

/*
- (void)_saveProperties:(NSArray *)_properties forObject:(NSString *)_objectId {
}

- (void)_saveObjectLinks:(NSArray *)_properties forObject:(NSString *)_objectId {
}
*/

- (void)_stripInternalKeys:(NSMutableDictionary *)_dictionary {
  NSEnumerator  *enumerator;
  NSString      *key;

  enumerator = [_dictionary keyEnumerator];
  while ((key = [enumerator nextObject]) != nil)
    if ([[key substringToIndex:1] isEqualToString:@"*"])
      [_dictionary removeObjectForKey:key];
}

@end /* zOGIAction */
