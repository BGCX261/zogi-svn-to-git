/*
  zOGIContactAction.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#include "zOGIContactAction.h"

@implementation zOGIContactAction

-(id)getContactsByObjectIdAction {
  [self logWithFormat:@"zogi.getContactsById(%@)", arg1];
  if([self _checkEntity:arg1 entityName:@"Person"])
    return [self _getContactsForKeys:arg1 withDetail:arg2];
  /* TODO: Throw Exception */
  return nil;
}

-(id)getFavoriteContactsAction {
  return [self _getContactsForKeys:[self _getFavoriteContacts] withDetail:arg1];
}

-(id)searchForContactsAction {
  [self logWithFormat:@"zogi.searchForContacts(%@)", arg1];
  //if([arg1 isKindOfClass:[NSDictionary class]])
    return [self _searchForContacts:arg1 withDetail: arg2];
  /* TODO: Throw Exception */
 // return nil;
}


@end /* zOGIContactAction */
