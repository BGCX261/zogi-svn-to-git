/*
  zOGIAction+Account.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006, 2007
*/
#ifndef __zOGIAction_Account_H__
#define __zOGIAction_Account_H__

#include "zOGIAction.h"

@interface zOGIAction(Account)

-(id)_renderAccounts:(NSArray *)_accounts 
          withDetail:(NSNumber *)_detail;

-(NSArray *)_getUnrenderedAccountsForKeys:(id)_arg;

-(id)_getAccountsForKeys:(id)_arg 
              withDetail:(NSNumber *)_detail;

-(id)_getAccountsForKeys:(id)_arg;

-(id)_getAccountForKey:(id)_pk 
            withDetail:(NSNumber *)_detail;

-(id)_getAccountForKey:(id)_pk;

-(id)_getLoginAccount:(NSNumber *)_detail;

@end

#endif /* __zOGIAction_Account_H__ */
