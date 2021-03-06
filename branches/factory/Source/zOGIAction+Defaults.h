/*
  Copyright (C) 2006-2007 Whitemice Consulting

  This file is part of OpenGroupware.org.

  OGo is free software; you can redistribute it and/or modify it under
  the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation; either version 2, or (at your option) any
  later version.

  OGo is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
  License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with OGo; see the file COPYING.  If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.
*/

#ifndef __zOGIAction_Defaults_H__
#define __zOGIAction_Defaults_H__

#include "zOGIAction.h"

@interface zOGIAction(Defaults)

-(id)_storeDefaults:(NSDictionary *)_defaults 
          withFlags:(NSArray *)_flags;
-(NSUserDefaults *)_getDefaults;
-(id)_getDefault:(NSString *)_value;
-(NSDictionary *)_getDefaultsForAccount:(id)_account;
-(NSArray *)_getSchedularPanel;
-(NSTimeZone *)_getTimeZoneForAccount:(id)_account;
-(NSString *)_getCCAddressForAccount:(id)_account;
-(NSArray *)_getDefaultWriteAccessFromDefaults:(NSUserDefaults *)_ud;

@end

#endif /* __zOGIAction_Defaults_H__ */
