/*
  zOGIAction+Account.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Account.h"
#include "zOGIAction+Object.h"

@implementation zOGIAction(Account)

-(id)_renderAccounts:(NSArray *)_accounts withDetail:(NSString *)_detail {
  NSMutableArray      *result;
  NSDictionary        *eoAccount;
  int                  count;

  result = [NSMutableArray arrayWithCapacity:[_accounts count]];
  for (count = 0; count < [_accounts count]; count++) {
    eoAccount = [_accounts objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [eoAccount valueForKey:@"companyId"], @"objectId",
       @"Account", @"entityName",
       [eoAccount valueForKey:@"objectVersion"], @"version",
       [eoAccount valueForKey:@"login"], @"login",
       nil]];
    if([_detail intValue] > 0)
      [[result objectAtIndex:count] setObject:eoAccount forKey:@"eoObject"];
   }
   if([_detail intValue] > 0) {
     for (count = 0; count < [result count]; count++) {
       [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
       [[result objectAtIndex:count] removeObjectForKey:@"eoObject"];
      }
    }
  return result;
}

-(NSArray *)_getUnrenderedAccountsForKeys:(id)_arg {
  NSArray       *accounts;

  [self logWithFormat:@"_getUnrenderedAccountsForKeys([%@])", _arg];
  accounts = [[[self getCTX] runCommand:@"person::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  if (accounts == nil)
    [self logWithFormat:@"_getUnrenderedAccountsForKeys() - No accounts found"];
   else
     [self logWithFormat:@"_getUnrenderedAccountsForKeys() found %d accounts", [accounts count]];
  return accounts;
}

-(id)_getAccountsForKeys:(id)_arg withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getAccountsForKeys([%@], [%@])", _arg, _detail];
  return [self _renderAccounts:[self _getUnrenderedAccountsForKeys:_arg] withDetail:_detail];
}

-(id)_getAccountsForKeys:(id)_arg {
  return [self _renderAccounts:[self _getUnrenderedAccountsForKeys:_arg] 
               withDetail:[NSNumber numberWithInt:0]];
}

-(id)_getAccountForKey:(id)_pk withDetail:(NSNumber *)_detail {
  [self logWithFormat:@"_getAccountForKey([%@],[%@])", _pk, _detail];
  return [[self _getAccountsForKeys:_pk withDetail:_detail] objectAtIndex:0];
}

-(id)_getAccountForKey:(id)_pk {
  [self logWithFormat:@"_getAccountForKey([%@])", _pk];
  return [[self _getAccountsForKeys:_pk] objectAtIndex:0];
}

-(id)_getLoginAccount:(NSNumber *)_detail {
  id       account;

  [self logWithFormat:@"_getLoginAccount([%@])", _detail];
  account   = [[self getCTX] valueForKey:LSAccountKey];
  if(account == nil)
    [self logWithFormat:@"_getLoginAccount() - account is NIL"];    
   else
     [self logWithFormat:@"_getLoginAccount() - account is ", account];
  return [self _getAccountForKey:[account valueForKey:@"companyId"] withDetail:_detail];
}

@end /* End zOGIAction(Account) */
