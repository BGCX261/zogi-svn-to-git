/*
  zOGISchedularAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGISchedularAction.h"

@implementation zOGISchedularAction

-(id)getAppointmentsByObjectIdAction {
  [self logWithFormat:@"zogi.getAppointmentsById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Date"])
    return [self _getDatesForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getAppointmentsInRange {
 return nil;
}

-(id)acceptAppointmentAction {
  if([self _checkEntity:arg1 entityName:@"Date"])
    return [self _setParticipantStatus:arg1 withStatus:@"ACCEPT"];
  /* TODO: Throw Exception */
  return nil;
}

-(id)declineAppointmentAction {
  if([self _checkEntity:arg1 entityName:@"Date"])
    return [self _setParticipantStatus:arg1 withStatus:@"DECLINED"];
  /* TODO: Throw Exception */
  return nil;
}

-(id)acceptAppointmentTentativelyAction:(id)_apt {
  if([self _checkEntity:arg1 entityName:@"Date"])
    return [self _setParticipantStatus:arg1 withStatus:@"TENTATIVE"];
  /* TODO: Throw Exception */
  return nil;
}

-(id)resetAppointmentStatusAction:(id)_apt {
  if([self _checkEntity:arg1 entityName:@"Date"])
    return [self _setParticipantStatus:arg1 withStatus:@"NEEDS-ACTION"];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getConflictsByObjectIdAction {
  NSEnumerator        *enumerator;
  NSMutableDictionary *result;
  NSArray             *pkeys;
  id                  pk;

  [self logWithFormat:@"zogi.getConflictsById(%@)", arg1];
  if(![arg1 isKindOfClass:[NSArray class]])
    pkeys = [NSArray arrayWithObjects:arg1, nil];
   else
     pkeys = arg1;

  result = [NSMutableDictionary new];
  enumerator = [pkeys objectEnumerator];
  while ((pk = [enumerator nextObject]) != nil) {
    [self logWithFormat:@"zogi.getConflictsById(%@): PK=%@", arg1, pk];
    if([self _checkEntity:pk entityName:@"Date"]) { 
      [self logWithFormat:@"zogi.getConflictsById(%@): PK=%@ is a date", arg1, pk];
      [result setObject:[self _renderConflictsForDateKey:pk]
              forKey:[pk stringValue]];
     } else {
         [self logWithFormat:@"zogi.getConflictsById(%@): PK=%@ NOT a date", arg1, pk];
        }
   } /* End while [enumerator nextObject] */
  return [result autorelease];
}

@end
