/*
  zOGIAction+AppointmentConflicts.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_AppointmentConflicts_H__
#define __zOGIAction_AppointmentConflicts_H__

#include "zOGIAction.h"
#include "zOGIAction+Appointment.h"

@interface zOGIAction(AppointmentConflicts)

-(id)_getConflictsForDate:(id)_appointment;
-(NSArray *)_renderConflictsForDate:(id)_eo;

@end

#endif /* __zOGIAction_AppointmentConflicts_H__ */
