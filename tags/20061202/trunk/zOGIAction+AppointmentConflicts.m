/*
  zOGIAction+AppointmentConflicts.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Resource.h"
#include "zOGIAction+Team.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+AppointmentConflicts.h"

@implementation zOGIAction(AppointmentConflicts)

-(id)_getConflictsForDate:(id)_appointment {
  NSArray         *conflictAttrs;
  NSDictionary    *conflictList;

  [self logWithFormat:@"_getConflictsForDate(%@)", _appointment];
  /* TODO: Do we really need to get the conflict attirbutes from defaults? */
  conflictAttrs = [[[self _getDefaults]
                        arrayForKey:@"schedulerconflicts_conflictkeys"] copy];  
  conflictList = [[[self getCTX] 
                     runCommand:@"appointment::conflicts",
                                @"appointment", _appointment,
                                @"fetchConflictInfo", @"YES",
                                @"fetchGlobalIDs", @"YES",
                                @"conflictInfoAttributes", conflictAttrs,
                                nil] copy];
  return conflictList;
}

-(id)_getConflictsForDateKey:(id)_pk {
  [self logWithFormat:@"_getConflictsForDateKey(%@)", _pk];
  return [[self _getConflictsForDate:[self _getUnrenderedDateForKey:_pk]] retain];
}

-(NSDictionary *)_renderConflictsForDateKey:(id)_arg {
  NSArray               *aptAttrs      = nil;
  id                    tmp, conflict;
  NSDictionary          *conflictList, *conflictDetail, *resource;
  NSMutableDictionary   *result;
  NSArray               *conflictDates;
  NSEnumerator          *enumerator;
  int                   count;

  [self logWithFormat:@"_renderConflictsForDateKey(%@)", _arg];
  /* Get required bits from user defaults */
  aptAttrs = [[[[self getCTX] userDefaults]
                   arrayForKey:@"schedulerconflicts_fetchkeys"] copy];

  /* Getting conflict info */
  conflictList = [[self _getConflictsForDateKey:arg1] retain];

  /* Get appointments found in conflict */
  conflictDates = [[self _getDatesForKeys:[conflictList allKeys]] retain];
  [self logWithFormat:@"_renderConflictsForDateKey(%@) - conflict dates = [%@]", _arg, conflictDates];

  /* Initialize dictionary for results with summary
     of conflicting appointments */
  result = [[NSMutableDictionary new] retain];
  enumerator = [conflictDates objectEnumerator];
  while ((conflict = [enumerator nextObject]) != nil) {
    [self logWithFormat:@"_renderConflictsForDateKey(%@) - rendering [%@]", conflict];
    conflictDetail = [NSDictionary dictionaryWithObjectsAndKeys:
       [conflict objectForKey:@"title"], @"title",
       [conflict objectForKey:@"startDate"], @"startDate",
       [conflict objectForKey:@"endDate"], @"endDate",
       [conflict objectForKey:@"dateId"], @"objectId",
       [conflict objectForKey:@"aptType"], @"type",
       [conflict objectForKey:@"ownerId"], @"ownerObjectId",
       [NSMutableArray arrayWithCapacity:16], @"conflicts",
       nil];
    [result setObject:conflictDetail forKey:
       [[conflict objectForKey:@"dateId"] stringValue]];
   }
  
  /* Add to dictionary of conflicting appointments the conflicts
     occuring with each appointment */
  enumerator = [conflictList objectEnumerator];
  while ((tmp = [enumerator nextObject]) != nil) {
    for (count = 0; count < [tmp count]; count++) {
      conflictDetail = nil;
      conflict = [tmp objectAtIndex: count];
      if ([conflict objectForKey:@"resourceName"] == nil) {
        /* Conflict is with a participant */
        if ([conflict objectForKey:@"isTeam"] == nil) {
          /* Participant is a person/contact */
          conflictDetail = [NSDictionary dictionaryWithObjectsAndKeys:
            @"participant", @"type",
            [conflict objectForKey:@"companyId"], @"objectId",
            @"Person", @"entityName",
            [conflict objectForKey:@"partStatus"], @"status",
            [conflict objectForKey:@"role"], @"role",
            nil];
         } else {
             /* Participant is a team */
             conflictDetail = [NSDictionary dictionaryWithObjectsAndKeys:
               @"participant", @"type",
               [conflict objectForKey:@"companyId"], @"objectId",
               @"Team", @"entityName",
               [conflict objectForKey:@"partStatus"], @"status",
               [conflict objectForKey:@"role"], @"role",
               nil];
            }
       } else {
          /* Conflict is with a resource */
          resource = [self _getResourceByName:[conflict 
                                            objectForKey:@"resourceName"]];
          if (resource == nil) {
            [self warnWithFormat:@"could not resolve pkey for resource %@", 
               [conflict objectForKey:@"resourceName"]];
           } else {
               conflictDetail = [NSDictionary dictionaryWithObjectsAndKeys:
                 @"resource", @"type",
                 [resource valueForKey:@"appointmentResourceId"], @"objectId",
                 @"AppointmentResource", @"entityName",
                 [resource valueForKey:@"name"], @"name",
                 [resource valueForKey:@"email"], @"email",
                 [resource valueForKey:@"emailSubject"], @"subject",
                 [resource valueForKey:@"category"], @"category",
                 [conflict objectForKey:@"partStatus"], @"status",
                 [conflict objectForKey:@"role"], @"role",
                 nil];
              } /* End else resource found */
          } /* End else conflict concerns a resource */
      /* Add conflict detail to conflicting appointment info */
      if (conflictDetail == nil) {
         /* Contents of conflict was unparsable somehow */
         [self warnWithFormat:@"potential conflict skipped for appId %@",
            _arg];
       } else {
           /* Store the conflict detail */
           [[[result objectForKey:
                       [[conflict objectForKey:@"dateId"] stringValue]]
                           objectForKey:@"conflicts"] addObject:conflictDetail];
          }
     } /* End for i < [tmp count] */
    } /* End while ((tmp = [enumerator nextObject]) != nil) */
  return [result autorelease];
}

@end /* zOGIAction(AppointmentConflicts */
