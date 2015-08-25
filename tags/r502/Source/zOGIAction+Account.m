/*
  zOGIAction+Account.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Account.h"
#include "zOGIAction+Object.h"

@implementation zOGIAction(Account)

/* Render accounts
   _accounts must be an array of EOGenericRecords of account objects */
-(id)_renderAccounts:(NSArray *)_accounts 
          withDetail:(NSNumber *)_detail 
{
  NSMutableArray      *result;
  NSDictionary        *eoAccount;
  int                  count;

  result = [NSMutableArray arrayWithCapacity:[_accounts count]];
  for (count = 0; count < [_accounts count]; count++) 
  {
    eoAccount = [_accounts objectAtIndex:count];
    [result addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       eoAccount, @"*eoObject",
       [eoAccount valueForKey:@"companyId"], @"objectId",
       @"Account", @"entityName",
       [eoAccount valueForKey:@"objectVersion"], @"version",
       [eoAccount valueForKey:@"login"], @"login",
       nil]];
    if([_detail intValue] > 0)
      for (count = 0; count < [result count]; count++)
      {  
        [self _addObjectDetails:[result objectAtIndex:count] withDetail:_detail];
      }
    [self _stripInternalKeys:[result objectAtIndex:count]];
  } /* End for-each-account loop */
  return result;
} /* End _renderAccounts */

/* Get specified accounts from logic layer */
-(NSArray *)_getUnrenderedAccountsForKeys:(id)_arg 
{
  NSArray       *accounts;

  accounts = [[[self getCTX] runCommand:@"person::get-by-globalid",
                                        @"gids", [self _getEOsForPKeys:_arg],
                                        nil] retain];
  return accounts;
} /* End _getUnrenderedAccountsForKeys */

/* Get rendered accounts at specified detail level */
-(id)_getAccountsForKeys:(id)_arg withDetail:(NSNumber *)_detail 
{
  return [self _renderAccounts:[self _getUnrenderedAccountsForKeys:_arg] 
                     withDetail:_detail];
} /* End _getAccountsForKeys */

/* Get rendered accounts at default detail level (0) */
-(id)_getAccountsForKeys:(id)_arg 
{
  return [self _renderAccounts:[self _getUnrenderedAccountsForKeys:_arg] 
                     withDetail:[NSNumber numberWithInt:0]];
} /* End _getAccountsForKeys */

/* Get one rendered account at specified detail level */
-(id)_getAccountForKey:(id)_pk withDetail:(NSNumber *)_detail 
{
  return [[self _getAccountsForKeys:_pk withDetail:_detail] objectAtIndex:0];
} /* End _getAccountForKey */

/* Get one rendered account at detail detail level (0) */
-(id)_getAccountForKey:(id)_pk 
{
  return [[self _getAccountsForKeys:_pk] objectAtIndex:0];
} /* End _getAccountForKey */

/* Get rendered account for current account at specified detail level */
-(id)_getLoginAccount:(NSNumber *)_detail 
{
  id       account;

  account   = [[self getCTX] valueForKey:LSAccountKey];
  return [self _getAccountForKey:[account valueForKey:@"companyId"] 
                       withDetail:_detail];
} /* End _getLoginAccount */

@end /* End zOGIAction(Account) */
