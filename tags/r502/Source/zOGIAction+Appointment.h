/*
  zOGIAction+Appointment.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Appointment_H__
#define __zOGIAction_Appointment_H__

#include "zOGIAction.h"

@interface zOGIAction(Appointment)

-(NSDictionary *)_renderAppointment:(NSDictionary *)eoAppointment
                         withDetail:(NSNumber *)_detail;
-(NSArray *)_renderAppointments:(NSArray *)_appointments 
                     withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedDatesForKeys:(id)_arg;
-(NSArray *)_getUnrenderedDateForKey:(id)_arg;
-(id)_getDatesForKeys:(id)_arg 
           withDetail:(NSNumber* )_detail;
-(id)_getDatesForKeys:(id)_arg;
-(id)_getDateForKey:(id)_arg 
         withDetail:(NSNumber* )_detail;
-(id)_getDateForKey:(id)_arg;
-(void)_addNotesToDate:(NSMutableDictionary *)_appointment;
-(void)_addParticipantsToDate:(NSMutableDictionary *)_appointment;
-(void)_addConflictsToDate:(id)_appointment;
-(id)_setParticipantStatus:(id)_pk 
                withStatus:(NSString *)_partstat 
                  withRole:(NSString *)_role
               withComment:(NSString *)_comment 
                  withRSVP:(NSNumber *)_rsvp;
-(id)_searchForAppointments:(NSDictionary *)_query 
                 withDetail:(NSNumber *)_detail;
-(id)_createAppointment:(NSDictionary *)_app 
              withFlags:(NSArray *)_flags;
-(id)_updateAppointment:(NSDictionary *)_app 
               objectId:(NSString *)_objectId
              withFlags:(NSArray *)_flags;
-(id)_deleteAppointment:(NSString *)_objectId
              withFlags:(NSArray *)_flags;
-(id)_writeAppointment:(NSDictionary *)_appointment
           withCommand:(NSString *)_command
             withFlags:(NSArray *)_flags;
-(id)_translateParticipants:(NSArray *)_participants;
-(id)_translateAppointment:(NSDictionary *)_appointment
                 withFlags:(NSArray *)_flags;

@end

#endif /* __zOGIAction_Appointment_H__ */
