/*
  zOGISchedularAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGISchedularAction_H__
#define __zOGISchedularAction_H__

#include "common.h"
#include "zOGIAction.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+AppointmentConflicts.h"

@interface zOGISchedularAction : zOGIAction
{
}

-(id)getAppointmentsByObjectIdAction;
-(id)getConflictsByObjectIdAction;
-(id)acceptAppointmentAction;
-(id)declineAppointmentAction;
-(id)acceptAppointmentTentativelyAction;
-(id)resetAppointmentStatusAction;

@end /* End zOGISchedularAction */

#endif /* __zOGISchedularAction_H__ */
