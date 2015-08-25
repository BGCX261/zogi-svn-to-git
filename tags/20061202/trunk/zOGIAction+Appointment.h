/*
  zOGIAction+Appointment.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Appointment_H__
#define __zOGIAction_Appointment_H__

#include "zOGIAction.h"

@interface zOGIAction(Appointment)

-(NSArray *)_renderAppointments:(NSArray *)_appointments withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedDatesForKeys:(id)_arg;
-(NSArray *)_getUnrenderedDateForKey:(id)_arg;
-(id)_getDatesForKeys:(id)_arg withDetail:(NSNumber* )_detail;
-(id)_getDatesForKeys:(id)_arg;
-(id)_getDateForKey:(id)_arg withDetail:(NSNumber* )_detail;
-(id)_getDateForKey:(id)_arg;
-(void)_addNotesToDate:(NSMutableDictionary *)_appointment;
-(void)_addParticipantsToDate:(NSMutableDictionary *)_appointment;
-(void)_addConflictsToDate:(NSMutableDictionary *)_appointment;
-(id)_setParticipantStatus:(id)_pk 
  withStatus:(NSString *)_partstat withRole:(NSString *)_role
  withComment:(NSString *)_comment withRSVP:(NSNumber *)_rsvp;

@end

#endif /* __zOGIAction_Appointment_H__ */
