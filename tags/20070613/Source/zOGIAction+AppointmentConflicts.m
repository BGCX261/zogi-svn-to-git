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

/* Create an array of conflicts with the provided appointment */
-(NSArray *)_renderConflictsForDate:(id)_eo {
  NSArray               *aptAttrs      = nil;
  NSMutableDictionary   *renderedConflict;
  NSDictionary          *conflict;
  NSDictionary          *conflictDates;
  NSDictionary          *conflictDate;
  NSMutableArray        *conflicts;
  NSEnumerator          *dateEnumerator;
  NSEnumerator          *conflictEnumerator;
  id                    resource;

  /* Get required bits from user defaults */
  aptAttrs = [[[[self getCTX] userDefaults]
                   arrayForKey:@"schedulerconflicts_fetchkeys"] copy];

  /* Getting conflict info */
  conflictDates = [[self _getConflictsForDate:_eo] retain];

  /* Initialize array of conflicts */
  conflicts = [[NSMutableArray alloc] initWithCapacity:[conflictDates count]];

  /* Initialize dictionary for results with summary
     of conflicting appointments */
  dateEnumerator = [[conflictDates allKeys] objectEnumerator];
  while ((conflictDate = [dateEnumerator nextObject]) != nil) 
  {
    conflictEnumerator = [[conflictDates objectForKey:conflictDate] objectEnumerator];
      while ((conflict = [conflictEnumerator nextObject]) != nil)
      {
        renderedConflict = [NSMutableDictionary new];
        [renderedConflict setObject:@"appointmentConflict" forKey:@"entityName"];
        [renderedConflict setObject:[self _getPKeyForEO:(id)conflictDate]
                             forKey:@"appointmentObjectId"];
        [renderedConflict setObject:[conflict objectForKey:@"partStatus"]
                             forKey:@"status"];
        if([conflict objectForKey:@"companyId"] == nil)
        {
         // Resource
          [renderedConflict setObject:@"Resource" 
                               forKey:@"conflictingEntityName"];
 
          resource = [self _getResourceByName:[conflict
                                             objectForKey:@"resourceName"]];
          if (resource == nil)
          {
             [self warnWithFormat:@"could not resolve pkey for resource %@",
                [conflict objectForKey:@"resourceName"]];
          } else 
            {
              [renderedConflict 
                 setObject:[resource valueForKey:@"appointmentResourceId"]
                    forKey:@"conflictingObjectId"];
            } 
        } else
          {
           // Contact / Team
           [renderedConflict setObject:[conflict objectForKey:@"companyId"]
                                forKey:@"conflictingObjectId"];
           if([conflict objectForKey:@"isTeam"] == nil)
             [renderedConflict setObject:@"Contact" 
                                  forKey:@"conflictingEntityName"];
             else [renderedConflict setObject:@"Team" 
                                       forKey:@"conflictingEntityName"];
          }
        [conflicts addObject:renderedConflict];
      }
  }
  return conflicts;
}

@end /* zOGIAction(AppointmentConflicts */
