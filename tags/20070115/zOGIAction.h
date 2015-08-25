/*
  zOGIAction.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __zOGIAction_H__
#define __zOGIAction_H__

#include <ZSFrontend/SxFolder.h>
#include <ZSFrontend/SxObject.h>
#include <zOGIDetailLevels.h>
#include <NSObject+zOGI.h>
#include "common.h"

@interface zOGIAction : WODirectAction
{
  id                arg1, arg2, arg3, arg4;
  LSCommandContext *ctx;
}

/* accessors */

- (void)setArg1:(id)_arg;
- (void)setArg2:(id)_arg;
- (void)setArg3:(id)_arg;
- (void)setArg4:(id)_arg;
- (id)arg1;
- (id)arg2;
- (id)arg3;
- (id)arg4;
- (id)NIL:(id)_arg;
- (id)defaultAction;
- (LSCommandContext *)getCTX;
- (EOGlobalID *)_getEOForPKey:(id)_arg;
- (NSArray *)_getEOsForPKeys:(id)_arg;
- (NSString *)_getEntityNameForPKey:(id)_arg;
- (NSString *)_izeEntityName:(NSString *)_arg;
- (id)_checkEntity:(id)_pkey entityName:(id)_name;
- (NSString *)_getPKeyForEO:(EOKeyGlobalID *)_arg;
- (NSUserDefaults *)_getDefaults;
- (NSString *)_getDefault:(NSString *)_value;
- (NSNumber *)_getCompanyId;
- (NSTimeZone *)_getTimeZone;
- (NSCalendarDate *)_makeCalendarDate:(id)_date;

@end /* zOGIAction */

#endif /* __zOGIAction_H__ */
