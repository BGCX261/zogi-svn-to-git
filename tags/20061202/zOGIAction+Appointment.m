/*
  zOGIAction+Appointment.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+AppointmentConflicts.h"
#include "zOGIAction+Contact.h"
#include "zOGIAction+Resource.h"
#include "zOGIAction+Team.h"

@implementation zOGIAction(Appointment)

-(NSArray *)_renderAppointments:(NSArray *)_appointments withDetail:(NSNumber *)_detail {
  NSDictionary        *eoAppointment;
  NSMutableDictionary *appointment;
  NSMutableArray      *result;
  int                 count;

  ///[self logWithFormat:@"_renderAppointments(%@)", _appointments];
  if (_appointments == nil) return [NSArray arrayWithObjects:nil];
  if ([_appointments count] == 0) return [NSArray arrayWithObjects:nil];

  result = [NSMutableArray arrayWithCapacity:[_appointments count]];
  for (count = 0; count < [_appointments count]; count++) {
    eoAppointment = [_appointments objectAtIndex:count];
    appointment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [eoAppointment valueForKey:@"dateId"], @"objectId",
                     @"Appointment", @"entityName",
                     [eoAppointment valueForKey:@"objectVersion"], @"version",
                     [eoAppointment valueForKey:@"ownerId"], @"ownerObjectId",
                     [eoAppointment valueForKey:@"endDate"], @"end",
                     [eoAppointment valueForKey:@"startDate"], @"start",
                     [self NIL:[eoAppointment valueForKey:@"title"]], @"title",
                     [self NIL:[eoAppointment valueForKey:@"location"]], @"location",
                     [self NIL:[eoAppointment valueForKey:@"keywords"]], @"keywords",
                     [self NIL:[eoAppointment valueForKey:@"aptType"]], @"type",
                     [self NIL:[eoAppointment valueForKey:@"comment"]], @"comment",
                     nil];
    if([eoAppointment valueForKey:@"type"] != nil) {
      [appointment setObject:[eoAppointment valueForKey:@"parentDateId"]
                   forKey:@"parentObjectId"];
      [appointment setObject:[eoAppointment valueForKey:@"cycleEndDate"]
                   forKey:@"cycleEnd"];
      [appointment setObject:[eoAppointment valueForKey:@"type"]
                   forKey:@"cycleType"];
     }
    [result addObject:appointment];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       if([_detail intValue] & zOGI_INCLUDE_NOTATIONS)
         [self _addNotesToDate:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_PARTICIPANTS)
         [self _addParticipantsToDate:[result objectAtIndex:count]];
       if([_detail intValue] & zOGI_INCLUDE_CONFLICTS)
         [self _addConflictsToDate:[result objectAtIndex:count]];
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
      }
    }
   [self logWithFormat:@"_renderAppointments(...) - returning %@", result];
   return result;
}

-(NSArray *)_getUnrenderedDatesForKeys:(id)_arg {
  return [[[self getCTX]
                      runCommand:@"appointment::get-by-globalid",
                                 @"gids", [self _getEOsForPKeys:_arg],
                                 @"timeZone", [self _getTimeZone],
                                 nil] retain];
}

-(NSArray *)_getUnrenderedDateForKey:(id)_arg {
  return [[self _getUnrenderedDatesForKeys:_arg] lastObject];
}

-(id)_getDatesForKeys:(id)_arg withDetail:(NSNumber *)_detail {

  [self logWithFormat:@"_getDatesForKeys([%@],[%@])", _arg, _detail];
  return [self _renderAppointments:[self _getUnrenderedDatesForKeys:_arg] 
                        withDetail:_detail];
}

-(id)_getDatesForKeys:(id)_pk {
  [self logWithFormat:@"_getDatesForKeys([%@])", _pk];
  return [self _getDatesForKeys:_pk withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getDateForKey:(id)_pk withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getDateForKey([%@],[%@])", _pk, _detail];
  return [[self _getDatesForKeys:_pk withDetail:_detail] objectAtIndex:0];
}

-(id)_getDateForKey:(id)_pk {
  [self logWithFormat:@"_getDateForKey([%@])", _pk];
  return [[self _getDatesForKeys:_pk withDetail:[NSNumber numberWithInt:0]] objectAtIndex:0];
}

-(void)_addNotesToDate:(NSMutableDictionary *)_appointment {
  NSMutableArray    *noteList;
  NSArray           *notes;
  EOGenericRecord   *note;
  int               count;

  noteList = [NSMutableArray new];
  notes = [[self getCTX]
              runCommand:@"note::get",
                         @"dateId", [_appointment valueForKey:@"objectId"],
                         @"returnType", intObj(LSDBReturnType_ManyObjects),
                         nil];
  if (notes == nil)
    notes = [NSArray array];
  [[self getCTX] runCommand:@"note::get-attachment-name", @"notes", notes, nil];
  for (count = 0; count < [notes count]; count++) {
    note = [notes objectAtIndex:count];
    [noteList addObject:
       [NSDictionary dictionaryWithObjectsAndKeys:
          [note valueForKey:@"documentId"], @"objectId",
          @"Note", @"entityName",
          [note valueForKey:@"title"], @"title",
          [note valueForKey:@"firstOwnerId"], @"creatorObjectId",
          [note valueForKey:@"currentOwnerId"], @"ownerObjectId",
          [note valueForKey:@"creationDate"], @"createdTime",
          //[note valueForKey:@"creationDate"], @"createdTime",
          [NSNull null], @"projectObjectId",
          [_appointment valueForKey:@"objectId"], @"dateObjectId",
          [NSString stringWithContentsOfFile:[note valueForKey:@"attachmentName"]],
            @"content",
          nil]];
   }
  [_appointment setObject:noteList forKey:@"_NOTES"];
}

-(void)_addParticipantsToDate:(NSMutableDictionary *)_appointment {
  [self logWithFormat:@"_addParticipantsToDate(...)"];
  NSMutableArray *participantList;
  NSArray        *participants;
  NSDictionary   *participant;
  NSEnumerator   *enumerator;
  

  participantList = [NSMutableArray new];
  participants = 
    [[self getCTX] runCommand:@"appointment::list-participants",
       @"gid", [self _getEOForPKey:[_appointment valueForKey:@"objectId"]],
       @"attributes", [NSArray arrayWithObjects:@"dateCompanyAssignmentId",
                         @"role", @"companyId", @"partStatus", @"comment",
                         @"rsvp", @"team.isTeam", @"team.description",
                         @"team.companyId", @"person.companyId",
                         @"person.firstname", @"person.name", 
                         @"person.isPrivate", @"dateId", nil],
       nil];
  [self logWithFormat:@"_addParticipantsToDate(...) - participants = %@", participants];
  enumerator = [participants objectEnumerator];
  while ((participant = [enumerator nextObject]) != nil) {
    if([participant valueForKey:@"isTeam"] == nil) {
      /* Participant is a contact */
      [participantList addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"Person", @"entityName",
           [participant valueForKey:@"companyId"], @"objectId",
           [participant valueForKey:@"dateCompanyAssignmentId"], @"assignmentId",
           [self NIL:[participant valueForKey:@"firstname"]], @"firstName",
           [self NIL:[participant valueForKey:@"name"]], @"lastname",
           [self NIL:[participant valueForKey:@"role"]], @"role",
           [participant valueForKey:@"isPrivate"], @"private",
           [self NIL:[participant valueForKey:@"partStatus"]], @"status",
           [self NIL:[participant valueForKey:@"rsvp"]], @"rsvp",
           [self NIL:[participant valueForKey:@"comment"]], @"comment",
           nil]];
     } else {
         /* Participant is a team */
         [participantList addObject:
            [NSDictionary dictionaryWithObjectsAndKeys:
               @"Team", @"entityName",
              [participant valueForKey:@"companyId"], @"objectId",
              [participant valueForKey:@"dateCompanyAssignmentId"], @"assignmentId",
              [self NIL:[participant valueForKey:@"description"]], @"name",
              [self NIL:[participant valueForKey:@"role"]], @"role",
              [self NIL:[participant valueForKey:@"rsvp"]], @"rsvp",
              [self NIL:[participant valueForKey:@"comment"]], @"comment",
              nil]];
        }
   }
  [_appointment setObject:participantList forKey:@"_PARTICIPANTS"];
}

-(void)_addConflictsToDate:(NSMutableDictionary *)_appointment {
  [self logWithFormat:@"_addConflictsToDate(...)"];
  [_appointment setObject:[self _renderConflictsForDateKey:[_appointment valueForKey:@"objectId"]]
                forKey:@"_CONFLICTS"];
}

-(id)_setParticipantStatus:(id)_pk 
  withStatus:(NSString *)_partstat withRole:(NSString *)_role
  withComment:(NSString *)_comment withRSVP:(NSNumber *)_rsvp {
  NSMutableDictionary *args;

  args = [NSMutableDictionary dictionaryWithCapacity:8];
  [args setObject:_pk forKey:@"appointment"];
  if (_partstat != nil) [args setObject:_partstat forKey:@"partstatus"];
  if (_role     != nil) [args setObject:_role     forKey:@"role"];
  if (_comment  != nil) [args setObject:_comment  forKey:@"comment"];
  if (_rsvp     != nil) [args setObject:_rsvp     forKey:@"rsvp"];
  return [[self getCTX] runCommand:@"appointment::change-attendee-status"
                                    arguments:args];
}

@end /* End zOGIAction(Appointment) */
